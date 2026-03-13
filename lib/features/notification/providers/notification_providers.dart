import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';

part 'notification_providers.g.dart';

/// Default notification settings — all enabled
const _defaultSettings = {
  'match_notifications': true,
  'message_notifications': true,
  'verification_notifications': true,
  'system_notifications': true,
};

/// Notification settings model
class NotificationSettings {
  const NotificationSettings({
    this.matchNotifications = true,
    this.messageNotifications = true,
    this.verificationNotifications = true,
    this.systemNotifications = true,
  });

  final bool matchNotifications;
  final bool messageNotifications;
  final bool verificationNotifications;
  final bool systemNotifications;

  factory NotificationSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationSettings();
    return NotificationSettings(
      matchNotifications: map['match_notifications'] as bool? ?? true,
      messageNotifications: map['message_notifications'] as bool? ?? true,
      verificationNotifications:
          map['verification_notifications'] as bool? ?? true,
      systemNotifications: map['system_notifications'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'match_notifications': matchNotifications,
        'message_notifications': messageNotifications,
        'verification_notifications': verificationNotifications,
        'system_notifications': systemNotifications,
      };

  NotificationSettings copyWith({
    bool? matchNotifications,
    bool? messageNotifications,
    bool? verificationNotifications,
    bool? systemNotifications,
  }) {
    return NotificationSettings(
      matchNotifications: matchNotifications ?? this.matchNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      verificationNotifications:
          verificationNotifications ?? this.verificationNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
    );
  }
}

/// Fetch current user's notification settings from managers table
@riverpod
Future<NotificationSettings> notificationSettings(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return const NotificationSettings();

  final result = await client
      .from('managers')
      .select('notification_settings')
      .eq('id', user.id)
      .maybeSingle();

  if (result == null) return const NotificationSettings();

  final raw = result['notification_settings'];
  if (raw is Map<String, dynamic>) {
    return NotificationSettings.fromMap(raw);
  }
  return const NotificationSettings();
}

/// Update notification settings
@riverpod
Future<void> updateNotificationSettings(
  Ref ref,
  NotificationSettings settings,
) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  await client
      .from('managers')
      .update({'notification_settings': settings.toMap()}).eq('id', user.id);

  ref.invalidate(notificationSettingsProvider);
}

/// Register FCM token to fcm_tokens table
/// Called after obtaining token from Firebase Messaging
@riverpod
Future<void> registerFcmToken(
  Ref ref, {
  required String token,
  required String platform,
}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  await client.from('fcm_tokens').upsert(
    {
      'user_id': user.id,
      'token': token,
      'platform': platform,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    },
    onConflict: 'user_id,platform',
  );

  debugPrint('FCM token registered for ${user.id} ($platform)');
}

/// Remove FCM token (on logout)
@riverpod
Future<void> removeFcmToken(Ref ref) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  await client.from('fcm_tokens').delete().eq('user_id', user.id);

  debugPrint('FCM tokens removed for ${user.id}');
}

/// Mark a single notification as read
@riverpod
Future<void> markNotificationRead(Ref ref, String notificationId) async {
  final client = ref.read(supabaseClientProvider);
  await client
      .from('notifications')
      .update({'is_read': true}).eq('id', notificationId);
}
