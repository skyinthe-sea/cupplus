import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';

part 'client_tags_provider.g.dart';

/// Preset tags with colors
const kPresetTags = <String, String>{
  'VIP': '#D4A017',
  '급한': '#E53935',
  '신규': '#43A047',
  '장기': '#1E88E5',
  '재상담': '#8E24AA',
  '적극적': '#FB8C00',
  '소극적': '#78909C',
  '까다로움': '#C62828',
};

/// Tags for a specific client
@riverpod
Future<List<Map<String, dynamic>>> clientTags(Ref ref, String clientId) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  try {
    final result = await client
        .from('client_tags')
        .select()
        .eq('client_id', clientId)
        .eq('manager_id', user.id)
        .order('created_at');
    return result;
  } catch (e) {
    debugPrint('Failed to fetch client tags: $e');
    return [];
  }
}

/// All unique tags used by this manager (for filtering)
@riverpod
Future<List<String>> allMyTags(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  try {
    final result = await client
        .from('client_tags')
        .select('tag')
        .eq('manager_id', user.id);

    final tags = result
        .map((r) => r['tag'] as String)
        .toSet()
        .toList()
      ..sort();
    return tags;
  } catch (e) {
    debugPrint('Failed to fetch all tags: $e');
    return [];
  }
}

/// Add a tag to a client
@riverpod
Future<void> addClientTag(
  Ref ref, {
  required String clientId,
  required String tag,
  String? color,
}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  final tagColor = color ?? kPresetTags[tag] ?? '#2D5A8E';

  await client.from('client_tags').upsert({
    'client_id': clientId,
    'manager_id': user.id,
    'tag': tag,
    'color': tagColor,
  });

  ref.invalidate(clientTagsProvider(clientId));
  ref.invalidate(allMyTagsProvider);
}

/// Remove a tag from a client
@riverpod
Future<void> removeClientTag(
  Ref ref, {
  required String tagId,
  required String clientId,
}) async {
  final client = ref.read(supabaseClientProvider);

  await client.from('client_tags').delete().eq('id', tagId);

  ref.invalidate(clientTagsProvider(clientId));
  ref.invalidate(allMyTagsProvider);
}
