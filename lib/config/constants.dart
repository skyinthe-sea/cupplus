import 'dart:ui';

abstract final class AppConstants {
  static const String appName = 'cup+';

  // Design reference size (iPhone base)
  static const Size designSize = Size(375, 812);

  // Breakpoints
  static const double tabletBreakpoint = 600;

  // Image compression
  static const int profilePhotoQuality = 80;
  static const int profilePhotoMaxDimension = 1024;
  static const int businessCardQuality = 85;
  static const int businessCardMaxWidth = 1920;
  static const int businessCardMaxHeight = 1080;
  static const int employmentCertQuality = 90;
  static const int employmentCertMaxDimension = 2048;

  // Subscription limits
  static const int freeMatchDailyLimit = 1;
  static const int standardMatchDailyLimit = 10;

  // Storage paths
  static const String verificationDocsBucket = 'verification-documents';
  static const String chatImagesBucket = 'chat-images';
  static const String profilePhotosBucket = 'profile-photos';

  // Signed URL expiry (seconds)
  static const int signedUrlExpiry = 3600;

  // Chat pagination
  static const int chatPageSize = 30;
}
