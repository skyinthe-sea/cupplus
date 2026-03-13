import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../../../config/constants.dart';
import '../../../config/supabase_config.dart';

part 'verification_provider.g.dart';

/// Manager's verification status from managers table
@riverpod
Future<String> managerVerificationStatus(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return 'unverified';

  final result = await client
      .from('managers')
      .select('verification_status')
      .eq('id', user.id)
      .maybeSingle();

  return result?['verification_status'] as String? ?? 'unverified';
}

/// List of submitted verification documents
@riverpod
Future<List<Map<String, dynamic>>> myVerificationDocuments(Ref ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final result = await client
      .from('manager_verification_documents')
      .select()
      .eq('manager_id', user.id)
      .order('uploaded_at', ascending: false);

  return result;
}

/// Upload a verification document and update manager status to 'pending'
@riverpod
Future<void> submitVerificationDocument(
  Ref ref, {
  required String documentType,
  required XFile imageFile,
}) async {
  final client = ref.read(supabaseClientProvider);
  final user = client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');

  final bytes = await imageFile.readAsBytes();

  final ext = imageFile.name.split('.').last;
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
  final storagePath = '${user.id}/$documentType/$fileName';

  // Upload to storage
  await client.storage
      .from(AppConstants.verificationDocsBucket)
      .uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

  // Insert document record
  await client.from('manager_verification_documents').insert({
    'manager_id': user.id,
    'document_type': documentType,
    'storage_path': storagePath,
    'status': 'pending',
  });

  // Update manager verification status to 'pending'
  await client
      .from('managers')
      .update({'verification_status': 'pending'})
      .eq('id', user.id);

  // Invalidate cached data
  ref.invalidate(managerVerificationStatusProvider);
  ref.invalidate(myVerificationDocumentsProvider);
}
