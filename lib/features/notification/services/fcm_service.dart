import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router.dart';
import '../../../config/routes.dart';

/// Top-level handler for background/terminated FCM messages.
/// Must be a top-level function (not a class method).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

/// FCM Service — handles token registration, foreground display, and deep linking.
///
/// ## Setup
/// 1. Run `flutterfire configure`
/// 2. Call `FcmService.initialize()` after `Firebase.initializeApp()` in main.dart
/// 3. Set up Supabase Database Webhook on `notifications` INSERT → Edge Function `notify-push`
class FcmService {
  FcmService._();

  static bool _initialized = false;
  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static StreamSubscription<String>? _tokenRefreshSub;
  static StreamSubscription<RemoteMessage>? _foregroundMsgSub;
  static StreamSubscription<RemoteMessage>? _backgroundOpenSub;
  static int _notificationIdCounter = 0;

  /// Android notification channel
  static const _androidChannel = AndroidNotificationChannel(
    'cupplus_default',
    'CupPlus 알림',
    description: '매칭, 채팅, 인증 알림',
    importance: Importance.high,
  );

  /// Initialize FCM: request permission, register token, set up listeners.
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (iOS — Android 13+ auto-handled by the package)
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('FCM permission denied — push notifications disabled');
        _initialized = true;
        return;
      }

      // Set up local notifications (for foreground display)
      await _setupLocalNotifications();

      // Get and register token
      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // Cancel previous subscriptions to prevent duplicates on re-login
      await _tokenRefreshSub?.cancel();
      await _foregroundMsgSub?.cancel();
      await _backgroundOpenSub?.cancel();

      // Listen for token refresh
      _tokenRefreshSub = messaging.onTokenRefresh.listen(_registerToken);

      // Foreground message handler
      _foregroundMsgSub = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Background: user tapped notification while app was in background
      _backgroundOpenSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleNotificationTap(message.data);
      });

      // Terminated: app was killed, user tapped notification to launch
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        // Delay slightly to ensure router is ready
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(initialMessage.data);
        });
      }

      _initialized = true;
      debugPrint('FCM service initialized successfully');
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  /// Set up flutter_local_notifications for foreground display
  static Future<void> _setupLocalNotifications() async {
    // Create Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // User tapped a local notification
        if (response.payload != null) {
          try {
            final data = jsonDecode(response.payload!) as Map<String, dynamic>;
            _handleNotificationTap(data);
          } catch (_) {}
        }
      },
    );
  }

  /// Register FCM token to Supabase fcm_tokens table
  static Future<void> _registerToken(String token) async {
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
      // Cancel stream subscriptions to prevent duplicate handlers on re-login
      await _tokenRefreshSub?.cancel();
      await _foregroundMsgSub?.cancel();
      await _backgroundOpenSub?.cancel();
      _tokenRefreshSub = null;
      _foregroundMsgSub = null;
      _backgroundOpenSub = null;

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

  /// Handle foreground push — show local notification banner.
  /// Skips if user is currently viewing the relevant chat.
  static void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    final data = message.data;
    final type = data['type'] as String? ?? '';

    // Skip chat notification if user has that conversation open
    if (type == 'new_message') {
      final conversationId = data['conversation_id'] as String?;
      if (conversationId != null && _isViewingChat(conversationId)) {
        debugPrint('Skipping foreground notification — user is in this chat');
        return;
      }
    }

    _notificationIdCounter = (_notificationIdCounter + 1) & 0x7FFFFFFF;
    _localNotifications.show(
      _notificationIdCounter,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  /// Check if the user is currently viewing a specific chat room
  static bool _isViewingChat(String conversationId) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;

    try {
      final router = GoRouter.of(context);
      final location = router.routeInformationProvider.value.uri.path;
      return location == '/chat/$conversationId';
    } catch (_) {
      return false;
    }
  }

  /// Handle notification tap — navigate to the relevant screen via GoRouter.
  static void _handleNotificationTap(Map<String, dynamic> data) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('Cannot handle notification tap — no navigator context');
      return;
    }

    final type = data['type'] as String?;
    debugPrint('Notification tapped: type=$type, data=$data');

    switch (type) {
      case 'new_match' || 'match_response':
        final matchId = data['match_id'] as String?;
        if (matchId != null) {
          context.push(AppRoutes.matchDetail(matchId));
        }

      case 'new_message':
        final conversationId = data['conversation_id'] as String?;
        if (conversationId != null) {
          context.push(AppRoutes.chatRoom(conversationId));
        }

      case 'verification_result':
        context.push(AppRoutes.verification);

      case 'system':
        // System notifications go to home
        context.go(AppRoutes.home);

      default:
        debugPrint('Unknown notification type: $type');
    }
  }
}
