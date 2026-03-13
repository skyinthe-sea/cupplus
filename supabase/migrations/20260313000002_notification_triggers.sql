-- Notification triggers for automated push notifications
-- These triggers INSERT into the notifications table.
-- The Edge Function (notify-push) can be invoked via Supabase Dashboard
-- webhook on notifications INSERT events for FCM delivery.
--
-- NOTE: handle_match_accepted (migration 20260312000012) already creates
-- notifications for BOTH managers on match acceptance + conversation creation.
-- This migration only handles: new match (pending), declined, new message,
-- and verification result.

-- ─── 1. Match Request Notification ────────────────────────────
-- When a new match is created (status='pending'), notify the OTHER manager
CREATE OR REPLACE FUNCTION public.notify_new_match()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_requester_name TEXT;
  v_client_a_name TEXT;
  v_client_b_name TEXT;
  v_target_manager_id UUID;
BEGIN
  IF NEW.status != 'pending' THEN
    RETURN NEW;
  END IF;

  SELECT full_name INTO v_requester_name
  FROM managers WHERE id = NEW.manager_id;

  SELECT full_name INTO v_client_a_name
  FROM clients WHERE id = NEW.client_a_id;

  SELECT full_name INTO v_client_b_name
  FROM clients WHERE id = NEW.client_b_id;

  SELECT manager_id INTO v_target_manager_id
  FROM clients WHERE id = NEW.client_b_id;

  IF v_target_manager_id IS NOT NULL AND v_target_manager_id != NEW.manager_id THEN
    INSERT INTO notifications (user_id, title, body, type, data, status)
    VALUES (
      v_target_manager_id,
      '새 매칭 요청',
      COALESCE(v_requester_name, '매니저') || '님이 ' ||
        COALESCE(v_client_a_name, '?') || '↔' ||
        COALESCE(v_client_b_name, '?') || ' 매칭을 요청했습니다',
      'new_match',
      jsonb_build_object(
        'match_id', NEW.id::TEXT,
        'client_a_name', COALESCE(v_client_a_name, ''),
        'client_b_name', COALESCE(v_client_b_name, '')
      ),
      'pending'
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_new_match ON matches;
CREATE TRIGGER trg_notify_new_match
  AFTER INSERT ON matches
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_new_match();


-- ─── 2. Match Declined Notification ───────────────────────────
-- Only handles 'declined' — 'accepted' is handled by handle_match_accepted
CREATE OR REPLACE FUNCTION public.notify_match_declined()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_client_a_name TEXT;
  v_client_b_name TEXT;
BEGIN
  IF OLD.status = NEW.status THEN RETURN NEW; END IF;
  IF NEW.status != 'declined' THEN RETURN NEW; END IF;

  SELECT full_name INTO v_client_a_name FROM clients WHERE id = NEW.client_a_id;
  SELECT full_name INTO v_client_b_name FROM clients WHERE id = NEW.client_b_id;

  INSERT INTO notifications (user_id, title, body, type, data, status)
  VALUES (
    NEW.manager_id,
    '매칭 거절',
    COALESCE(v_client_a_name, '?') || '↔' ||
      COALESCE(v_client_b_name, '?') || ' 매칭이 거절되었습니다',
    'match_response',
    jsonb_build_object(
      'match_id', NEW.id::TEXT,
      'match_status', 'declined',
      'client_a_name', COALESCE(v_client_a_name, ''),
      'client_b_name', COALESCE(v_client_b_name, '')
    ),
    'pending'
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_match_declined ON matches;
CREATE TRIGGER trg_notify_match_declined
  AFTER UPDATE OF status ON matches
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_match_declined();


-- ─── 3. New Message Notification ──────────────────────────────
-- Notify the other participant when a new chat message arrives.
-- Skip system messages and messages from handle_match_accepted
-- (which already inserts its own notifications).
CREATE OR REPLACE FUNCTION public.notify_new_message()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_sender_name TEXT;
  v_recipient_id UUID;
  v_preview TEXT;
  v_participant_a UUID;
  v_participant_b UUID;
BEGIN
  SELECT participant_a, participant_b
  INTO v_participant_a, v_participant_b
  FROM conversations WHERE id = NEW.conversation_id;

  IF v_participant_a IS NULL THEN RETURN NEW; END IF;

  IF v_participant_a = NEW.sender_id THEN
    v_recipient_id := v_participant_b;
  ELSE
    v_recipient_id := v_participant_a;
  END IF;

  IF v_recipient_id IS NULL OR v_recipient_id = NEW.sender_id THEN
    RETURN NEW;
  END IF;

  -- Skip if this message was just created as part of match acceptance
  -- (handle_match_accepted already created notifications)
  IF NEW.content LIKE '매칭이 성사되었습니다%' THEN
    RETURN NEW;
  END IF;

  SELECT full_name INTO v_sender_name
  FROM managers WHERE id = NEW.sender_id;

  IF NEW.type = 'image' THEN
    v_preview := '사진을 보냈습니다';
  ELSE
    v_preview := LEFT(COALESCE(NEW.content, ''), 50);
    IF LENGTH(COALESCE(NEW.content, '')) > 50 THEN
      v_preview := v_preview || '...';
    END IF;
  END IF;

  INSERT INTO notifications (user_id, title, body, type, data, status)
  VALUES (
    v_recipient_id,
    COALESCE(v_sender_name, '매니저'),
    v_preview,
    'new_message',
    jsonb_build_object(
      'conversation_id', NEW.conversation_id::TEXT,
      'message_id', NEW.id::TEXT,
      'sender_id', NEW.sender_id::TEXT
    ),
    'pending'
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_new_message ON messages;
CREATE TRIGGER trg_notify_new_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_new_message();


-- ─── 4. Verification Result Notification ──────────────────────
CREATE OR REPLACE FUNCTION public.notify_verification_result()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_title TEXT;
  v_body TEXT;
BEGIN
  IF OLD.status = NEW.status THEN RETURN NEW; END IF;
  IF NEW.status NOT IN ('approved', 'rejected') THEN RETURN NEW; END IF;

  IF NEW.status = 'approved' THEN
    v_title := '매니저 인증 완료';
    v_body := '매니저 인증이 승인되었습니다. 이제 매칭 요청이 가능합니다!';
  ELSE
    v_title := '매니저 인증 반려';
    v_body := '매니저 인증이 반려되었습니다.';
    IF NEW.rejection_reason IS NOT NULL AND NEW.rejection_reason != '' THEN
      v_body := v_body || ' 사유: ' || NEW.rejection_reason;
    END IF;
  END IF;

  INSERT INTO notifications (user_id, title, body, type, data, status)
  VALUES (
    NEW.manager_id,
    v_title,
    v_body,
    'verification_result',
    jsonb_build_object(
      'document_id', NEW.id::TEXT,
      'verification_status', NEW.status
    ),
    'pending'
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_verification_result ON manager_verification_documents;
CREATE TRIGGER trg_notify_verification_result
  AFTER UPDATE OF status ON manager_verification_documents
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_verification_result();


-- ─── 5. Enable Realtime for notifications ─────────────────────
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
  END IF;
END $$;
