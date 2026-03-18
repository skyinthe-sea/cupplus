// Supabase Edge Function: notify-push
// Unified push notification sender for all notification types.
//
// Two invocation modes:
// 1. Direct call: POST { type, user_id, title, body, data }
//    → Inserts notification + sends FCM push
// 2. Database Webhook: POST { type: "INSERT", table: "notifications", record: {...} }
//    → Reads existing notification row + sends FCM push
//
// Triggered by Database Webhooks on:
// - notifications INSERT → FCM delivery
//
// Required secrets (set via `supabase secrets set`):
// - GOOGLE_SERVICE_ACCOUNT_JSON: Firebase service account for FCM v1 API
//
// Deploy: supabase functions deploy notify-push

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const GOOGLE_SERVICE_ACCOUNT_JSON = Deno.env.get("GOOGLE_SERVICE_ACCOUNT_JSON");

interface NotificationPayload {
  type: "new_match" | "match_response" | "new_message" | "verification_result" | "system";
  user_id: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: Record<string, unknown>;
  schema: string;
  old_record: Record<string, unknown> | null;
}

// ─── FCM Access Token ────────────────────────────────────────
let cachedAccessToken: string | null = null;
let tokenExpiresAt = 0;

async function getFcmAccessToken(): Promise<string | null> {
  if (!GOOGLE_SERVICE_ACCOUNT_JSON) {
    console.warn("GOOGLE_SERVICE_ACCOUNT_JSON not configured — FCM disabled");
    return null;
  }

  if (cachedAccessToken && Date.now() < tokenExpiresAt) {
    return cachedAccessToken;
  }

  const sa = JSON.parse(GOOGLE_SERVICE_ACCOUNT_JSON);
  const now = Math.floor(Date.now() / 1000);

  // Create JWT for Google OAuth2
  const header = btoa(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claim = btoa(
    JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
    })
  );

  const unsignedToken = `${header}.${claim}`;

  // Import RSA private key and sign
  const pemContents = sa.private_key
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\n/g, "");
  const binaryKey = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsignedToken)
  );

  const signedJwt = `${unsignedToken}.${btoa(
    String.fromCharCode(...new Uint8Array(signature))
  )
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "")}`;

  // Exchange JWT for access token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signedJwt}`,
  });

  if (!tokenRes.ok) {
    console.error("Failed to get FCM access token:", await tokenRes.text());
    return null;
  }

  const tokenData = await tokenRes.json();
  cachedAccessToken = tokenData.access_token;
  tokenExpiresAt = Date.now() + (tokenData.expires_in - 60) * 1000;
  return cachedAccessToken;
}

// ─── Send FCM Message ────────────────────────────────────────
async function sendFcmMessage(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
  projectId: string
): Promise<boolean> {
  const accessToken = await getFcmAccessToken();
  if (!accessToken) return false;

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          android: {
            priority: "high",
            notification: {
              channel_id: "cupplus_default",
              click_action: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
          apns: {
            payload: {
              aps: {
                alert: { title, body },
                badge: 1,
                sound: "default",
              },
            },
          },
        },
      }),
    }
  );

  if (!res.ok) {
    const errText = await res.text();
    console.error(`FCM send failed for token ${token.substring(0, 20)}...:`, errText);

    // If token is invalid, remove it
    if (errText.includes("UNREGISTERED") || errText.includes("INVALID_ARGUMENT")) {
      console.log("Removing invalid FCM token");
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
      await supabase.from("fcm_tokens").delete().eq("token", token);
    }
    return false;
  }

  return true;
}

