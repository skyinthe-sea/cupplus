import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/constants.dart';
import '../../config/supabase_config.dart';

part 'signed_url_helper.g.dart';

/// Generates a signed URL for a private storage bucket file.
/// Returns empty string on failure (renders placeholder instead of crashing).
///
/// Usage:
/// ```dart
/// final url = ref.watch(signedUrlProvider(
///   bucket: 'profile-photos',
///   path: 'client-id/photo_0.jpg',
/// ));
/// ```
@riverpod
Future<String> signedUrl(
  Ref ref, {
  required String bucket,
  required String path,
  int expirySeconds = AppConstants.signedUrlExpiry,
}) async {
  final client = ref.read(supabaseClientProvider);
  try {
    return await client.storage
        .from(bucket)
        .createSignedUrl(path, expirySeconds);
  } catch (_) {
    return '';
  }
}

/// Helper to extract storage path from a bucket-prefixed URL stored in DB.
/// e.g. 'profile-photos/client-id/photo.jpg' → bucket='profile-photos', path='client-id/photo.jpg'
({String bucket, String path})? parseStoragePath(String? storedPath) {
  if (storedPath == null || storedPath.isEmpty) return null;
  final slashIndex = storedPath.indexOf('/');
  if (slashIndex == -1) return null;
  return (
    bucket: storedPath.substring(0, slashIndex),
    path: storedPath.substring(slashIndex + 1),
  );
}
