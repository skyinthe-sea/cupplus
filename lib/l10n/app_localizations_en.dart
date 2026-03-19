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
  String get matchStatusCancelled => 'Cancelled';

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
  String get chatEmptySubtitle =>
      'No chats yet.\nA chat room will be created automatically when a match is accepted.';

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
  String chatDaysAgo(int days) {
    return '${days}d ago';
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
  String get subscriptionSilver => 'Silver';

  @override
  String get subscriptionGold => 'Gold';

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

  @override
  String homeGreetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String homeGreetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String homeGreetingNight(String name) {
    return 'Working late, $name?';
  }

  @override
  String get homeQuickRegister => 'Register Client';

  @override
  String get homeQuickMatch => 'Create Match';

  @override
  String get homeTodayTasks => 'Today\'s Tasks';

  @override
  String homeTodayPendingMatches(int count) {
    return '$count pending matches';
  }

  @override
  String homeTodayNewMessages(int count) {
    return '$count new messages';
  }

  @override
  String get homeTodayView => 'View';

  @override
  String get homeRecentActivity => 'Recent Activity';

  @override
  String homeActivityMatchRequested(String clientA, String clientB) {
    return '$clientA ↔ $clientB match requested';
  }

  @override
  String homeActivityMatchReceived(String clientA, String clientB) {
    return '$clientA ↔ $clientB match request received';
  }

  @override
  String homeActivityMatchAccepted(String clientA, String clientB) {
    return '$clientA ↔ $clientB match established';
  }

  @override
  String homeActivityMatchDeclined(String clientA, String clientB) {
    return '$clientA ↔ $clientB match declined';
  }

  @override
  String homeActivityMatchCancelled(String clientA, String clientB) {
    return '$clientA ↔ $clientB match cancelled';
  }

  @override
  String homeActivityClientRegistered(String name) {
    return '$name registered';
  }

  @override
  String get homeActivityEmpty => 'No activity yet';

  @override
  String get homeActivityEmptyAction => 'Register your first client!';

  @override
  String get homeActivityToday => 'Today';

  @override
  String get homeActivityYesterday => 'Yesterday';

  @override
  String get homeNotificationMarkAllRead => 'Mark all read';

  @override
  String get homeClientRegTitle => 'Quick Registration';

  @override
  String get homeClientRegNameRequired => 'Name is required';

  @override
  String get homeClientRegSuccess => 'Client registered successfully';

  @override
  String get homeMatchCreateTitle => 'Today\'s Picks';

  @override
  String get homeMatchCreateEmpty => 'No profiles to recommend';

  @override
  String get homeMatchMgmtTitle => 'Match Management';

  @override
  String get homeMatchAccept => 'Accept';

  @override
  String get homeMatchDecline => 'Decline';

  @override
  String get homeMatchMemo => 'Note';

  @override
  String get homeMatchDeclineReason => 'Reason (optional)';

  @override
  String get homeMatchAcceptSuccess => 'Match accepted';

  @override
  String get homeMatchDeclineSuccess => 'Match declined';

  @override
  String get homeMatchCancel => 'Cancel Request';

  @override
  String get homeMatchCancelConfirm => 'Cancel this match request?';

  @override
  String get homeMatchCancelSuccess => 'Match request cancelled';

  @override
  String get homeMatchMemoHint => 'Enter a note';

  @override
  String get homeMatchMemoSaved => 'Note saved';

  @override
  String get matchCardSent => 'Sent';

  @override
  String get matchCardReceived => 'Received';

  @override
  String get matchCardMyClient => 'My Client';

  @override
  String get matchCardOtherClient => 'Other Client';

  @override
  String get marketplaceLikesTab => 'Likes';

  @override
  String get marketplaceSortNewest => 'Newest';

  @override
  String get marketplaceSortMostLikes => 'Most Liked';

  @override
  String get marketplaceSortRecommended => 'Recommended';

  @override
  String get marketplaceFilterEducation => 'Education';

  @override
  String get marketplaceFilterOccupation => 'Occupation';

  @override
  String get marketplaceFilterIncome => 'Income Range';

  @override
  String get marketplaceMatchCompleted => 'Match Completed';

  @override
  String get matchRequestVerificationPending =>
      'We\'re reviewing your documents.\nYou\'ll be able to request matches once approved.\nPlease wait!';

  @override
  String get matchRequestVerificationPendingTitle => 'Verification in Review';

  @override
  String get matchRequestVerificationRequired => 'Verification Required';

  @override
  String get matchRequestVerificationRequiredDesc =>
      'Please submit documents proving your marriage agency affiliation to request matches.';

  @override
  String get matchRequestVerify => 'Verify';

  @override
  String get matchRequestSelectClient => 'Select a client for matching';

  @override
  String get matchRequestNoEligible =>
      'No eligible opposite-gender clients available';

  @override
  String matchRequestConfirmMessage(String clientA, String clientB) {
    return 'Request a match between $clientA and $clientB?';
  }

  @override
  String get matchRequestSuccess => 'Match request sent successfully';

  @override
  String get matchRequestDailyLimit => 'You have exceeded today\'s match limit';

  @override
  String clientRegistrationLimitExceeded(int current, int limit) {
    return 'Client limit reached ($current/$limit). Please upgrade your plan.';
  }

  @override
  String get subscriptionDevModeTitle => 'Dev: Change Subscription Tier';

  @override
  String chatMatchContext(String clientA, String clientB) {
    return '$clientA ↔ $clientB Match';
  }

  @override
  String get chatImagePickerTitle => 'Send Image';

  @override
  String get chatImagePickerCamera => 'Camera';

  @override
  String get chatImagePickerGallery => 'Gallery';

  @override
  String get chatImageUploading => 'Uploading image...';

  @override
  String get chatMessageSendFailed => 'Failed to send message';

  @override
  String get regTitle => 'Register Client';

  @override
  String regStepOf(int current, int total) {
    return 'Step $current/$total';
  }

  @override
  String get regStep1Title => 'Basic Info';

  @override
  String get regStep2Title => 'Career / Education';

  @override
  String get regStep3Title => 'Appearance';

  @override
  String get regStep4Title => 'Personality / Hobbies';

  @override
  String get regStep5Title => 'Agreement';

  @override
  String get regPrevious => 'Previous';

  @override
  String get regComplete => 'Complete';

  @override
  String get regNameLabel => 'Name';

  @override
  String get regNameHint => 'Enter name';

  @override
  String get regNameValidation => 'Name must be 2-20 characters';

  @override
  String get regPhoneLabel => 'Phone';

  @override
  String get regPhoneHint => '010-0000-0000';

  @override
  String get regEmailLabel => 'Email';

  @override
  String get regEmailHint => 'Enter email';

  @override
  String get regEmailValidation => 'Invalid email format';

  @override
  String get regOccupationLabel => 'Occupation';

  @override
  String get regOccupationHint => 'Enter occupation';

  @override
  String get regOccupationRequired => 'Occupation is required';

  @override
  String get regCompanyLabel => 'Company';

  @override
  String get regCompanyHint => 'Enter company';

  @override
  String get regEducationLevel => 'Education Level';

  @override
  String get regEduHighSchool => 'High School';

  @override
  String get regEduAssociate => 'Associate';

  @override
  String get regEduBachelor => 'Bachelor';

  @override
  String get regEduMaster => 'Master';

  @override
  String get regEduDoctorate => 'Doctorate';

  @override
  String get regSchoolLabel => 'School';

  @override
  String get regSchoolHint => 'Enter school name';

  @override
  String get regMajorLabel => 'Major';

  @override
  String get regMajorHint => 'Enter major';

  @override
  String get regIncomeLabel => 'Annual Income';

  @override
  String get regIncome1 => 'Under 30M KRW';

  @override
  String get regIncome2 => '30M - 50M KRW';

  @override
  String get regIncome3 => '50M - 70M KRW';

  @override
  String get regIncome4 => '70M - 100M KRW';

  @override
  String get regIncome5 => '100M - 150M KRW';

  @override
  String get regIncome6 => 'Over 150M KRW';

  @override
  String get regHeightLabel => 'Height';

  @override
  String regHeightValue(int height) {
    return '$height cm';
  }

  @override
  String get regBodyTypeLabel => 'Body Type';

  @override
  String get regBodySlim => 'Slim';

  @override
  String get regBodySlightlySlim => 'Slightly Slim';

  @override
  String get regBodyAverage => 'Average';

  @override
  String get regBodySlightlyChubby => 'Slightly Chubby';

  @override
  String get regBodyChubby => 'Chubby';

  @override
  String get regPhotoLabel => 'Profile Photos (max 5)';

  @override
  String get regPhotoAdd => 'Add';

  @override
  String get regPhotoMain => 'Main';

  @override
  String get regPhotoHint => 'The first photo will be used as the main photo.';

  @override
  String get regPhotoMax => 'You can add up to 5 photos';

  @override
  String get regReligionLabel => 'Religion';

  @override
  String get regReligionNone => 'None';

  @override
  String get regReligionChristian => 'Christian';

  @override
  String get regReligionCatholic => 'Catholic';

  @override
  String get regReligionBuddhist => 'Buddhist';

  @override
  String get regReligionOther => 'Other';

  @override
  String get regHobbiesLabel => 'Hobbies (max 5)';

  @override
  String get regHobbiesMax => 'You can select up to 5 hobbies';

  @override
  String regHobbiesCount(int count) {
    return '$count/5';
  }

  @override
  String get regHobbiesCustom => '+ Custom';

  @override
  String get regHobbiesAdd => 'Add';

  @override
  String get regBioLabel => 'About';

  @override
  String get regBioHint =>
      'A positive person who enjoys reading at cafes on weekends...';

  @override
  String regBioCount(int count) {
    return '$count/300';
  }

  @override
  String get regAgreeAll => 'Agree to All';

  @override
  String get regAgreeAllRequired => 'Agree to All Required';

  @override
  String get regAgreeTerms => 'Terms of Service';

  @override
  String get regAgreePrivacy => 'Privacy Policy';

  @override
  String get regAgreeMarketing => 'Marketing Communications';

  @override
  String get regRequired => '(Required)';

  @override
  String get regOptional => '(Optional)';

  @override
  String get regView => 'View';

  @override
  String get regAgreeDesc => 'Please review and agree to the terms.';

  @override
  String get regSuccessTitle => 'Registration Complete!';

  @override
  String regSuccessMessage(String name) {
    return '$name has been registered';
  }

  @override
  String get regSuccessViewProfile => 'View Profile';

  @override
  String get regSuccessGoHome => 'Go Home';

  @override
  String get regExitTitle => 'Leave?';

  @override
  String get regExitMessage =>
      'You have unsaved information.\nIt will be saved as a draft.';

  @override
  String get regExitLeave => 'Leave';

  @override
  String get regDraftFound =>
      'You have a draft in progress.\nWould you like to continue?';

  @override
  String get regDraftContinue => 'Continue';

  @override
  String get regDraftNew => 'Start Fresh';

  @override
  String get myClientsTitle => 'My Clients';

  @override
  String get myClientsRegister => 'Register';

  @override
  String get myClientsSearchHint => 'Search by name';

  @override
  String get myClientsTabAll => 'All';

  @override
  String get myClientsTabActive => 'Active';

  @override
  String get myClientsTabPaused => 'Paused';

  @override
  String get myClientsTabMatched => 'Matched';

  @override
  String myClientsCount(int count) {
    return '$count';
  }

  @override
  String get myClientsEmpty => 'No clients registered';

  @override
  String get myClientsEmptyAction => 'Register your first client';

  @override
  String get myClientDetailTitle => 'Client Details';

  @override
  String get myClientDetailEdit => 'Edit';

  @override
  String get myClientDetailStatus => 'Status';

  @override
  String get myClientDetailStatusActive => 'Active';

  @override
  String get myClientDetailStatusPaused => 'Paused';

  @override
  String get myClientDetailStatusMatched => 'Matched';

  @override
  String get myClientDetailStatusWithdrawn => 'Withdrawn';

  @override
  String get myClientDetailMatchHistory => 'Match History';

  @override
  String get myClientDetailMatchEmpty => 'No match history';

  @override
  String get myClientDetailRegisteredAt => 'Registered';

  @override
  String get myClientDetailPhone => 'Phone';

  @override
  String get myClientDetailEmail => 'Email';

  @override
  String get myClientDetailEducationLevel => 'Education';

  @override
  String get myClientDetailSchool => 'School';

  @override
  String get myClientDetailMajor => 'Major';

  @override
  String get myClientDetailBodyType => 'Body Type';

  @override
  String get myClientEditTitle => 'Edit Client';

  @override
  String get myClientEditSaved => 'Changes saved successfully';

  @override
  String get myClientEditFailed => 'Failed to save changes';

  @override
  String get myClientStatusChange => 'Change Status';

  @override
  String myClientStatusChangeConfirm(String name, String status) {
    return 'Change $name\'s status to $status?';
  }

  @override
  String get myClientStatusChanged => 'Status updated';

  @override
  String get myClientDeleteTitle => 'Delete Client';

  @override
  String myClientDeleteMessage(String name) {
    return 'Delete $name?\nThis will cancel pending matches and remove the profile from the marketplace.';
  }

  @override
  String get myClientDeleteSuccess => 'Client deleted';

  @override
  String get myClientDeleteFailed => 'Failed to delete client';

  @override
  String get verificationTitle => 'Manager Verification';

  @override
  String get verificationDesc =>
      'Submit a document proving your affiliation with a matchmaking company.\nYou will be notified once reviewed.';

  @override
  String get verificationDocTypeTitle => 'Select Document Type';

  @override
  String get verificationBusinessCard => 'Business Card';

  @override
  String get verificationEmploymentCert => 'Employment Certificate';

  @override
  String get verificationBusinessReg => 'Business Registration';

  @override
  String get verificationAcceptedDocs => 'Accepted documents';

  @override
  String get verificationUpload => 'Upload Document';

  @override
  String get verificationUploadHint => 'Take a photo or select from gallery';

  @override
  String get verificationUploadSub => 'Camera or photo library';

  @override
  String get verificationChangeImage => 'Change';

  @override
  String get verificationCamera => 'Camera';

  @override
  String get verificationGallery => 'Gallery';

  @override
  String get verificationSubmit => 'Submit';

  @override
  String get verificationSubmitSuccess =>
      'Submitted! You will be notified after review.';

  @override
  String get verificationSubmitFailed => 'Submission failed';

  @override
  String get verificationUploading => 'Uploading...';

  @override
  String get verificationStatusUnverified => 'Unverified';

  @override
  String get verificationStatusPending => 'Pending Review';

  @override
  String get verificationStatusVerified => 'Verified';

  @override
  String get verificationStatusRejected => 'Rejected';

  @override
  String get verificationRejectedMessage =>
      'Verification was rejected. Please resubmit your document.';

  @override
  String verificationRejectedReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get verificationResubmit => 'Resubmit';

  @override
  String get verificationImageRequired => 'Please select a document image';

  @override
  String get contractEmptyTitle => 'No contract history';

  @override
  String get contractAgreedAt => 'Agreed at';

  @override
  String get contractHashLabel => 'Contract hash';

  @override
  String get contractMarketingConsent => 'Marketing consent';

  @override
  String get contractDeviceInfo => 'Device';

  @override
  String get contractHistory => 'Contract History';

  @override
  String get subscriptionCurrentPlan => 'Current Plan';

  @override
  String subscriptionDailyUsage(int used, int limit) {
    return '$used/$limit matches used today';
  }

  @override
  String get subscriptionChangePlan => 'Change Plan';

  @override
  String get subscriptionFeatureMatches => 'Daily Matches';

  @override
  String subscriptionFeatureMatchesValue(int count) {
    return '$count/day';
  }

  @override
  String get subscriptionClientLimit => 'Client Limit';

  @override
  String subscriptionClientLimitValue(int count) {
    return 'Up to $count';
  }

  @override
  String get subscriptionFreePlanDesc => 'Free Plan';

  @override
  String get subscriptionSilverPlanDesc => 'Silver Plan';

  @override
  String get subscriptionGoldPlanDesc => 'Gold Plan';

  @override
  String get subscriptionLaunchPrice => 'Launch Special';

  @override
  String get subscriptionOriginalPrice => 'Regular';

  @override
  String get subscriptionRestoreTitle => 'Restore Purchases';

  @override
  String get subscriptionRestoreSuccess => 'Purchases restored';

  @override
  String get subscriptionRestoreFailed => 'No purchases to restore';

  @override
  String get subscriptionNotConfigured =>
      'Subscription service is being set up';

  @override
  String get notificationSettingsTitle => 'Notification Settings';

  @override
  String get notificationSettingsDesc =>
      'Choose which notifications you\'d like to receive as push notifications. In-app notifications are always shown.';

  @override
  String get notificationSettingsMatch => 'Match Notifications';

  @override
  String get notificationSettingsMatchDesc =>
      'Match requests, accepts, and declines';

  @override
  String get notificationSettingsMessage => 'Chat Notifications';

  @override
  String get notificationSettingsMessageDesc => 'New message alerts';

  @override
  String get notificationSettingsVerification => 'Verification Notifications';

  @override
  String get notificationSettingsVerificationDesc =>
      'Manager verification approval/rejection';

  @override
  String get notificationSettingsSystem => 'System Notifications';

  @override
  String get notificationSettingsSystemDesc =>
      'Announcements, subscription expiry, etc.';

  @override
  String get notificationSettingsFcmNote =>
      'Push notifications will be activated after Firebase is configured. In-app notifications are always received.';

  @override
  String get notificationSettingsSaved => 'Notification settings saved';

  @override
  String get matchDetailTitle => 'Match Detail';

  @override
  String get matchDetailNotFound => 'Match not found';

  @override
  String get matchDetailClientA => 'Client A';

  @override
  String get matchDetailClientB => 'Client B';

  @override
  String get matchDetailCreatedBy => 'Created by';

  @override
  String get matchDetailCreatedAt => 'Created at';

  @override
  String get matchDetailRespondedAt => 'Responded at';

  @override
  String get matchDetailOpenChat => 'Open Chat';

  @override
  String get matchDetailAcceptConfirm =>
      'Accept this match request? A chat room will be created with the other manager.';

  @override
  String get matchDetailWaitingResponse =>
      'Waiting for the other manager\'s response';

  @override
  String get matchHistoryEmpty => 'No match history';

  @override
  String get regStep6Title => 'Family / Lifestyle';

  @override
  String get regMaritalHistoryLabel => 'Marital History';

  @override
  String get regMaritalFirst => 'First Marriage';

  @override
  String get regMaritalRemarriage => 'Remarriage';

  @override
  String get regMaritalDivorced => 'Divorced';

  @override
  String get regHasChildrenLabel => 'Has Children';

  @override
  String get regChildrenCountLabel => 'Number of Children';

  @override
  String get regFamilyDetailLabel => 'Family Detail';

  @override
  String get regFamilyDetailHint =>
      'e.g., Eldest son of 1 brother and 2 sisters';

  @override
  String get regParentsStatusLabel => 'Parents Status';

  @override
  String get regParentsBothAlive => 'Both Alive';

  @override
  String get regParentsFatherOnly => 'Father Only';

  @override
  String get regParentsMotherOnly => 'Mother Only';

  @override
  String get regParentsDeceased => 'Deceased';

  @override
  String get regDrinkingLabel => 'Drinking';

  @override
  String get regDrinkingNone => 'None';

  @override
  String get regDrinkingSocial => 'Social';

  @override
  String get regDrinkingRegular => 'Regular';

  @override
  String get regSmokingLabel => 'Smoking';

  @override
  String get regSmokingNone => 'None';

  @override
  String get regSmokingSometimes => 'Sometimes';

  @override
  String get regSmokingRegular => 'Regular';

  @override
  String get regAssetRangeLabel => 'Asset Range';

  @override
  String get regAssetRange1 => 'Under 100M KRW';

  @override
  String get regAssetRange2 => '100M - 300M KRW';

  @override
  String get regAssetRange3 => '300M - 500M KRW';

  @override
  String get regAssetRange4 => '500M - 1B KRW';

  @override
  String get regAssetRange5 => 'Over 1B KRW';

  @override
  String get regResidenceAreaLabel => 'Residence Area';

  @override
  String get regResidenceAreaHint => 'e.g., Gangnam, Seoul';

  @override
  String get regResidenceTypeLabel => 'Residence Type';

  @override
  String get regResidenceOwn => 'Own';

  @override
  String get regResidenceRentDeposit => 'Jeonse (Deposit Rent)';

  @override
  String get regResidenceRentMonthly => 'Monthly Rent';

  @override
  String get regResidenceWithParents => 'With Parents';

  @override
  String get regHealthNotesLabel => 'Health Notes';

  @override
  String get regHealthNotesHint => 'Enter any health-related notes';

  @override
  String get regPersonalityTypeLabel => 'Personality Type (MBTI etc)';

  @override
  String get regPersonalityTypeHint => 'e.g., ENFP';

  @override
  String get profileFamilyTitle => 'Family Info';

  @override
  String get profileLifestyleTitle => 'Lifestyle';

  @override
  String get profileIdealPartnerTitle => 'Ideal Partner';

  @override
  String get profileResidenceTitle => 'Assets / Residence';

  @override
  String get profilePersonalityTitle => 'Personality';

  @override
  String get profileMaritalHistory => 'Marital History';

  @override
  String get profileChildren => 'Children';

  @override
  String profileChildrenCount(int count) {
    return '$count';
  }

  @override
  String get profileFamilyDetail => 'Family';

  @override
  String get profileParentsStatus => 'Parents';

  @override
  String get profileDrinking => 'Drinking';

  @override
  String get profileSmoking => 'Smoking';

  @override
  String get profileHealthNotes => 'Health';

  @override
  String get profilePersonalityType => 'Personality';

  @override
  String get profileAssetRange => 'Assets';

  @override
  String get profileResidenceArea => 'Area';

  @override
  String get profileResidenceType => 'Residence';

  @override
  String get profileIdealAge => 'Preferred Age';

  @override
  String get profileIdealHeight => 'Preferred Height';

  @override
  String get profileIdealEducation => 'Preferred Education';

  @override
  String get profileIdealIncome => 'Preferred Income';

  @override
  String get profileIdealReligion => 'Preferred Religion';

  @override
  String get profileIdealNotes => 'Other Preferences';

  @override
  String profileIdealAgeRange(int min, int max) {
    return '$min ~ $max';
  }

  @override
  String profileIdealHeightRange(int min, int max) {
    return '$min ~ ${max}cm';
  }

  @override
  String get marketplaceFilterDrinking => 'Drinking';

  @override
  String get marketplaceFilterSmoking => 'Smoking';

  @override
  String get marketplaceFilterMaritalHistory => 'Marital History';

  @override
  String get marketplaceFilterResidenceArea => 'Residence Area';

  @override
  String get marketplaceFilterResidenceHint => 'Enter area name';

  @override
  String get crmNotesTitle => 'Notes & Timeline';

  @override
  String get crmNoteAdd => 'Add Note';

  @override
  String get crmNoteTypeGeneral => 'General';

  @override
  String get crmNoteTypePreference => 'Preference';

  @override
  String get crmNoteTypeMeetingFeedback => 'Meeting Feedback';

  @override
  String get crmNoteTypeSchedule => 'Schedule';

  @override
  String get crmNoteContentHint => 'Enter note content';

  @override
  String get crmNoteScheduleAt => 'Schedule Date';

  @override
  String get crmNoteSaved => 'Note saved';

  @override
  String get crmNoteDeleted => 'Note deleted';

  @override
  String get crmNoteDeleteConfirm => 'Delete this note?';

  @override
  String get crmNoteEmpty => 'No notes yet';

  @override
  String get crmNoteCompleted => 'Completed';

  @override
  String get crmScheduleTitle => 'Upcoming Schedules';

  @override
  String get crmScheduleEmpty => 'No upcoming schedules';

  @override
  String get crmTagsTitle => 'Tags';

  @override
  String get crmTagsEmpty => 'Add tags to categorize this client';

  @override
  String get crmTagsAdd => 'Add Tag';

  @override
  String get crmTagsAddButton => 'Add';

  @override
  String get crmTagsCustomHint => 'Enter custom tag';

  @override
  String get crmDashboardTitle => 'Client Analytics';

  @override
  String get crmThisMonth => 'This Month';

  @override
  String get crmNewRegistrations => 'New Clients';

  @override
  String get crmNewMatches => 'Match Requests';

  @override
  String get crmTotalNotes => 'Notes';

  @override
  String get crmClientOverview => 'Client Overview';

  @override
  String get crmTotalClients => 'clients';

  @override
  String get crmAvgAge => 'Avg Age';

  @override
  String get crmMatchPerformance => 'Match Performance';

  @override
  String get crmSuccessRate => 'Success Rate';

  @override
  String get crmDeclineRate => 'Decline Rate';

  @override
  String get crmPendingMatches => 'Pending';

  @override
  String get crmWaitingResponse => 'Awaiting response';

  @override
  String get crmTotalMatchesLabel => 'Total Matches';

  @override
  String get crmAllTime => 'All time';

  @override
  String get crmOtherStatus => 'Other';

  @override
  String get supportHeaderTitle => 'Need help?';

  @override
  String get supportHeaderSubtitle =>
      'Feel free to reach out\nwith any questions or issues.';

  @override
  String get supportEmailTitle => 'Email Support';

  @override
  String get supportEmailDesc =>
      'We respond within 24 hours on business days.\nPlease include your manager name and contact info.';

  @override
  String get supportEmailButton => 'Send Email';

  @override
  String get supportHoursTitle => 'Business Hours';

  @override
  String get supportHoursValue => 'Mon-Fri 10:00 AM - 6:00 PM (KST)';

  @override
  String supportEmailFallback(String email) {
    return 'No email app found. Please contact us directly: $email';
  }

  @override
  String get supportFaqTitle => 'FAQ';

  @override
  String get supportFaq1Q => 'How do I change or cancel my subscription?';

  @override
  String get supportFaq1A =>
      'Go to My > Subscription to change your plan. Cancellation is managed through the App Store or Google Play Store.';

  @override
  String get supportFaq2Q => 'How long does manager verification take?';

  @override
  String get supportFaq2A =>
      'Verification is typically completed within 1-2 business days after submission. You\'ll be notified via push notification.';

  @override
  String get supportFaq3Q => 'When does the daily match limit reset?';

  @override
  String get supportFaq3A =>
      'Daily limits reset automatically at midnight (00:00 KST).';

  @override
  String get supportFaq4Q => 'How do I delete a registered client?';

  @override
  String get supportFaq4A =>
      'Go to My > My Clients, select the client, and use the delete option. Pending matches will be cancelled.';

  @override
  String homeTodaySchedules(int count) {
    return '$count upcoming schedules';
  }

  @override
  String get customerSupportUrl => 'https://cupplus.channel.io';

  @override
  String regPhotoRemaining(int count) {
    return 'up to $count';
  }

  @override
  String get landingHeroTitle => 'Elevate\nYour Matchmaking';

  @override
  String get landingHeroSubtitle =>
      'All-in-one matching platform\nfor marriage agency managers';

  @override
  String get landingFeature1Title => 'Smart Matching';

  @override
  String get landingFeature1Desc =>
      'AI-powered recommendations based on member data';

  @override
  String get landingFeature2Title => 'Real-time Chat';

  @override
  String get landingFeature2Desc => 'Instant manager-to-manager communication';

  @override
  String get landingFeature3Title => 'Streamlined Management';

  @override
  String get landingFeature3Desc =>
      'From registration to contract, all in one place';

  @override
  String get landingCta => 'Get Started';

  @override
  String get landingLoginPrompt => 'Already have an account?';

  @override
  String get profileDetailMatchContext =>
      'This client is part of the match request';

  @override
  String get matchSheetVerificationRequired => 'Verification Required';

  @override
  String get matchSheetVerificationBody =>
      'Please complete manager verification before accepting or declining matches.';

  @override
  String get matchSheetGoVerify => 'Go to Verification';
}
