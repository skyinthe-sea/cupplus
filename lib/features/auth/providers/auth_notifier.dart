import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/auth_service.dart';
import 'last_login_provider.dart';

part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithKakao() async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() => service.signInWithKakao());
    if (state is AsyncData) {
      ref.read(lastLoginNotifierProvider.notifier).save('kakao');
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() => service.signInWithGoogle());
    if (state is AsyncData) {
      ref.read(lastLoginNotifierProvider.notifier).save('google');
    }
  }

  Future<void> devSignIn() async {
    state = const AsyncLoading();
    final service = ref.read(authServiceProvider);
    state = await AsyncValue.guard(() => service.devSignIn());
    if (state is AsyncData) {
      ref.read(lastLoginNotifierProvider.notifier).save('email');
    }
  }
}
