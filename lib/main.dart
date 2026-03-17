import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'app/app.dart';
import 'config/supabase_config.dart';
import 'features/notification/services/fcm_service.dart';
import 'firebase_options.dart';
import 'shared/utils/logger.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await initSupabase();
  } catch (e, st) {
    AppLogger.error('Failed to initialize Supabase', e, st);
  }

  // Firebase + FCM initialization
  // Gracefully fails if Firebase is not configured (flutterfire configure not run yet)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FcmService.initialize();
  } catch (e) {
    debugPrint('Firebase not configured — push notifications disabled');
    debugPrint('Run `flutterfire configure` to enable FCM');
    debugPrint('Error: $e');
  }

  final kakaoKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];
  if (kakaoKey != null && kakaoKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoKey);
  }

  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: CupPlusApp()));
}
