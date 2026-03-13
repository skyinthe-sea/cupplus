import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/supabase_config.dart';
import '../../auth/providers/manager_profile_provider.dart';
import '../models/client_note.dart';

part 'client_notes_provider.g.dart';

@riverpod
Future<List<ClientNote>> clientNotes(Ref ref, String clientId) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final result = await client
      .from('client_notes')
      .select()
      .eq('client_id', clientId)
      .eq('manager_id', user.id)
      .order('created_at', ascending: false);

  return result.map((row) => ClientNote.fromMap(row)).toList();
}

@riverpod
Future<void> addClientNote(
  Ref ref, {
  required String clientId,
  required String noteType,
  required String content,
  DateTime? scheduledAt,
}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return;

  final managerProfile = ref.read(managerProfileProvider).valueOrNull;
  final regionId = managerProfile?['region_id'] as String? ?? 'default';

  await client.from('client_notes').insert({
    'client_id': clientId,
    'manager_id': user.id,
    'region_id': regionId,
    'note_type': noteType,
    'content': content,
    if (scheduledAt != null)
      'scheduled_at': scheduledAt.toIso8601String(),
  });

  ref.invalidate(clientNotesProvider(clientId));
  ref.invalidate(upcomingSchedulesProvider);
}

@riverpod
Future<void> toggleNoteCompleted(
  Ref ref,
  String noteId,
  String clientId, {
  required bool isCompleted,
}) async {
  final client = ref.read(supabaseClientProvider);

  await client.from('client_notes').update({
    'is_completed': isCompleted,
    'updated_at': DateTime.now().toIso8601String(),
  }).eq('id', noteId);

  ref.invalidate(clientNotesProvider(clientId));
  ref.invalidate(upcomingSchedulesProvider);
}

@riverpod
Future<void> deleteClientNote(Ref ref, String noteId, String clientId) async {
  final client = ref.read(supabaseClientProvider);

  await client.from('client_notes').delete().eq('id', noteId);

  ref.invalidate(clientNotesProvider(clientId));
  ref.invalidate(upcomingSchedulesProvider);
}

@riverpod
Future<List<ClientNote>> upcomingSchedules(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final result = await client
      .from('client_notes')
      .select('*, clients!inner(full_name)')
      .eq('manager_id', user.id)
      .eq('note_type', 'schedule')
      .eq('is_completed', false)
      .gte('scheduled_at', DateTime.now().toIso8601String())
      .order('scheduled_at', ascending: true)
      .limit(10);

  return result.map((row) => ClientNote.fromMap(row)).toList();
}
