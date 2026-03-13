import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// FCM Service — handles token registration and push notification routing.
///
/// ## Setup Required
/// 1. Run `flutterfire configure` to generate firebase_options.dart
/// 2. Add to pubspec.yaml:
///    - firebase_core
///    - firebase_messaging
///    - flutter_local_notifications
/// 3. Add google-services.json (Android) and GoogleService-Info.plist (iOS)
/// 4. Uncomment Firebase initialization in main.dart
/// 5. Call `FcmService.initialize(ref)` after Firebase.initializeApp()
///
/// ## Architecture
/// - Token registration: saved to `fcm_tokens` table via Supabase
/// - Push sending: handled by Edge Functions (notify-push), NOT client-side
/// - Foreground display: flutter_local_notifications (when package is added)
/// - Deep linking: notification tap → GoRouter navigation
class FcmService {
  FcmService._();

  static bool _initialized = false;

  /// Initialize FCM and register token.
  /// Call this after Firebase.initializeApp() in main.dart.
  static Future<void> initialize(WidgetRef ref) async {
    if (_initialized) return;

    try {
      // TODO: Uncomment when firebase_messaging is added
      // final messaging = FirebaseMessaging.instance;
      //
      // // Request permission (iOS)
      // final settings = await messaging.requestPermission(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );
      // debugPrint('FCM permission: ${settings.authorizationStatus}');
      //
      // // Get and register token
      // final token = await messaging.getToken();
      // if (token != null) {
      //   await _registerToken(ref, token);
      // }
      //
      // // Listen for token refresh
      // messaging.onTokenRefresh.listen((newToken) {
      //   _registerToken(ref, newToken);
      // });
      //
      // // Foreground message handler
      // FirebaseMessaging.onMessage.listen((message) {
      //   _handleForegroundMessage(message);
      // });
      //
      // // Background message opened handler (app was in background)
      // FirebaseMessaging.onMessageOpenedApp.listen((message) {
      //   _handleNotificationTap(message.data);
      // });
      //
      // // Check for initial message (app was terminated)
      // final initialMessage = await messaging.getInitialMessage();
      // if (initialMessage != null) {
      //   _handleNotificationTap(initialMessage.data);
      // }

      _initialized = true;
      debugPrint('FCM service initialized (placeholder — Firebase not configured)');
    } catch (e) {
      debugPrint('FCM initialization skipped: $e');
    }
  }

  /// Register FCM token to Supabase fcm_tokens table
  static Future<void> _registerToken(WidgetRef ref, String token) async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      final platform = Platform.isIOS ? 'ios' : 'android';

      await client.from('fcm_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'user_id,platform',
      );

      debugPrint('FCM token registered: ${token.substring(0, 20)}...');
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }
  }

  /// Remove FCM tokens on logout
  static Future<void> removeTokens() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;

      await client.from('fcm_tokens').delete().eq('user_id', user.id);
      _initialized = false;
      debugPrint('FCM tokens removed');
    } catch (e) {
      debugPrint('Failed to remove FCM tokens: $e');
    }
  }

  /// Handle foreground push notification — show local notification banner
  // ignore: unused_element
  static void _handleForegroundMessage(dynamic message) {
    // TODO: Uncomment when flutter_local_notifications is added
    // final notification = message.notification;
    // if (notification == null) return;
    //
    // final data = message.data;
    // final type = data['type'] as String? ?? '';
    //
    // // Skip if user is currently viewing the relevant chat
    // if (type == 'new_message') {
    //   // Check if the user has this conversation open
    //   // If yes, skip showing the notification
    // }
    //
    // FlutterLocalNotificationsPlugin().show(
    //   notification.hashCode,
    //   notification.title,
    //   notification.body,
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'cupplus_default',
    //       'CupPlus Notifications',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //     ),
    //     iOS: const DarwinNotificationDetails(),
    //   ),
    //   payload: json.encode(data),
    // );
    debugPrint('Foreground message received (handler not active)');
  }

  /// Handle notification tap — navigate to relevant screen
  static void _handleNotificationTap(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final targetId = data['target_id'] as String?;

    debugPrint('Notification tapped: type=$type, targetId=$targetId');

    // Navigation will be handled via GoRouter when properly wired
    // See NotificationBottomSheet._onNotificationTap for deep linking logic
  }
}
