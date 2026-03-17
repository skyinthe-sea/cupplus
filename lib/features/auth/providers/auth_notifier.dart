import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';
import '../services/auth_service.dart';
import 'last_login_provider.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Refresh JWT once after login so handle_new_user trigger's
  /// app_metadata changes (e.g. region_id) are picked up.
  Future<void> _refreshJwt() async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.refreshSession();
    } catch (_) {}
  }

  Future<void> signInWithKakao() async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() => service.signInWithKakao());
    if (state is AsyncData) {
      await _refreshJwt();
      ref.read(lastLoginNotifierProvider.notifier).save('kakao');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() => service.signInWithGoogle());
    if (state is AsyncData) {
      await _refreshJwt();
      ref.read(lastLoginNotifierProvider.notifier).save('google');
    }
  }

  Future<void> devSignIn([String email = 'admin@test.com']) async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() => service.devSignIn(email));
    if (state is AsyncData) {
      await _refreshJwt();
      ref.read(lastLoginNotifierProvider.notifier).save('email');
    }
  }
}
