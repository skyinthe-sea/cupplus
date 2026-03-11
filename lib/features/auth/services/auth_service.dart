import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../../../shared/utils/logger.dart';

part 'auth_service.g.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      clientId: Platform.isIOS ? dotenv.env['GOOGLE_IOS_CLIENT_ID'] : null,
    );
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google sign-in was cancelled');
    }
    final googleAuth = await googleUser.authentication;
    if (googleAuth.idToken == null) {
      throw const AuthException('Failed to get Google ID token');
    }
    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }

  Future<AuthResponse> signInWithKakao() async {
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        AppLogger.debug('Kakao: using KakaoTalk login', 'Auth');
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        AppLogger.debug('Kakao: using KakaoAccount login (web)', 'Auth');
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      AppLogger.debug('Kakao: got token, idToken=${token.idToken != null}', 'Auth');
      if (token.idToken == null) {
        throw const AuthException(
          'Failed to get Kakao ID token. Ensure OpenID Connect is enabled.',
        );
      }
      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.kakao,
        idToken: token.idToken!,
        accessToken: token.accessToken,
      );
    } catch (e, st) {
      AppLogger.error('Kakao sign-in failed: $e', e, st);
      rethrow;
    }
  }

  Future<AuthResponse> devSignIn() async {
    const email = 'admin@test.com';
    const password = 'testtest';
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException {
      // First run — user doesn't exist yet, create it
      return await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': '테스트 관리자'},
      );
    }
  }

  Future<List<UserIdentity>> getLinkedIdentities() async {
    return await _client.auth.getUserIdentities();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
}
