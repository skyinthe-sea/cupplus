import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';

part 'nickname_provider.g.dart';

@riverpod
Future<bool> checkNicknameAvailable(Ref ref, String nickname) async {
  if (nickname.isEmpty) return false;
  final client = ref.watch(supabaseClientProvider);
  final result = await client.rpc(
    'check_nickname_available',
    params: {'p_nickname': nickname},
  );
  return result as bool;
}

@riverpod
class NicknameNotifier extends _$NicknameNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> updateNickname(String nickname) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      await client.rpc('update_nickname', params: {'p_nickname': nickname});
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
