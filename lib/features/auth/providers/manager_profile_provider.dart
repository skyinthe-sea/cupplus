import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';

part 'manager_profile_provider.g.dart';

@riverpod
Future<Map<String, dynamic>?> managerProfile(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return null;

  final result = await client
      .from('managers')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  return result;
}
