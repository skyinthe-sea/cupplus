// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'cup+';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNext => 'Next';

  @override
  String get commonBack => 'Back';

  @override
  String get commonDone => 'Done';

  @override
  String get commonAll => 'All';

  @override
  String get commonFemale => 'Female';

  @override
  String get commonMale => 'Male';

  @override
  String get authLogin => 'Log In';

  @override
  String get authLogout => 'Log Out';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authForgotPassword => 'Forgot Password';

  @override
  String get authComingSoon => 'Coming Soon';

  @override
  String get authSubtitle => 'Platform for Professional Matchmakers';

  @override
  String get authLoginWithGoogle => 'Continue with Google';

  @override
  String get authLoginWithKakao => 'Continue with Kakao';

  @override
  String get authLoginWithEmail => 'Continue with Email';

  @override
  String get authGetStarted => 'Get Started';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authTermsNotice =>
      'By continuing, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get authOr => 'or';

  @override
  String get matchStatusPending => 'Pending';

  @override
  String get matchStatusAccepted => 'Accepted';

  @override
  String get matchStatusDeclined => 'Declined';

  @override
  String get matchStatusMeetingScheduled => 'Meeting Scheduled';

  @override
  String get matchStatusCompleted => 'Completed';

  @override
  String get matchCreate => 'Create Match';

  @override
  String get matchList => 'Match List';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit Profile';

  @override
  String get profileName => 'Name';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileBirthDate => 'Date of Birth';

  @override
  String get profileEducation => 'Education';

  @override
  String get profileOccupation => 'Occupation';

  @override
  String get profileCompany => 'Company';

  @override
  String get profileIncome => 'Annual Income';

  @override
  String get profileReligion => 'Religion';

  @override
  String get profileHeight => 'Height';

  @override
  String get chatTitle => 'Chat';

  @override
  String get chatSendMessage => 'Send Message';

  @override
  String get chatNoMessages => 'No messages';

  @override
  String get chatImageSent => 'Sent an image';

  @override
  String get chatListHeadline => 'Messages';

  @override
  String chatListUnreadCount(int count) {
    return '$count unread messages';
  }

  @override
  String get chatEmptyTitle => 'No conversations';

  @override
  String get chatEmptySubtitle => 'Start a conversation with another manager';

  @override
  String get chatInputPlaceholder => 'Type a message';

  @override
  String get chatOnline => 'Online';

  @override
  String get chatOffline => 'Offline';

  @override
  String get chatToday => 'Today';

  @override
  String get chatYesterday => 'Yesterday';

  @override
  String get chatImageMessage => 'Photo';

  @override
  String get chatFileMessage => 'File';

  @override
  String get chatJustNow => 'Just now';

  @override
  String chatMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String chatHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String chatDateFormat(int month, int day) {
    return '$month/$day';
  }

  @override
  String get contractTitle => 'Contract';

  @override
  String get contractAgree => 'I Agree';

  @override
  String get contractSign => 'Sign';

  @override
  String get contractVersion => 'Contract Version';

  @override
  String get subscriptionTitle => 'Subscription';

  @override
  String get subscriptionFree => 'Free';

  @override
  String get subscriptionStandard => 'Standard';

  @override
  String get subscriptionPremium => 'Premium';

  @override
  String subscriptionDailyLimit(int count) {
    return 'Daily match limit: $count';
  }

  @override
  String get notificationTitle => 'Notifications';

  @override
  String get notificationEmpty => 'No notifications';

  @override
  String get navHome => 'Home';

  @override
  String get navMatches => 'Matches';

  @override
  String get navChat => 'Chat';

  @override
  String get navMy => 'My';

  @override
  String get homeTitle => 'Home Screen';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String homeRecommendedCount(int count) {
    return '$count recommended profiles for you today.';
  }

  @override
  String get homeRecommendedTitle => 'Recommended';

  @override
  String get homeStatusTitle => 'Activity';

  @override
  String get homePendingMatches => 'Pending Matches';

  @override
  String get homeTodayMatches => 'Today\'s Matches';

  @override
  String get homePendingVerifications => 'Pending Review';

  @override
  String get homeNewMessages => 'New Messages';

  @override
  String get homeVerified => 'Verified';

  @override
  String get homeGenderMale => 'M';

  @override
  String get homeGenderFemale => 'F';

  @override
  String get homeTipTitle => 'Matching Tip';

  @override
  String homeAgeSuffix(int age) {
    return 'Age $age';
  }

  @override
  String homeHeightCm(int height) {
    return '${height}cm';
  }

  @override
  String get matchesTitle => 'Matches';

  @override
  String get matchesTabPending => 'Pending';

  @override
  String get matchesTabActive => 'Active';

  @override
  String get matchesTabDone => 'Done';

  @override
  String matchesTotalCount(int count) {
    return '$count matches total';
  }

  @override
  String matchesMatchedAt(String date) {
    return '$date';
  }

  @override
  String get matchesNotesPreview => 'Notes';

  @override
  String get matchesEmptyPendingTitle => 'No pending matches';

  @override
  String get matchesEmptyPendingSubtitle => 'Create a new match to get started';

  @override
  String get matchesEmptyActiveTitle => 'No active matches';

  @override
  String get matchesEmptyActiveSubtitle => 'Accepted matches will appear here';

  @override
  String get matchesEmptyDoneTitle => 'No completed matches';

  @override
  String get matchesEmptyDoneSubtitle =>
      'Completed or declined matches will appear here';

  @override
  String get chatListTitle => 'Messages';

  @override
  String get myTitle => 'My Screen';

  @override
  String get authRequiredTitle => 'Login Required';

  @override
  String get authRequiredMessage => 'Please log in to use this feature.';

  @override
  String get authRequiredLogin => 'Log In';

  @override
  String get errorNotFound => 'Page not found';

  @override
  String get errorGoHome => 'Go Home';

  @override
  String get mySettingsTitle => 'Settings';

  @override
  String get mySettingsLanguage => 'Language';

  @override
  String get mySettingsLanguageKo => '한국어';

  @override
  String get mySettingsLanguageEn => 'English';

  @override
  String get mySettingsDarkMode => 'Dark Mode';

  @override
  String get myGeneralTitle => 'General';

  @override
  String get myMatchHistory => 'Match History';

  @override
  String get mySubscriptionManage => 'Subscription';

  @override
  String get myNotificationSettings => 'Notification Settings';

  @override
  String get myCustomerSupport => 'Customer Support';

  @override
  String get myLogoutConfirmTitle => 'Log Out';

  @override
  String get myLogoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get myProfileDetail => 'Profile Details';

  @override
  String myVersion(String version) {
    return 'Version $version';
  }

  @override
  String get nicknameEditTitle => 'Change Nickname';

  @override
  String get nicknameHint => 'Enter nickname';

  @override
  String get nicknameRules => '2-20 chars, letters/numbers/Korean/underscores';

  @override
  String get nicknameAvailable => 'Available';

  @override
  String get nicknameUnavailable => 'Already taken';

  @override
  String get nicknameInvalid => 'Invalid format';

  @override
  String get nicknameConfirm => 'Confirm';

  @override
  String get nicknameEditSuccess => 'Nickname updated';

  @override
  String get nicknameSetHint => 'Set your nickname';

  @override
  String get authLoginError => 'Login failed';

  @override
  String get authDevLogin => 'Developer Login';

  @override
  String get myNickname => 'Nickname';

  @override
  String get myLinkedAccountsTitle => 'Linked Accounts';

  @override
  String get myLinkedAccountConnected => 'Connected';

  @override
  String get myLinkedAccountNotConnected => 'Not connected';

  @override
  String get authLastUsed => 'Last used';

  @override
  String get authDifferentProviderTitle => 'Different login method';

  @override
  String authDifferentProviderMessage(String provider) {
    return 'You previously signed in with $provider. Using a different method may create a separate account. Continue?';
  }

  @override
  String get marketplaceTitle => 'Profile Market';

  @override
  String marketplaceTotalCount(int count) {
    return '$count profiles';
  }

  @override
  String get marketplaceSearchHint => 'Search name, job, company, region';

  @override
  String get marketplaceEmptyTitle => 'No profiles found';

  @override
  String get marketplaceEmptySubtitle => 'Try adjusting your search criteria';

  @override
  String get marketplaceFilterTitle => 'Filters';

  @override
  String get marketplaceFilterClear => 'Clear';

  @override
  String get marketplaceFilterApply => 'Apply';

  @override
  String marketplaceFilterAge(int min, int max) {
    return 'Age ($min ~ $max)';
  }

  @override
  String marketplaceFilterHeight(int min, int max) {
    return 'Height (${min}cm ~ ${max}cm)';
  }

  @override
  String get marketplaceFilterVerifiedOnly => 'Verified profiles only';

  @override
  String get profileDetailInfoTitle => 'Basic Info';

  @override
  String get profileDetailHobbies => 'Hobbies & Interests';

  @override
  String get profileDetailBio => 'About Me';

  @override
  String get profileDetailIdealPartner => 'Ideal Partner';

  @override
  String get profileDetailVerification => 'Verified Documents';

  @override
  String get profileDetailMatchRequests => 'Match Requests';

  @override
  String get profileDetailMatchRequestUnit => '';

  @override
  String get profileDetailRequestMatch => 'Request Match';

  @override
  String get profileDetailMatchRequestTitle => 'Match Request';

  @override
  String profileDetailMatchRequestMessage(String name) {
    return 'Request a match with $name?';
  }

  @override
  String get profileDetailMatchRequestSent => 'Match request sent successfully';
}
