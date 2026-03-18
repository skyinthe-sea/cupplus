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

  // Subscription limits — daily match requests
  static const int freeMatchDailyLimit = 3;
  static const int silverMatchDailyLimit = 30;
  static const int goldMatchDailyLimit = 60;

  // Subscription limits — max active clients per manager
  static const int freeClientLimit = 3;
  static const int silverClientLimit = 5;
  static const int goldClientLimit = 10;

  // Daily reset time (00:00 KST midnight)
  static const int dailyResetHour = 0;
  static const int dailyResetMinute = 0;

  // Storage paths
  static const String verificationDocsBucket = 'verification-documents';
  static const String chatImagesBucket = 'chat-images';
  static const String profilePhotosBucket = 'profile-photos';

  // Signed URL expiry (seconds)
  static const int signedUrlExpiry = 3600;

  // Chat pagination
  static const int chatPageSize = 30;
}
