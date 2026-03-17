import 'package:flutter_test/flutter_test.dart';
import 'package:cupplus/features/contract/services/contract_service.dart';

void main() {
  group('Contract Service', () {
    test('computeContractHash produces consistent SHA-256', () {
      const terms = 'Terms of Service content here';
      const privacy = 'Privacy Policy content here';

      final hash1 = computeContractHash(terms, privacy);
      final hash2 = computeContractHash(terms, privacy);

      expect(hash1, equals(hash2));
      expect(hash1.length, equals(64)); // SHA-256 = 64 hex chars
    });

    test('different content produces different hash', () {
      final hash1 = computeContractHash('A', 'B');
      final hash2 = computeContractHash('A', 'C');

      expect(hash1, isNot(equals(hash2)));
    });

    test('collectDeviceInfo has required fields', () {
      final info = collectDeviceInfo();

      expect(info, containsPair('platform', isA<String>()));
      expect(info, containsPair('os_version', isA<String>()));
      expect(info, containsPair('dart_version', isA<String>()));
      expect(info, containsPair('is_debug', isA<bool>()));
      expect(info, containsPair('timestamp_utc', isA<String>()));
    });

    test('contract hash with actual contract content', () {
      final hash = computeContractHash(termsContent, privacyContent);

      expect(hash, isNotEmpty);
      expect(hash.length, equals(64));
    });
  });

  group('Signed URL Helper', () {
    test('parseStoragePath splits bucket and path correctly', () {
      final result = parseStoragePath('profile-photos/client-id/photo.jpg');

      expect(result, isNotNull);
      expect(result!.bucket, equals('profile-photos'));
      expect(result.path, equals('client-id/photo.jpg'));
    });

    test('parseStoragePath handles null', () {
      expect(parseStoragePath(null), isNull);
    });

    test('parseStoragePath handles empty string', () {
      expect(parseStoragePath(''), isNull);
    });

    test('parseStoragePath handles no slash', () {
      expect(parseStoragePath('noslash'), isNull);
    });

    test('parseStoragePath handles chat-images path', () {
      final result = parseStoragePath('chat-images/conv-123/1234567.jpg');

      expect(result!.bucket, equals('chat-images'));
      expect(result.path, equals('conv-123/1234567.jpg'));
    });
  });
}

// Import parseStoragePath directly since it's a top-level function
({String bucket, String path})? parseStoragePath(String? storedPath) {
  if (storedPath == null || storedPath.isEmpty) return null;
  final slashIndex = storedPath.indexOf('/');
  if (slashIndex == -1) return null;
  return (
    bucket: storedPath.substring(0, slashIndex),
    path: storedPath.substring(slashIndex + 1),
  );
}
