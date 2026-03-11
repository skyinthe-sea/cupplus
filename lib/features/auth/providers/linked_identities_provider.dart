import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

part 'linked_identities_provider.g.dart';

@riverpod
Future<List<UserIdentity>> linkedIdentities(Ref ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getLinkedIdentities();
}