// ─── Send push for a notification record ─────────────────────
async function sendPushForNotification(
  supabase: ReturnType<typeof createClient>,
  notificationId: string,
  userId: string,
  type: string,
  title: string,
  body: string,
  data: Record<string, string>
): Promise<Response> {
  // Check user's notification settings
  const notifTypeKey: Record<string, string> = {
    new_match: "match_notifications",
    match_response: "match_notifications",
    new_message: "message_notifications",
    verification_result: "verification_notifications",
    system: "system_notifications",
  };

  const settingKey = notifTypeKey[type];
  if (settingKey) {
    const { data: manager } = await supabase
      .from("managers")
      .select("notification_settings")
      .eq("id", userId)
      .maybeSingle();

    const settings = manager?.notification_settings ?? {};
    if (settings[settingKey] === false) {
      console.log(`Notification skipped: ${type} disabled for user ${userId}`);
      return new Response(
        JSON.stringify({ status: "skipped", reason: "notification_disabled" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }
  }

  // Fetch FCM tokens for the user
  const { data: tokens } = await supabase
    .from("fcm_tokens")
    .select("token, platform")
    .eq("user_id", userId);

  if (!tokens || tokens.length === 0) {
    console.log(`No FCM tokens for user ${userId} — notification saved to DB only`);
    await supabase
      .from("notifications")
      .update({ status: "sent" })
      .eq("id", notificationId);

    return new Response(
      JSON.stringify({ status: "saved", notification_id: notificationId, push_sent: false }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  }

  // Get Firebase project ID from service account
  let projectId = "cupplus";
  if (GOOGLE_SERVICE_ACCOUNT_JSON) {
    try {
      const sa = JSON.parse(GOOGLE_SERVICE_ACCOUNT_JSON);
      projectId = sa.project_id || projectId;
    } catch (_) {
      // use default
    }
  }

  // Send push to all user's devices
  const fcmData: Record<string, string> = {
    type,
    notification_id: notificationId,
    ...Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    ),
  };

  let anySent = false;
  for (const { token } of tokens) {
    const success = await sendFcmMessage(token, title, body, fcmData, projectId);
    if (success) anySent = true;
  }

  // Update notification status
  await supabase
    .from("notifications")
    .update({
      status: anySent ? "sent" : "failed",
      sent_at: anySent ? new Date().toISOString() : null,
      retries: anySent ? 0 : 1,
    })
    .eq("id", notificationId);

  return new Response(
    JSON.stringify({
      status: anySent ? "sent" : "failed",
      notification_id: notificationId,
      tokens_attempted: tokens.length,
    }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  );
}

// ─── Main Handler ────────────────────────────────────────────
serve(async (req: Request) => {
  try {
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
    const rawPayload = await req.json();

    // ─── Mode 2: Database Webhook (notifications INSERT) ─────
    // Webhook payload has { type: "INSERT", table: "notifications", record: {...} }
    if (rawPayload.table === "notifications" && rawPayload.record) {
      const webhook = rawPayload as WebhookPayload;
      const record = webhook.record;

      // Skip if already processed
      if (record.status !== "pending") {
        return new Response(
          JSON.stringify({ status: "skipped", reason: "not_pending" }),
          { status: 200, headers: { "Content-Type": "application/json" } }
        );
      }

      return sendPushForNotification(
        supabase,
        record.id as string,
        record.user_id as string,
        record.type as string,
        record.title as string,
        record.body as string,
        (record.data as Record<string, string>) ?? {}
      );
    }

    // ─── Mode 1: Direct call ─────────────────────────────────
    const payload: NotificationPayload = rawPayload;
    const { type, user_id, title, body, data = {} } = payload;

    if (!type || !user_id || !title || !body) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: type, user_id, title, body" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    // Insert notification record into DB
    const { data: notification, error: insertError } = await supabase
      .from("notifications")
      .insert({
        user_id,
        title,
        body,
        data,
        type,
        status: "pending",
        retries: 0,
      })
      .select("id")
      .single();

    if (insertError) {
      console.error("Failed to insert notification:", insertError);
      return new Response(
        JSON.stringify({ error: "Failed to create notification record" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    return sendPushForNotification(
      supabase,
      notification.id,
      user_id,
      type,
      title,
      body,
      data
    );
  } catch (error) {
    console.error("notify-push error:", error);
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});
