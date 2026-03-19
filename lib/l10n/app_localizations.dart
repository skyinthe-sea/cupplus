import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// 앱 이름
  ///
  /// In ko, this message translates to:
  /// **'cup+'**
  String get appName;

  /// No description provided for @commonCancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get commonConfirm;

  /// No description provided for @commonSave.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In ko, this message translates to:
  /// **'편집'**
  String get commonEdit;

  /// No description provided for @commonSearch.
  ///
  /// In ko, this message translates to:
  /// **'검색'**
  String get commonSearch;

  /// No description provided for @commonLoading.
  ///
  /// In ko, this message translates to:
  /// **'로딩 중...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In ko, this message translates to:
  /// **'오류가 발생했습니다'**
  String get commonError;

  /// No description provided for @commonRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get commonRetry;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @commonNext.
  ///
  /// In ko, this message translates to:
  /// **'다음'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In ko, this message translates to:
  /// **'뒤로'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get commonDone;

  /// No description provided for @commonAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get commonAll;

  /// No description provided for @commonFemale.
  ///
  /// In ko, this message translates to:
  /// **'여성'**
  String get commonFemale;

  /// No description provided for @commonMale.
  ///
  /// In ko, this message translates to:
  /// **'남성'**
  String get commonMale;

  /// No description provided for @authLogin.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get authLogin;

  /// No description provided for @authLogout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get authLogout;

  /// No description provided for @authSignUp.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get authSignUp;

  /// No description provided for @authEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get authPassword;

  /// No description provided for @authForgotPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 찾기'**
  String get authForgotPassword;

  /// No description provided for @authComingSoon.
  ///
  /// In ko, this message translates to:
  /// **'곧 제공됩니다'**
  String get authComingSoon;

  /// No description provided for @authSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭 전문가를 위한 플랫폼'**
  String get authSubtitle;

  /// No description provided for @authLoginWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get authLoginWithGoogle;

  /// No description provided for @authLoginWithKakao.
  ///
  /// In ko, this message translates to:
  /// **'카카오로 계속하기'**
  String get authLoginWithKakao;

  /// No description provided for @authLoginWithEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일로 계속하기'**
  String get authLoginWithEmail;

  /// No description provided for @authGetStarted.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get authGetStarted;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authTermsNotice.
  ///
  /// In ko, this message translates to:
  /// **'계속 진행하면 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.'**
  String get authTermsNotice;

  /// No description provided for @authOr.
  ///
  /// In ko, this message translates to:
  /// **'또는'**
  String get authOr;

  /// No description provided for @matchStatusPending.
  ///
  /// In ko, this message translates to:
  /// **'대기 중'**
  String get matchStatusPending;

  /// No description provided for @matchStatusAccepted.
  ///
  /// In ko, this message translates to:
  /// **'수락됨'**
  String get matchStatusAccepted;

  /// No description provided for @matchStatusDeclined.
  ///
  /// In ko, this message translates to:
  /// **'거절됨'**
  String get matchStatusDeclined;

  /// No description provided for @matchStatusMeetingScheduled.
  ///
  /// In ko, this message translates to:
  /// **'만남 예정'**
  String get matchStatusMeetingScheduled;

  /// No description provided for @matchStatusCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get matchStatusCompleted;

  /// No description provided for @matchStatusCancelled.
  ///
  /// In ko, this message translates to:
  /// **'취소됨'**
  String get matchStatusCancelled;

  /// No description provided for @matchCreate.
  ///
  /// In ko, this message translates to:
  /// **'매칭 생성'**
  String get matchCreate;

  /// No description provided for @matchList.
  ///
  /// In ko, this message translates to:
  /// **'매칭 목록'**
  String get matchList;

  /// No description provided for @profileTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In ko, this message translates to:
  /// **'프로필 편집'**
  String get profileEdit;

  /// No description provided for @profileName.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get profileName;

  /// No description provided for @profileGender.
  ///
  /// In ko, this message translates to:
  /// **'성별'**
  String get profileGender;

  /// No description provided for @profileBirthDate.
  ///
  /// In ko, this message translates to:
  /// **'생년월일'**
  String get profileBirthDate;

  /// No description provided for @profileEducation.
  ///
  /// In ko, this message translates to:
  /// **'학력'**
  String get profileEducation;

  /// No description provided for @profileOccupation.
  ///
  /// In ko, this message translates to:
  /// **'직업'**
  String get profileOccupation;

  /// No description provided for @profileCompany.
  ///
  /// In ko, this message translates to:
  /// **'회사'**
  String get profileCompany;

  /// No description provided for @profileIncome.
  ///
  /// In ko, this message translates to:
  /// **'연소득'**
  String get profileIncome;

  /// No description provided for @profileReligion.
  ///
  /// In ko, this message translates to:
  /// **'종교'**
  String get profileReligion;

  /// No description provided for @profileHeight.
  ///
  /// In ko, this message translates to:
  /// **'키'**
  String get profileHeight;

  /// No description provided for @chatTitle.
  ///
  /// In ko, this message translates to:
  /// **'채팅'**
  String get chatTitle;

  /// No description provided for @chatSendMessage.
  ///
  /// In ko, this message translates to:
  /// **'메시지 보내기'**
  String get chatSendMessage;

  /// No description provided for @chatNoMessages.
  ///
  /// In ko, this message translates to:
  /// **'메시지가 없습니다'**
  String get chatNoMessages;

  /// No description provided for @chatImageSent.
  ///
  /// In ko, this message translates to:
  /// **'이미지를 보냈습니다'**
  String get chatImageSent;

  /// No description provided for @chatListHeadline.
  ///
  /// In ko, this message translates to:
  /// **'대화함'**
  String get chatListHeadline;

  /// No description provided for @chatListUnreadCount.
  ///
  /// In ko, this message translates to:
  /// **'읽지 않은 메시지 {count}건'**
  String chatListUnreadCount(int count);

  /// No description provided for @chatEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화가 없습니다'**
  String get chatEmptyTitle;

  /// No description provided for @chatEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'아직 채팅이 없습니다.\n매칭이 성사되면 자동으로 채팅방이 생성됩니다.'**
  String get chatEmptySubtitle;

  /// No description provided for @chatInputPlaceholder.
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력하세요'**
  String get chatInputPlaceholder;

  /// No description provided for @chatOnline.
  ///
  /// In ko, this message translates to:
  /// **'온라인'**
  String get chatOnline;

  /// No description provided for @chatOffline.
  ///
  /// In ko, this message translates to:
  /// **'오프라인'**
  String get chatOffline;

  /// No description provided for @chatToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get chatToday;

  /// No description provided for @chatYesterday.
  ///
  /// In ko, this message translates to:
  /// **'어제'**
  String get chatYesterday;

  /// No description provided for @chatImageMessage.
  ///
  /// In ko, this message translates to:
  /// **'사진'**
  String get chatImageMessage;

  /// No description provided for @chatFileMessage.
  ///
  /// In ko, this message translates to:
  /// **'파일'**
  String get chatFileMessage;

  /// No description provided for @chatJustNow.
  ///
  /// In ko, this message translates to:
  /// **'방금'**
  String get chatJustNow;

  /// No description provided for @chatMinutesAgo.
  ///
  /// In ko, this message translates to:
  /// **'{minutes}분 전'**
  String chatMinutesAgo(int minutes);

  /// No description provided for @chatHoursAgo.
  ///
  /// In ko, this message translates to:
  /// **'{hours}시간 전'**
  String chatHoursAgo(int hours);

  /// No description provided for @chatDaysAgo.
  ///
  /// In ko, this message translates to:
  /// **'{days}일 전'**
  String chatDaysAgo(int days);

  /// No description provided for @chatDateFormat.
  ///
  /// In ko, this message translates to:
  /// **'{month}월 {day}일'**
  String chatDateFormat(int month, int day);

  /// No description provided for @contractTitle.
  ///
  /// In ko, this message translates to:
  /// **'계약'**
  String get contractTitle;

  /// No description provided for @contractAgree.
  ///
  /// In ko, this message translates to:
  /// **'동의합니다'**
  String get contractAgree;

  /// No description provided for @contractSign.
  ///
  /// In ko, this message translates to:
  /// **'서명하기'**
  String get contractSign;

  /// No description provided for @contractVersion.
  ///
  /// In ko, this message translates to:
  /// **'계약 버전'**
  String get contractVersion;

  /// No description provided for @subscriptionTitle.
  ///
  /// In ko, this message translates to:
  /// **'구독'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionFree.
  ///
  /// In ko, this message translates to:
  /// **'무료'**
  String get subscriptionFree;

  /// No description provided for @subscriptionSilver.
  ///
  /// In ko, this message translates to:
  /// **'실버'**
  String get subscriptionSilver;

  /// No description provided for @subscriptionGold.
  ///
  /// In ko, this message translates to:
  /// **'골드'**
  String get subscriptionGold;

  /// No description provided for @subscriptionDailyLimit.
  ///
  /// In ko, this message translates to:
  /// **'일일 매칭 제한: {count}건'**
  String subscriptionDailyLimit(int count);

  /// No description provided for @notificationTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림'**
  String get notificationTitle;

  /// No description provided for @notificationEmpty.
  ///
  /// In ko, this message translates to:
  /// **'알림이 없습니다'**
  String get notificationEmpty;

  /// No description provided for @navHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// No description provided for @navMatches.
  ///
  /// In ko, this message translates to:
  /// **'매칭'**
  String get navMatches;

  /// No description provided for @navChat.
  ///
  /// In ko, this message translates to:
  /// **'채팅'**
  String get navChat;

  /// No description provided for @navMy.
  ///
  /// In ko, this message translates to:
  /// **'마이'**
  String get navMy;

  /// No description provided for @homeTitle.
  ///
  /// In ko, this message translates to:
  /// **'홈 화면입니다'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In ko, this message translates to:
  /// **'안녕하세요, {name}님!'**
  String homeGreeting(String name);

  /// No description provided for @homeRecommendedCount.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {count}명의 추천 프로필이 있어요.'**
  String homeRecommendedCount(int count);

  /// No description provided for @homeRecommendedTitle.
  ///
  /// In ko, this message translates to:
  /// **'추천 프로필'**
  String get homeRecommendedTitle;

  /// No description provided for @homeStatusTitle.
  ///
  /// In ko, this message translates to:
  /// **'활동 현황'**
  String get homeStatusTitle;

  /// No description provided for @homePendingMatches.
  ///
  /// In ko, this message translates to:
  /// **'대기 중 매칭'**
  String get homePendingMatches;

  /// No description provided for @homeTodayMatches.
  ///
  /// In ko, this message translates to:
  /// **'오늘 매칭'**
  String get homeTodayMatches;

  /// No description provided for @homePendingVerifications.
  ///
  /// In ko, this message translates to:
  /// **'서류 대기'**
  String get homePendingVerifications;

  /// No description provided for @homeNewMessages.
  ///
  /// In ko, this message translates to:
  /// **'새 메시지'**
  String get homeNewMessages;

  /// No description provided for @homeVerified.
  ///
  /// In ko, this message translates to:
  /// **'인증됨'**
  String get homeVerified;

  /// No description provided for @homeGenderMale.
  ///
  /// In ko, this message translates to:
  /// **'남'**
  String get homeGenderMale;

  /// No description provided for @homeGenderFemale.
  ///
  /// In ko, this message translates to:
  /// **'여'**
  String get homeGenderFemale;

  /// No description provided for @homeTipTitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭 팁'**
  String get homeTipTitle;

  /// No description provided for @homeAgeSuffix.
  ///
  /// In ko, this message translates to:
  /// **'{age}세'**
  String homeAgeSuffix(int age);

  /// No description provided for @homeHeightCm.
  ///
  /// In ko, this message translates to:
  /// **'{height}cm'**
  String homeHeightCm(int height);

  /// No description provided for @matchesTitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭'**
  String get matchesTitle;

  /// No description provided for @matchesTabPending.
  ///
  /// In ko, this message translates to:
  /// **'대기 중'**
  String get matchesTabPending;

  /// No description provided for @matchesTabActive.
  ///
  /// In ko, this message translates to:
  /// **'진행 중'**
  String get matchesTabActive;

  /// No description provided for @matchesTabDone.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get matchesTabDone;

  /// No description provided for @matchesTotalCount.
  ///
  /// In ko, this message translates to:
  /// **'총 {count}건의 매칭'**
  String matchesTotalCount(int count);

  /// No description provided for @matchesMatchedAt.
  ///
  /// In ko, this message translates to:
  /// **'{date}'**
  String matchesMatchedAt(String date);

  /// No description provided for @matchesNotesPreview.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get matchesNotesPreview;

  /// No description provided for @matchesEmptyPendingTitle.
  ///
  /// In ko, this message translates to:
  /// **'대기 중인 매칭이 없습니다'**
  String get matchesEmptyPendingTitle;

  /// No description provided for @matchesEmptyPendingSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'새로운 매칭을 생성해보세요'**
  String get matchesEmptyPendingSubtitle;

  /// No description provided for @matchesEmptyActiveTitle.
  ///
  /// In ko, this message translates to:
  /// **'진행 중인 매칭이 없습니다'**
  String get matchesEmptyActiveTitle;

  /// No description provided for @matchesEmptyActiveSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'대기 중인 매칭이 수락되면 여기에 표시됩니다'**
  String get matchesEmptyActiveSubtitle;

  /// No description provided for @matchesEmptyDoneTitle.
  ///
  /// In ko, this message translates to:
  /// **'완료된 매칭이 없습니다'**
  String get matchesEmptyDoneTitle;

  /// No description provided for @matchesEmptyDoneSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭이 완료되거나 거절되면 여기에 표시됩니다'**
  String get matchesEmptyDoneSubtitle;

  /// No description provided for @chatListTitle.
  ///
  /// In ko, this message translates to:
  /// **'대화함'**
  String get chatListTitle;

  /// No description provided for @myTitle.
  ///
  /// In ko, this message translates to:
  /// **'마이 화면입니다'**
  String get myTitle;

  /// No description provided for @authRequiredTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요합니다'**
  String get authRequiredTitle;

  /// No description provided for @authRequiredMessage.
  ///
  /// In ko, this message translates to:
  /// **'이 기능을 사용하려면 로그인이 필요합니다.'**
  String get authRequiredMessage;

  /// No description provided for @authRequiredLogin.
  ///
  /// In ko, this message translates to:
  /// **'로그인하기'**
  String get authRequiredLogin;

  /// No description provided for @errorNotFound.
  ///
  /// In ko, this message translates to:
  /// **'페이지를 찾을 수 없습니다'**
  String get errorNotFound;

  /// No description provided for @errorGoHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로 이동'**
  String get errorGoHome;

  /// No description provided for @mySettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get mySettingsTitle;

  /// No description provided for @mySettingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get mySettingsLanguage;

  /// No description provided for @mySettingsLanguageKo.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get mySettingsLanguageKo;

  /// No description provided for @mySettingsLanguageEn.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get mySettingsLanguageEn;

  /// No description provided for @mySettingsDarkMode.
  ///
  /// In ko, this message translates to:
  /// **'다크 모드'**
  String get mySettingsDarkMode;

  /// No description provided for @myGeneralTitle.
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get myGeneralTitle;

  /// No description provided for @myMatchHistory.
  ///
  /// In ko, this message translates to:
  /// **'매칭 이력'**
  String get myMatchHistory;

  /// No description provided for @mySubscriptionManage.
  ///
  /// In ko, this message translates to:
  /// **'구독 관리'**
  String get mySubscriptionManage;

  /// No description provided for @myNotificationSettings.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get myNotificationSettings;

  /// No description provided for @myCustomerSupport.
  ///
  /// In ko, this message translates to:
  /// **'고객센터'**
  String get myCustomerSupport;

  /// No description provided for @myLogoutConfirmTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get myLogoutConfirmTitle;

  /// No description provided for @myLogoutConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃하시겠습니까?'**
  String get myLogoutConfirmMessage;

  /// No description provided for @myProfileDetail.
  ///
  /// In ko, this message translates to:
  /// **'프로필 상세'**
  String get myProfileDetail;

  /// No description provided for @myVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version}'**
  String myVersion(String version);

  /// No description provided for @nicknameEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'닉네임 변경'**
  String get nicknameEditTitle;

  /// No description provided for @nicknameHint.
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 입력하세요'**
  String get nicknameHint;

  /// No description provided for @nicknameRules.
  ///
  /// In ko, this message translates to:
  /// **'2-20자, 한글/영문/숫자/밑줄(_)'**
  String get nicknameRules;

  /// No description provided for @nicknameAvailable.
  ///
  /// In ko, this message translates to:
  /// **'사용 가능'**
  String get nicknameAvailable;

  /// No description provided for @nicknameUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'이미 사용 중'**
  String get nicknameUnavailable;

  /// No description provided for @nicknameInvalid.
  ///
  /// In ko, this message translates to:
  /// **'올바르지 않은 형식'**
  String get nicknameInvalid;

  /// No description provided for @nicknameConfirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get nicknameConfirm;

  /// No description provided for @nicknameEditSuccess.
  ///
  /// In ko, this message translates to:
  /// **'닉네임이 변경되었습니다'**
  String get nicknameEditSuccess;

  /// No description provided for @nicknameSetHint.
  ///
  /// In ko, this message translates to:
  /// **'닉네임을 설정해주세요'**
  String get nicknameSetHint;

  /// No description provided for @authLoginError.
  ///
  /// In ko, this message translates to:
  /// **'로그인에 실패했습니다'**
  String get authLoginError;

  /// No description provided for @authDevLogin.
  ///
  /// In ko, this message translates to:
  /// **'개발자 로그인'**
  String get authDevLogin;

  /// No description provided for @myNickname.
  ///
  /// In ko, this message translates to:
  /// **'닉네임'**
  String get myNickname;

  /// No description provided for @myLinkedAccountsTitle.
  ///
  /// In ko, this message translates to:
  /// **'연결된 계정'**
  String get myLinkedAccountsTitle;

  /// No description provided for @myLinkedAccountConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결됨'**
  String get myLinkedAccountConnected;

  /// No description provided for @myLinkedAccountNotConnected.
  ///
  /// In ko, this message translates to:
  /// **'미연결'**
  String get myLinkedAccountNotConnected;

  /// No description provided for @authLastUsed.
  ///
  /// In ko, this message translates to:
  /// **'최근 사용'**
  String get authLastUsed;

  /// No description provided for @authDifferentProviderTitle.
  ///
  /// In ko, this message translates to:
  /// **'다른 로그인 방법'**
  String get authDifferentProviderTitle;

  /// No description provided for @authDifferentProviderMessage.
  ///
  /// In ko, this message translates to:
  /// **'이전에 {provider}로 로그인하셨습니다. 다른 방법으로 로그인하면 별도의 계정이 생성될 수 있습니다. 계속하시겠습니까?'**
  String authDifferentProviderMessage(String provider);

  /// No description provided for @marketplaceTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필 마켓'**
  String get marketplaceTitle;

  /// No description provided for @marketplaceTotalCount.
  ///
  /// In ko, this message translates to:
  /// **'총 {count}명의 프로필'**
  String marketplaceTotalCount(int count);

  /// No description provided for @marketplaceSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'이름, 직업, 회사, 지역 검색'**
  String get marketplaceSearchHint;

  /// No description provided for @marketplaceEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'프로필이 없습니다'**
  String get marketplaceEmptyTitle;

  /// No description provided for @marketplaceEmptySubtitle.
  ///
  /// In ko, this message translates to:
  /// **'검색 조건을 변경해보세요'**
  String get marketplaceEmptySubtitle;

  /// No description provided for @marketplaceFilterTitle.
  ///
  /// In ko, this message translates to:
  /// **'필터'**
  String get marketplaceFilterTitle;

  /// No description provided for @marketplaceFilterClear.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get marketplaceFilterClear;

  /// No description provided for @marketplaceFilterApply.
  ///
  /// In ko, this message translates to:
  /// **'적용하기'**
  String get marketplaceFilterApply;

  /// No description provided for @marketplaceFilterAge.
  ///
  /// In ko, this message translates to:
  /// **'나이 ({min}세 ~ {max}세)'**
  String marketplaceFilterAge(int min, int max);

  /// No description provided for @marketplaceFilterHeight.
  ///
  /// In ko, this message translates to:
  /// **'키 ({min}cm ~ {max}cm)'**
  String marketplaceFilterHeight(int min, int max);

  /// No description provided for @marketplaceFilterVerifiedOnly.
  ///
  /// In ko, this message translates to:
  /// **'인증된 프로필만'**
  String get marketplaceFilterVerifiedOnly;

  /// No description provided for @profileDetailInfoTitle.
  ///
  /// In ko, this message translates to:
  /// **'기본 정보'**
  String get profileDetailInfoTitle;

  /// No description provided for @profileDetailHobbies.
  ///
  /// In ko, this message translates to:
  /// **'취미/관심사'**
  String get profileDetailHobbies;

  /// No description provided for @profileDetailBio.
  ///
  /// In ko, this message translates to:
  /// **'자기소개'**
  String get profileDetailBio;

  /// No description provided for @profileDetailIdealPartner.
  ///
  /// In ko, this message translates to:
  /// **'이상형'**
  String get profileDetailIdealPartner;

  /// No description provided for @profileDetailVerification.
  ///
  /// In ko, this message translates to:
  /// **'인증 서류'**
  String get profileDetailVerification;

  /// No description provided for @profileDetailMatchRequests.
  ///
  /// In ko, this message translates to:
  /// **'매칭 신청'**
  String get profileDetailMatchRequests;

  /// No description provided for @profileDetailMatchRequestUnit.
  ///
  /// In ko, this message translates to:
  /// **'건'**
  String get profileDetailMatchRequestUnit;

  /// No description provided for @profileDetailRequestMatch.
  ///
  /// In ko, this message translates to:
  /// **'매칭 신청하기'**
  String get profileDetailRequestMatch;

  /// No description provided for @profileDetailMatchRequestTitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭 신청'**
  String get profileDetailMatchRequestTitle;

  /// No description provided for @profileDetailMatchRequestMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}님에게 매칭을 신청하시겠습니까?'**
  String profileDetailMatchRequestMessage(String name);

  /// No description provided for @profileDetailMatchRequestSent.
  ///
  /// In ko, this message translates to:
  /// **'매칭 신청이 완료되었습니다'**
  String get profileDetailMatchRequestSent;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In ko, this message translates to:
  /// **'좋은 아침이에요, {name}님'**
  String homeGreetingMorning(String name);

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In ko, this message translates to:
  /// **'좋은 오후예요, {name}님'**
  String homeGreetingAfternoon(String name);

  /// No description provided for @homeGreetingEvening.
  ///
  /// In ko, this message translates to:
  /// **'좋은 저녁이에요, {name}님'**
  String homeGreetingEvening(String name);

  /// No description provided for @homeGreetingNight.
  ///
  /// In ko, this message translates to:
  /// **'늦은 시간 고생하세요, {name}님'**
  String homeGreetingNight(String name);

  /// No description provided for @homeQuickRegister.
  ///
  /// In ko, this message translates to:
  /// **'회원등록'**
  String get homeQuickRegister;

  /// No description provided for @homeQuickMatch.
  ///
  /// In ko, this message translates to:
  /// **'매칭생성'**
  String get homeQuickMatch;

  /// No description provided for @homeTodayTasks.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 할일'**
  String get homeTodayTasks;

  /// No description provided for @homeTodayPendingMatches.
  ///
  /// In ko, this message translates to:
  /// **'대기 매칭 {count}건'**
  String homeTodayPendingMatches(int count);

  /// No description provided for @homeTodayNewMessages.
  ///
  /// In ko, this message translates to:
  /// **'새 메시지 {count}건'**
  String homeTodayNewMessages(int count);

  /// No description provided for @homeTodayView.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get homeTodayView;

  /// No description provided for @homeRecentActivity.
  ///
  /// In ko, this message translates to:
  /// **'최근 활동'**
  String get homeRecentActivity;

  /// No description provided for @homeActivityMatchRequested.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭 요청'**
  String homeActivityMatchRequested(String clientA, String clientB);

  /// No description provided for @homeActivityMatchReceived.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭 요청 받음'**
  String homeActivityMatchReceived(String clientA, String clientB);

  /// No description provided for @homeActivityMatchAccepted.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭 성사'**
  String homeActivityMatchAccepted(String clientA, String clientB);

  /// No description provided for @homeActivityMatchDeclined.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭 거절'**
  String homeActivityMatchDeclined(String clientA, String clientB);

  /// No description provided for @homeActivityMatchCancelled.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭 취소'**
  String homeActivityMatchCancelled(String clientA, String clientB);

  /// No description provided for @homeActivityClientRegistered.
  ///
  /// In ko, this message translates to:
  /// **'{name} 신규 회원 등록'**
  String homeActivityClientRegistered(String name);

  /// No description provided for @homeActivityEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 활동 내역이 없습니다'**
  String get homeActivityEmpty;

  /// No description provided for @homeActivityEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'첫 회원을 등록해보세요!'**
  String get homeActivityEmptyAction;

  /// No description provided for @homeActivityToday.
  ///
  /// In ko, this message translates to:
  /// **'오늘'**
  String get homeActivityToday;

  /// No description provided for @homeActivityYesterday.
  ///
  /// In ko, this message translates to:
  /// **'어제'**
  String get homeActivityYesterday;

  /// No description provided for @homeNotificationMarkAllRead.
  ///
  /// In ko, this message translates to:
  /// **'모두 읽음'**
  String get homeNotificationMarkAllRead;

  /// No description provided for @homeClientRegTitle.
  ///
  /// In ko, this message translates to:
  /// **'간편 회원 등록'**
  String get homeClientRegTitle;

  /// No description provided for @homeClientRegNameRequired.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해주세요'**
  String get homeClientRegNameRequired;

  /// No description provided for @homeClientRegSuccess.
  ///
  /// In ko, this message translates to:
  /// **'회원이 등록되었습니다'**
  String get homeClientRegSuccess;

  /// No description provided for @homeMatchCreateTitle.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 추천'**
  String get homeMatchCreateTitle;

  /// No description provided for @homeMatchCreateEmpty.
  ///
  /// In ko, this message translates to:
  /// **'추천할 프로필이 없습니다'**
  String get homeMatchCreateEmpty;

  /// No description provided for @homeMatchMgmtTitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭 관리'**
  String get homeMatchMgmtTitle;

  /// No description provided for @homeMatchAccept.
  ///
  /// In ko, this message translates to:
  /// **'수락'**
  String get homeMatchAccept;

  /// No description provided for @homeMatchDecline.
  ///
  /// In ko, this message translates to:
  /// **'거절'**
  String get homeMatchDecline;

  /// No description provided for @homeMatchMemo.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get homeMatchMemo;

  /// No description provided for @homeMatchDeclineReason.
  ///
  /// In ko, this message translates to:
  /// **'거절 사유 (선택)'**
  String get homeMatchDeclineReason;

  /// No description provided for @homeMatchAcceptSuccess.
  ///
  /// In ko, this message translates to:
  /// **'매칭이 수락되었습니다'**
  String get homeMatchAcceptSuccess;

  /// No description provided for @homeMatchDeclineSuccess.
  ///
  /// In ko, this message translates to:
  /// **'매칭이 거절되었습니다'**
  String get homeMatchDeclineSuccess;

  /// No description provided for @homeMatchCancel.
  ///
  /// In ko, this message translates to:
  /// **'요청 취소'**
  String get homeMatchCancel;

  /// No description provided for @homeMatchCancelConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 매칭 요청을 취소하시겠습니까?'**
  String get homeMatchCancelConfirm;

  /// No description provided for @homeMatchCancelSuccess.
  ///
  /// In ko, this message translates to:
  /// **'매칭 요청이 취소되었습니다'**
  String get homeMatchCancelSuccess;

  /// No description provided for @homeMatchMemoHint.
  ///
  /// In ko, this message translates to:
  /// **'메모를 입력하세요'**
  String get homeMatchMemoHint;

  /// No description provided for @homeMatchMemoSaved.
  ///
  /// In ko, this message translates to:
  /// **'메모가 저장되었습니다'**
  String get homeMatchMemoSaved;

  /// No description provided for @matchCardSent.
  ///
  /// In ko, this message translates to:
  /// **'보낸 요청'**
  String get matchCardSent;

  /// No description provided for @matchCardReceived.
  ///
  /// In ko, this message translates to:
  /// **'받은 요청'**
  String get matchCardReceived;

  /// No description provided for @matchCardMyClient.
  ///
  /// In ko, this message translates to:
  /// **'내 회원'**
  String get matchCardMyClient;

  /// No description provided for @matchCardOtherClient.
  ///
  /// In ko, this message translates to:
  /// **'상대 회원'**
  String get matchCardOtherClient;

  /// No description provided for @marketplaceLikesTab.
  ///
  /// In ko, this message translates to:
  /// **'좋아요'**
  String get marketplaceLikesTab;

  /// No description provided for @marketplaceSortNewest.
  ///
  /// In ko, this message translates to:
  /// **'최신순'**
  String get marketplaceSortNewest;

  /// No description provided for @marketplaceSortMostLikes.
  ///
  /// In ko, this message translates to:
  /// **'좋아요순'**
  String get marketplaceSortMostLikes;

  /// No description provided for @marketplaceSortRecommended.
  ///
  /// In ko, this message translates to:
  /// **'추천순'**
  String get marketplaceSortRecommended;

  /// No description provided for @marketplaceFilterEducation.
  ///
  /// In ko, this message translates to:
  /// **'학력'**
  String get marketplaceFilterEducation;

  /// No description provided for @marketplaceFilterOccupation.
  ///
  /// In ko, this message translates to:
  /// **'직업군'**
  String get marketplaceFilterOccupation;

  /// No description provided for @marketplaceFilterIncome.
  ///
  /// In ko, this message translates to:
  /// **'연소득대'**
  String get marketplaceFilterIncome;

  /// No description provided for @marketplaceMatchCompleted.
  ///
  /// In ko, this message translates to:
  /// **'매칭완료'**
  String get marketplaceMatchCompleted;

  /// No description provided for @matchRequestVerificationPending.
  ///
  /// In ko, this message translates to:
  /// **'제출하신 서류를 검토하고 있습니다.\n승인 완료 후 매칭 요청이 가능합니다.\n잠시만 기다려주세요!'**
  String get matchRequestVerificationPending;

  /// No description provided for @matchRequestVerificationPendingTitle.
  ///
  /// In ko, this message translates to:
  /// **'인증 검토 중'**
  String get matchRequestVerificationPendingTitle;

  /// No description provided for @matchRequestVerificationRequired.
  ///
  /// In ko, this message translates to:
  /// **'매니저 인증이 필요합니다'**
  String get matchRequestVerificationRequired;

  /// No description provided for @matchRequestVerificationRequiredDesc.
  ///
  /// In ko, this message translates to:
  /// **'매칭 요청을 위해 결혼정보회사 소속을\n증명하는 서류를 제출해주세요.'**
  String get matchRequestVerificationRequiredDesc;

  /// No description provided for @matchRequestVerify.
  ///
  /// In ko, this message translates to:
  /// **'인증하기'**
  String get matchRequestVerify;

  /// No description provided for @matchRequestSelectClient.
  ///
  /// In ko, this message translates to:
  /// **'매칭할 회원을 선택해주세요'**
  String get matchRequestSelectClient;

  /// No description provided for @matchRequestNoEligible.
  ///
  /// In ko, this message translates to:
  /// **'매칭 가능한 이성 회원이 없습니다'**
  String get matchRequestNoEligible;

  /// No description provided for @matchRequestConfirmMessage.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭을 요청하시겠습니까?'**
  String matchRequestConfirmMessage(String clientA, String clientB);

  /// No description provided for @matchRequestSuccess.
  ///
  /// In ko, this message translates to:
  /// **'매칭 요청이 완료되었습니다'**
  String get matchRequestSuccess;

  /// No description provided for @matchRequestDailyLimit.
  ///
  /// In ko, this message translates to:
  /// **'오늘의 매칭 횟수를 초과했습니다'**
  String get matchRequestDailyLimit;

  /// No description provided for @clientRegistrationLimitExceeded.
  ///
  /// In ko, this message translates to:
  /// **'회원 등록 한도 초과 (현재 {current}/{limit}명). 구독을 업그레이드하세요.'**
  String clientRegistrationLimitExceeded(int current, int limit);

  /// No description provided for @subscriptionDevModeTitle.
  ///
  /// In ko, this message translates to:
  /// **'Dev: 구독 티어 변경'**
  String get subscriptionDevModeTitle;

  /// No description provided for @chatMatchContext.
  ///
  /// In ko, this message translates to:
  /// **'{clientA} ↔ {clientB} 매칭'**
  String chatMatchContext(String clientA, String clientB);

  /// No description provided for @chatImagePickerTitle.
  ///
  /// In ko, this message translates to:
  /// **'이미지 전송'**
  String get chatImagePickerTitle;

  /// No description provided for @chatImagePickerCamera.
  ///
  /// In ko, this message translates to:
  /// **'카메라'**
  String get chatImagePickerCamera;

  /// No description provided for @chatImagePickerGallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리'**
  String get chatImagePickerGallery;

  /// No description provided for @chatImageUploading.
  ///
  /// In ko, this message translates to:
  /// **'이미지 업로드 중...'**
  String get chatImageUploading;

  /// No description provided for @chatMessageSendFailed.
  ///
  /// In ko, this message translates to:
  /// **'메시지 전송에 실패했습니다'**
  String get chatMessageSendFailed;

  /// No description provided for @regTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원 등록'**
  String get regTitle;

  /// No description provided for @regStepOf.
  ///
  /// In ko, this message translates to:
  /// **'Step {current}/{total}'**
  String regStepOf(int current, int total);

  /// No description provided for @regStep1Title.
  ///
  /// In ko, this message translates to:
  /// **'기본 정보'**
  String get regStep1Title;

  /// No description provided for @regStep2Title.
  ///
  /// In ko, this message translates to:
  /// **'직업/학력'**
  String get regStep2Title;

  /// No description provided for @regStep3Title.
  ///
  /// In ko, this message translates to:
  /// **'신체/외모'**
  String get regStep3Title;

  /// No description provided for @regStep4Title.
  ///
  /// In ko, this message translates to:
  /// **'성격/취미'**
  String get regStep4Title;

  /// No description provided for @regStep5Title.
  ///
  /// In ko, this message translates to:
  /// **'동의 및 완료'**
  String get regStep5Title;

  /// No description provided for @regPrevious.
  ///
  /// In ko, this message translates to:
  /// **'이전'**
  String get regPrevious;

  /// No description provided for @regComplete.
  ///
  /// In ko, this message translates to:
  /// **'등록 완료'**
  String get regComplete;

  /// No description provided for @regNameLabel.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get regNameLabel;

  /// No description provided for @regNameHint.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력하세요'**
  String get regNameHint;

  /// No description provided for @regNameValidation.
  ///
  /// In ko, this message translates to:
  /// **'이름은 2~20자여야 합니다'**
  String get regNameValidation;

  /// No description provided for @regPhoneLabel.
  ///
  /// In ko, this message translates to:
  /// **'핸드폰'**
  String get regPhoneLabel;

  /// No description provided for @regPhoneHint.
  ///
  /// In ko, this message translates to:
  /// **'010-0000-0000'**
  String get regPhoneHint;

  /// No description provided for @regEmailLabel.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get regEmailLabel;

  /// No description provided for @regEmailHint.
  ///
  /// In ko, this message translates to:
  /// **'이메일을 입력하세요'**
  String get regEmailHint;

  /// No description provided for @regEmailValidation.
  ///
  /// In ko, this message translates to:
  /// **'올바른 이메일 형식이 아닙니다'**
  String get regEmailValidation;

  /// No description provided for @regOccupationLabel.
  ///
  /// In ko, this message translates to:
  /// **'직업'**
  String get regOccupationLabel;

  /// No description provided for @regOccupationHint.
  ///
  /// In ko, this message translates to:
  /// **'직업을 입력하세요'**
  String get regOccupationHint;

  /// No description provided for @regOccupationRequired.
  ///
  /// In ko, this message translates to:
  /// **'직업을 입력해주세요'**
  String get regOccupationRequired;

  /// No description provided for @regCompanyLabel.
  ///
  /// In ko, this message translates to:
  /// **'회사'**
  String get regCompanyLabel;

  /// No description provided for @regCompanyHint.
  ///
  /// In ko, this message translates to:
  /// **'회사를 입력하세요'**
  String get regCompanyHint;

  /// No description provided for @regEducationLevel.
  ///
  /// In ko, this message translates to:
  /// **'학력 수준'**
  String get regEducationLevel;

  /// No description provided for @regEduHighSchool.
  ///
  /// In ko, this message translates to:
  /// **'고졸'**
  String get regEduHighSchool;

  /// No description provided for @regEduAssociate.
  ///
  /// In ko, this message translates to:
  /// **'전문대'**
  String get regEduAssociate;

  /// No description provided for @regEduBachelor.
  ///
  /// In ko, this message translates to:
  /// **'대졸'**
  String get regEduBachelor;

  /// No description provided for @regEduMaster.
  ///
  /// In ko, this message translates to:
  /// **'석사'**
  String get regEduMaster;

  /// No description provided for @regEduDoctorate.
  ///
  /// In ko, this message translates to:
  /// **'박사'**
  String get regEduDoctorate;

  /// No description provided for @regSchoolLabel.
  ///
  /// In ko, this message translates to:
  /// **'학교명'**
  String get regSchoolLabel;

  /// No description provided for @regSchoolHint.
  ///
  /// In ko, this message translates to:
  /// **'학교명을 입력하세요'**
  String get regSchoolHint;

  /// No description provided for @regMajorLabel.
  ///
  /// In ko, this message translates to:
  /// **'전공'**
  String get regMajorLabel;

  /// No description provided for @regMajorHint.
  ///
  /// In ko, this message translates to:
  /// **'전공을 입력하세요'**
  String get regMajorHint;

  /// No description provided for @regIncomeLabel.
  ///
  /// In ko, this message translates to:
  /// **'연소득대'**
  String get regIncomeLabel;

  /// No description provided for @regIncome1.
  ///
  /// In ko, this message translates to:
  /// **'3,000만원 미만'**
  String get regIncome1;

  /// No description provided for @regIncome2.
  ///
  /// In ko, this message translates to:
  /// **'3,000~5,000만원'**
  String get regIncome2;

  /// No description provided for @regIncome3.
  ///
  /// In ko, this message translates to:
  /// **'5,000~7,000만원'**
  String get regIncome3;

  /// No description provided for @regIncome4.
  ///
  /// In ko, this message translates to:
  /// **'7,000만~1억원'**
  String get regIncome4;

  /// No description provided for @regIncome5.
  ///
  /// In ko, this message translates to:
  /// **'1억~1.5억원'**
  String get regIncome5;

  /// No description provided for @regIncome6.
  ///
  /// In ko, this message translates to:
  /// **'1.5억원 이상'**
  String get regIncome6;

  /// No description provided for @regHeightLabel.
  ///
  /// In ko, this message translates to:
  /// **'키'**
  String get regHeightLabel;

  /// No description provided for @regHeightValue.
  ///
  /// In ko, this message translates to:
  /// **'{height} cm'**
  String regHeightValue(int height);

  /// No description provided for @regBodyTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'체형'**
  String get regBodyTypeLabel;

  /// No description provided for @regBodySlim.
  ///
  /// In ko, this message translates to:
  /// **'마른'**
  String get regBodySlim;

  /// No description provided for @regBodySlightlySlim.
  ///
  /// In ko, this message translates to:
  /// **'약간마른'**
  String get regBodySlightlySlim;

  /// No description provided for @regBodyAverage.
  ///
  /// In ko, this message translates to:
  /// **'보통'**
  String get regBodyAverage;

  /// No description provided for @regBodySlightlyChubby.
  ///
  /// In ko, this message translates to:
  /// **'약간통통'**
  String get regBodySlightlyChubby;

  /// No description provided for @regBodyChubby.
  ///
  /// In ko, this message translates to:
  /// **'통통'**
  String get regBodyChubby;

  /// No description provided for @regPhotoLabel.
  ///
  /// In ko, this message translates to:
  /// **'프로필 사진 (최대 5장)'**
  String get regPhotoLabel;

  /// No description provided for @regPhotoAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get regPhotoAdd;

  /// No description provided for @regPhotoMain.
  ///
  /// In ko, this message translates to:
  /// **'대표'**
  String get regPhotoMain;

  /// No description provided for @regPhotoHint.
  ///
  /// In ko, this message translates to:
  /// **'첫 번째 사진이 대표 사진으로 사용됩니다.'**
  String get regPhotoHint;

  /// No description provided for @regPhotoMax.
  ///
  /// In ko, this message translates to:
  /// **'최대 5장까지 등록 가능합니다'**
  String get regPhotoMax;

  /// No description provided for @regReligionLabel.
  ///
  /// In ko, this message translates to:
  /// **'종교'**
  String get regReligionLabel;

  /// No description provided for @regReligionNone.
  ///
  /// In ko, this message translates to:
  /// **'무교'**
  String get regReligionNone;

  /// No description provided for @regReligionChristian.
  ///
  /// In ko, this message translates to:
  /// **'기독교'**
  String get regReligionChristian;

  /// No description provided for @regReligionCatholic.
  ///
  /// In ko, this message translates to:
  /// **'천주교'**
  String get regReligionCatholic;

  /// No description provided for @regReligionBuddhist.
  ///
  /// In ko, this message translates to:
  /// **'불교'**
  String get regReligionBuddhist;

  /// No description provided for @regReligionOther.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get regReligionOther;

  /// No description provided for @regHobbiesLabel.
  ///
  /// In ko, this message translates to:
  /// **'취미 (최대 5개)'**
  String get regHobbiesLabel;

  /// No description provided for @regHobbiesMax.
  ///
  /// In ko, this message translates to:
  /// **'최대 5개까지 선택 가능합니다'**
  String get regHobbiesMax;

  /// No description provided for @regHobbiesCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}/5'**
  String regHobbiesCount(int count);

  /// No description provided for @regHobbiesCustom.
  ///
  /// In ko, this message translates to:
  /// **'+ 직접 입력'**
  String get regHobbiesCustom;

  /// No description provided for @regHobbiesAdd.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get regHobbiesAdd;

  /// No description provided for @regBioLabel.
  ///
  /// In ko, this message translates to:
  /// **'자기소개'**
  String get regBioLabel;

  /// No description provided for @regBioHint.
  ///
  /// In ko, this message translates to:
  /// **'밝고 긍정적인 성격으로, 주말엔 카페에서 책 읽는 것을 좋아합니다...'**
  String get regBioHint;

  /// No description provided for @regBioCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}/300'**
  String regBioCount(int count);

  /// No description provided for @regAgreeAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 동의'**
  String get regAgreeAll;

  /// No description provided for @regAgreeAllRequired.
  ///
  /// In ko, this message translates to:
  /// **'필수 전체 동의'**
  String get regAgreeAllRequired;

  /// No description provided for @regAgreeTerms.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용 약관'**
  String get regAgreeTerms;

  /// No description provided for @regAgreePrivacy.
  ///
  /// In ko, this message translates to:
  /// **'개인정보 수집/이용'**
  String get regAgreePrivacy;

  /// No description provided for @regAgreeMarketing.
  ///
  /// In ko, this message translates to:
  /// **'마케팅 정보 수신'**
  String get regAgreeMarketing;

  /// No description provided for @regRequired.
  ///
  /// In ko, this message translates to:
  /// **'(필수)'**
  String get regRequired;

  /// No description provided for @regOptional.
  ///
  /// In ko, this message translates to:
  /// **'(선택)'**
  String get regOptional;

  /// No description provided for @regView.
  ///
  /// In ko, this message translates to:
  /// **'보기'**
  String get regView;

  /// No description provided for @regAgreeDesc.
  ///
  /// In ko, this message translates to:
  /// **'등록 정보를 확인하고 약관에 동의해주세요.'**
  String get regAgreeDesc;

  /// No description provided for @regSuccessTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원 등록 완료!'**
  String get regSuccessTitle;

  /// No description provided for @regSuccessMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}님이 등록되었습니다'**
  String regSuccessMessage(String name);

  /// No description provided for @regSuccessViewProfile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 확인'**
  String get regSuccessViewProfile;

  /// No description provided for @regSuccessGoHome.
  ///
  /// In ko, this message translates to:
  /// **'홈으로'**
  String get regSuccessGoHome;

  /// No description provided for @regExitTitle.
  ///
  /// In ko, this message translates to:
  /// **'나가시겠습니까?'**
  String get regExitTitle;

  /// No description provided for @regExitMessage.
  ///
  /// In ko, this message translates to:
  /// **'입력 중인 정보가 있습니다.\n임시저장됩니다.'**
  String get regExitMessage;

  /// No description provided for @regExitLeave.
  ///
  /// In ko, this message translates to:
  /// **'나가기'**
  String get regExitLeave;

  /// No description provided for @regDraftFound.
  ///
  /// In ko, this message translates to:
  /// **'작성 중인 회원 정보가 있습니다.\n이어서 작성하시겠습니까?'**
  String get regDraftFound;

  /// No description provided for @regDraftContinue.
  ///
  /// In ko, this message translates to:
  /// **'이어서 작성'**
  String get regDraftContinue;

  /// No description provided for @regDraftNew.
  ///
  /// In ko, this message translates to:
  /// **'새로 작성'**
  String get regDraftNew;

  /// No description provided for @myClientsTitle.
  ///
  /// In ko, this message translates to:
  /// **'내 회원 관리'**
  String get myClientsTitle;

  /// No description provided for @myClientsRegister.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get myClientsRegister;

  /// No description provided for @myClientsSearchHint.
  ///
  /// In ko, this message translates to:
  /// **'이름으로 검색'**
  String get myClientsSearchHint;

  /// No description provided for @myClientsTabAll.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get myClientsTabAll;

  /// No description provided for @myClientsTabActive.
  ///
  /// In ko, this message translates to:
  /// **'활성'**
  String get myClientsTabActive;

  /// No description provided for @myClientsTabPaused.
  ///
  /// In ko, this message translates to:
  /// **'휴지'**
  String get myClientsTabPaused;

  /// No description provided for @myClientsTabMatched.
  ///
  /// In ko, this message translates to:
  /// **'매칭중'**
  String get myClientsTabMatched;

  /// No description provided for @myClientsCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String myClientsCount(int count);

  /// No description provided for @myClientsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 회원이 없습니다'**
  String get myClientsEmpty;

  /// No description provided for @myClientsEmptyAction.
  ///
  /// In ko, this message translates to:
  /// **'첫 회원을 등록해보세요'**
  String get myClientsEmptyAction;

  /// No description provided for @myClientDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원 상세'**
  String get myClientDetailTitle;

  /// No description provided for @myClientDetailEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get myClientDetailEdit;

  /// No description provided for @myClientDetailStatus.
  ///
  /// In ko, this message translates to:
  /// **'상태'**
  String get myClientDetailStatus;

  /// No description provided for @myClientDetailStatusActive.
  ///
  /// In ko, this message translates to:
  /// **'활성'**
  String get myClientDetailStatusActive;

  /// No description provided for @myClientDetailStatusPaused.
  ///
  /// In ko, this message translates to:
  /// **'휴지'**
  String get myClientDetailStatusPaused;

  /// No description provided for @myClientDetailStatusMatched.
  ///
  /// In ko, this message translates to:
  /// **'매칭중'**
  String get myClientDetailStatusMatched;

  /// No description provided for @myClientDetailStatusWithdrawn.
  ///
  /// In ko, this message translates to:
  /// **'탈퇴'**
  String get myClientDetailStatusWithdrawn;

  /// No description provided for @myClientDetailMatchHistory.
  ///
  /// In ko, this message translates to:
  /// **'매칭 이력'**
  String get myClientDetailMatchHistory;

  /// No description provided for @myClientDetailMatchEmpty.
  ///
  /// In ko, this message translates to:
  /// **'매칭 이력이 없습니다'**
  String get myClientDetailMatchEmpty;

  /// No description provided for @myClientDetailRegisteredAt.
  ///
  /// In ko, this message translates to:
  /// **'등록일'**
  String get myClientDetailRegisteredAt;

  /// No description provided for @myClientDetailPhone.
  ///
  /// In ko, this message translates to:
  /// **'연락처'**
  String get myClientDetailPhone;

  /// No description provided for @myClientDetailEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get myClientDetailEmail;

  /// No description provided for @myClientDetailEducationLevel.
  ///
  /// In ko, this message translates to:
  /// **'학력'**
  String get myClientDetailEducationLevel;

  /// No description provided for @myClientDetailSchool.
  ///
  /// In ko, this message translates to:
  /// **'학교'**
  String get myClientDetailSchool;

  /// No description provided for @myClientDetailMajor.
  ///
  /// In ko, this message translates to:
  /// **'전공'**
  String get myClientDetailMajor;

  /// No description provided for @myClientDetailBodyType.
  ///
  /// In ko, this message translates to:
  /// **'체형'**
  String get myClientDetailBodyType;

  /// No description provided for @myClientEditTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원 정보 수정'**
  String get myClientEditTitle;

  /// No description provided for @myClientEditSaved.
  ///
  /// In ko, this message translates to:
  /// **'수정 사항이 저장되었습니다'**
  String get myClientEditSaved;

  /// No description provided for @myClientEditFailed.
  ///
  /// In ko, this message translates to:
  /// **'저장에 실패했습니다'**
  String get myClientEditFailed;

  /// No description provided for @myClientStatusChange.
  ///
  /// In ko, this message translates to:
  /// **'상태 변경'**
  String get myClientStatusChange;

  /// No description provided for @myClientStatusChangeConfirm.
  ///
  /// In ko, this message translates to:
  /// **'{name}님의 상태를 {status}(으)로 변경하시겠습니까?'**
  String myClientStatusChangeConfirm(String name, String status);

  /// No description provided for @myClientStatusChanged.
  ///
  /// In ko, this message translates to:
  /// **'상태가 변경되었습니다'**
  String get myClientStatusChanged;

  /// No description provided for @myClientDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원 삭제'**
  String get myClientDeleteTitle;

  /// No description provided for @myClientDeleteMessage.
  ///
  /// In ko, this message translates to:
  /// **'{name}님을 삭제하시겠습니까?\n삭제 시 해당 회원의 대기 매칭이 취소되고, 프로필 마켓에서 사라집니다.'**
  String myClientDeleteMessage(String name);

  /// No description provided for @myClientDeleteSuccess.
  ///
  /// In ko, this message translates to:
  /// **'회원이 삭제되었습니다'**
  String get myClientDeleteSuccess;

  /// No description provided for @myClientDeleteFailed.
  ///
  /// In ko, this message translates to:
  /// **'삭제에 실패했습니다'**
  String get myClientDeleteFailed;

  /// No description provided for @verificationTitle.
  ///
  /// In ko, this message translates to:
  /// **'매니저 인증'**
  String get verificationTitle;

  /// No description provided for @verificationDesc.
  ///
  /// In ko, this message translates to:
  /// **'결혼정보회사 소속을 증명할 서류를 제출해주세요.\n검토 후 알림으로 결과를 안내드립니다.'**
  String get verificationDesc;

  /// No description provided for @verificationDocTypeTitle.
  ///
  /// In ko, this message translates to:
  /// **'서류 종류 선택'**
  String get verificationDocTypeTitle;

  /// No description provided for @verificationBusinessCard.
  ///
  /// In ko, this message translates to:
  /// **'명함'**
  String get verificationBusinessCard;

  /// No description provided for @verificationEmploymentCert.
  ///
  /// In ko, this message translates to:
  /// **'재직증명서'**
  String get verificationEmploymentCert;

  /// No description provided for @verificationBusinessReg.
  ///
  /// In ko, this message translates to:
  /// **'사업자등록증'**
  String get verificationBusinessReg;

  /// No description provided for @verificationAcceptedDocs.
  ///
  /// In ko, this message translates to:
  /// **'인정되는 서류'**
  String get verificationAcceptedDocs;

  /// No description provided for @verificationUpload.
  ///
  /// In ko, this message translates to:
  /// **'서류 업로드'**
  String get verificationUpload;

  /// No description provided for @verificationUploadHint.
  ///
  /// In ko, this message translates to:
  /// **'서류 사진을 촬영하거나 선택하세요'**
  String get verificationUploadHint;

  /// No description provided for @verificationUploadSub.
  ///
  /// In ko, this message translates to:
  /// **'카메라 촬영 또는 갤러리에서 선택'**
  String get verificationUploadSub;

  /// No description provided for @verificationChangeImage.
  ///
  /// In ko, this message translates to:
  /// **'변경'**
  String get verificationChangeImage;

  /// No description provided for @verificationCamera.
  ///
  /// In ko, this message translates to:
  /// **'카메라'**
  String get verificationCamera;

  /// No description provided for @verificationGallery.
  ///
  /// In ko, this message translates to:
  /// **'갤러리'**
  String get verificationGallery;

  /// No description provided for @verificationSubmit.
  ///
  /// In ko, this message translates to:
  /// **'제출하기'**
  String get verificationSubmit;

  /// No description provided for @verificationSubmitSuccess.
  ///
  /// In ko, this message translates to:
  /// **'제출 완료! 검토 후 알림드리겠습니다.'**
  String get verificationSubmitSuccess;

  /// No description provided for @verificationSubmitFailed.
  ///
  /// In ko, this message translates to:
  /// **'제출에 실패했습니다'**
  String get verificationSubmitFailed;

  /// No description provided for @verificationUploading.
  ///
  /// In ko, this message translates to:
  /// **'업로드 중...'**
  String get verificationUploading;

  /// No description provided for @verificationStatusUnverified.
  ///
  /// In ko, this message translates to:
  /// **'미인증'**
  String get verificationStatusUnverified;

  /// No description provided for @verificationStatusPending.
  ///
  /// In ko, this message translates to:
  /// **'인증 대기중'**
  String get verificationStatusPending;

  /// No description provided for @verificationStatusVerified.
  ///
  /// In ko, this message translates to:
  /// **'인증 완료'**
  String get verificationStatusVerified;

  /// No description provided for @verificationStatusRejected.
  ///
  /// In ko, this message translates to:
  /// **'반려됨'**
  String get verificationStatusRejected;

  /// No description provided for @verificationRejectedMessage.
  ///
  /// In ko, this message translates to:
  /// **'인증이 반려되었습니다. 서류를 다시 제출해주세요.'**
  String get verificationRejectedMessage;

  /// No description provided for @verificationRejectedReason.
  ///
  /// In ko, this message translates to:
  /// **'반려 사유: {reason}'**
  String verificationRejectedReason(String reason);

  /// No description provided for @verificationResubmit.
  ///
  /// In ko, this message translates to:
  /// **'재제출하기'**
  String get verificationResubmit;

  /// No description provided for @verificationImageRequired.
  ///
  /// In ko, this message translates to:
  /// **'서류 이미지를 선택해주세요'**
  String get verificationImageRequired;

  /// No description provided for @contractEmptyTitle.
  ///
  /// In ko, this message translates to:
  /// **'계약 이력이 없습니다'**
  String get contractEmptyTitle;

  /// No description provided for @contractAgreedAt.
  ///
  /// In ko, this message translates to:
  /// **'동의 일시'**
  String get contractAgreedAt;

  /// No description provided for @contractHashLabel.
  ///
  /// In ko, this message translates to:
  /// **'계약 해시'**
  String get contractHashLabel;

  /// No description provided for @contractMarketingConsent.
  ///
  /// In ko, this message translates to:
  /// **'마케팅 동의'**
  String get contractMarketingConsent;

  /// No description provided for @contractDeviceInfo.
  ///
  /// In ko, this message translates to:
  /// **'디바이스'**
  String get contractDeviceInfo;

  /// No description provided for @contractHistory.
  ///
  /// In ko, this message translates to:
  /// **'계약 이력'**
  String get contractHistory;

  /// No description provided for @subscriptionCurrentPlan.
  ///
  /// In ko, this message translates to:
  /// **'현재 플랜'**
  String get subscriptionCurrentPlan;

  /// No description provided for @subscriptionDailyUsage.
  ///
  /// In ko, this message translates to:
  /// **'오늘 {used}/{limit}건 사용'**
  String subscriptionDailyUsage(int used, int limit);

  /// No description provided for @subscriptionChangePlan.
  ///
  /// In ko, this message translates to:
  /// **'플랜 변경'**
  String get subscriptionChangePlan;

  /// No description provided for @subscriptionFeatureMatches.
  ///
  /// In ko, this message translates to:
  /// **'일일 매칭'**
  String get subscriptionFeatureMatches;

  /// No description provided for @subscriptionFeatureMatchesValue.
  ///
  /// In ko, this message translates to:
  /// **'{count}건/일'**
  String subscriptionFeatureMatchesValue(int count);

  /// No description provided for @subscriptionClientLimit.
  ///
  /// In ko, this message translates to:
  /// **'회원 등록'**
  String get subscriptionClientLimit;

  /// No description provided for @subscriptionClientLimitValue.
  ///
  /// In ko, this message translates to:
  /// **'최대 {count}명'**
  String subscriptionClientLimitValue(int count);

  /// No description provided for @subscriptionFreePlanDesc.
  ///
  /// In ko, this message translates to:
  /// **'무료 플랜'**
  String get subscriptionFreePlanDesc;

  /// No description provided for @subscriptionSilverPlanDesc.
  ///
  /// In ko, this message translates to:
  /// **'실버 플랜'**
  String get subscriptionSilverPlanDesc;

  /// No description provided for @subscriptionGoldPlanDesc.
  ///
  /// In ko, this message translates to:
  /// **'골드 플랜'**
  String get subscriptionGoldPlanDesc;

  /// No description provided for @subscriptionLaunchPrice.
  ///
  /// In ko, this message translates to:
  /// **'론칭 특가'**
  String get subscriptionLaunchPrice;

  /// No description provided for @subscriptionOriginalPrice.
  ///
  /// In ko, this message translates to:
  /// **'정가'**
  String get subscriptionOriginalPrice;

  /// No description provided for @subscriptionRestoreTitle.
  ///
  /// In ko, this message translates to:
  /// **'구매 복원'**
  String get subscriptionRestoreTitle;

  /// No description provided for @subscriptionRestoreSuccess.
  ///
  /// In ko, this message translates to:
  /// **'구매가 복원되었습니다'**
  String get subscriptionRestoreSuccess;

  /// No description provided for @subscriptionRestoreFailed.
  ///
  /// In ko, this message translates to:
  /// **'복원할 구매가 없습니다'**
  String get subscriptionRestoreFailed;

  /// No description provided for @subscriptionNotConfigured.
  ///
  /// In ko, this message translates to:
  /// **'구독 서비스 준비 중입니다'**
  String get subscriptionNotConfigured;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationSettingsDesc.
  ///
  /// In ko, this message translates to:
  /// **'알림 종류별로 푸시 알림 수신 여부를 설정할 수 있습니다. 앱 내 알림은 항상 표시됩니다.'**
  String get notificationSettingsDesc;

  /// No description provided for @notificationSettingsMatch.
  ///
  /// In ko, this message translates to:
  /// **'매칭 알림'**
  String get notificationSettingsMatch;

  /// No description provided for @notificationSettingsMatchDesc.
  ///
  /// In ko, this message translates to:
  /// **'매칭 요청, 수락, 거절 알림'**
  String get notificationSettingsMatchDesc;

  /// No description provided for @notificationSettingsMessage.
  ///
  /// In ko, this message translates to:
  /// **'채팅 알림'**
  String get notificationSettingsMessage;

  /// No description provided for @notificationSettingsMessageDesc.
  ///
  /// In ko, this message translates to:
  /// **'새 메시지 수신 알림'**
  String get notificationSettingsMessageDesc;

  /// No description provided for @notificationSettingsVerification.
  ///
  /// In ko, this message translates to:
  /// **'인증 알림'**
  String get notificationSettingsVerification;

  /// No description provided for @notificationSettingsVerificationDesc.
  ///
  /// In ko, this message translates to:
  /// **'매니저 인증 승인/반려 알림'**
  String get notificationSettingsVerificationDesc;

  /// No description provided for @notificationSettingsSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 알림'**
  String get notificationSettingsSystem;

  /// No description provided for @notificationSettingsSystemDesc.
  ///
  /// In ko, this message translates to:
  /// **'공지사항, 구독 만료 등'**
  String get notificationSettingsSystemDesc;

  /// No description provided for @notificationSettingsFcmNote.
  ///
  /// In ko, this message translates to:
  /// **'푸시 알림은 Firebase 설정 후 활성화됩니다. 앱 내 알림은 항상 수신됩니다.'**
  String get notificationSettingsFcmNote;

  /// No description provided for @notificationSettingsSaved.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정이 저장되었습니다'**
  String get notificationSettingsSaved;

  /// No description provided for @matchDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'매칭 상세'**
  String get matchDetailTitle;

  /// No description provided for @matchDetailNotFound.
  ///
  /// In ko, this message translates to:
  /// **'매칭 정보를 찾을 수 없습니다'**
  String get matchDetailNotFound;

  /// No description provided for @matchDetailClientA.
  ///
  /// In ko, this message translates to:
  /// **'회원 A'**
  String get matchDetailClientA;

  /// No description provided for @matchDetailClientB.
  ///
  /// In ko, this message translates to:
  /// **'회원 B'**
  String get matchDetailClientB;

  /// No description provided for @matchDetailCreatedBy.
  ///
  /// In ko, this message translates to:
  /// **'생성자'**
  String get matchDetailCreatedBy;

  /// No description provided for @matchDetailCreatedAt.
  ///
  /// In ko, this message translates to:
  /// **'생성일'**
  String get matchDetailCreatedAt;

  /// No description provided for @matchDetailRespondedAt.
  ///
  /// In ko, this message translates to:
  /// **'응답일'**
  String get matchDetailRespondedAt;

  /// No description provided for @matchDetailOpenChat.
  ///
  /// In ko, this message translates to:
  /// **'채팅 열기'**
  String get matchDetailOpenChat;

  /// No description provided for @matchDetailAcceptConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 매칭 요청을 수락하시겠습니까? 수락 시 상대 매니저와 채팅방이 생성됩니다.'**
  String get matchDetailAcceptConfirm;

  /// No description provided for @matchDetailWaitingResponse.
  ///
  /// In ko, this message translates to:
  /// **'상대 매니저의 응답을 기다리고 있습니다'**
  String get matchDetailWaitingResponse;

  /// No description provided for @matchHistoryEmpty.
  ///
  /// In ko, this message translates to:
  /// **'매칭 이력이 없습니다'**
  String get matchHistoryEmpty;

  /// No description provided for @regStep6Title.
  ///
  /// In ko, this message translates to:
  /// **'가족/라이프스타일'**
  String get regStep6Title;

  /// No description provided for @regMaritalHistoryLabel.
  ///
  /// In ko, this message translates to:
  /// **'결혼 이력'**
  String get regMaritalHistoryLabel;

  /// No description provided for @regMaritalFirst.
  ///
  /// In ko, this message translates to:
  /// **'초혼'**
  String get regMaritalFirst;

  /// No description provided for @regMaritalRemarriage.
  ///
  /// In ko, this message translates to:
  /// **'재혼'**
  String get regMaritalRemarriage;

  /// No description provided for @regMaritalDivorced.
  ///
  /// In ko, this message translates to:
  /// **'이혼'**
  String get regMaritalDivorced;

  /// No description provided for @regHasChildrenLabel.
  ///
  /// In ko, this message translates to:
  /// **'자녀 유무'**
  String get regHasChildrenLabel;

  /// No description provided for @regChildrenCountLabel.
  ///
  /// In ko, this message translates to:
  /// **'자녀 수'**
  String get regChildrenCountLabel;

  /// No description provided for @regFamilyDetailLabel.
  ///
  /// In ko, this message translates to:
  /// **'가족 관계'**
  String get regFamilyDetailLabel;

  /// No description provided for @regFamilyDetailHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 1남2녀 중 장남'**
  String get regFamilyDetailHint;

  /// No description provided for @regParentsStatusLabel.
  ///
  /// In ko, this message translates to:
  /// **'부모님 상태'**
  String get regParentsStatusLabel;

  /// No description provided for @regParentsBothAlive.
  ///
  /// In ko, this message translates to:
  /// **'양부모 건재'**
  String get regParentsBothAlive;

  /// No description provided for @regParentsFatherOnly.
  ///
  /// In ko, this message translates to:
  /// **'부친만'**
  String get regParentsFatherOnly;

  /// No description provided for @regParentsMotherOnly.
  ///
  /// In ko, this message translates to:
  /// **'모친만'**
  String get regParentsMotherOnly;

  /// No description provided for @regParentsDeceased.
  ///
  /// In ko, this message translates to:
  /// **'모두 별세'**
  String get regParentsDeceased;

  /// No description provided for @regDrinkingLabel.
  ///
  /// In ko, this message translates to:
  /// **'음주'**
  String get regDrinkingLabel;

  /// No description provided for @regDrinkingNone.
  ///
  /// In ko, this message translates to:
  /// **'안 함'**
  String get regDrinkingNone;

  /// No description provided for @regDrinkingSocial.
  ///
  /// In ko, this message translates to:
  /// **'가끔'**
  String get regDrinkingSocial;

  /// No description provided for @regDrinkingRegular.
  ///
  /// In ko, this message translates to:
  /// **'자주'**
  String get regDrinkingRegular;

  /// No description provided for @regSmokingLabel.
  ///
  /// In ko, this message translates to:
  /// **'흡연'**
  String get regSmokingLabel;

  /// No description provided for @regSmokingNone.
  ///
  /// In ko, this message translates to:
  /// **'안 함'**
  String get regSmokingNone;

  /// No description provided for @regSmokingSometimes.
  ///
  /// In ko, this message translates to:
  /// **'가끔'**
  String get regSmokingSometimes;

  /// No description provided for @regSmokingRegular.
  ///
  /// In ko, this message translates to:
  /// **'자주'**
  String get regSmokingRegular;

  /// No description provided for @regAssetRangeLabel.
  ///
  /// In ko, this message translates to:
  /// **'자산 범위'**
  String get regAssetRangeLabel;

  /// No description provided for @regAssetRange1.
  ///
  /// In ko, this message translates to:
  /// **'1억 미만'**
  String get regAssetRange1;

  /// No description provided for @regAssetRange2.
  ///
  /// In ko, this message translates to:
  /// **'1~3억'**
  String get regAssetRange2;

  /// No description provided for @regAssetRange3.
  ///
  /// In ko, this message translates to:
  /// **'3~5억'**
  String get regAssetRange3;

  /// No description provided for @regAssetRange4.
  ///
  /// In ko, this message translates to:
  /// **'5~10억'**
  String get regAssetRange4;

  /// No description provided for @regAssetRange5.
  ///
  /// In ko, this message translates to:
  /// **'10억 이상'**
  String get regAssetRange5;

  /// No description provided for @regResidenceAreaLabel.
  ///
  /// In ko, this message translates to:
  /// **'거주 지역'**
  String get regResidenceAreaLabel;

  /// No description provided for @regResidenceAreaHint.
  ///
  /// In ko, this message translates to:
  /// **'예: 서울 강남구'**
  String get regResidenceAreaHint;

  /// No description provided for @regResidenceTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'거주 형태'**
  String get regResidenceTypeLabel;

  /// No description provided for @regResidenceOwn.
  ///
  /// In ko, this message translates to:
  /// **'자가'**
  String get regResidenceOwn;

  /// No description provided for @regResidenceRentDeposit.
  ///
  /// In ko, this message translates to:
  /// **'전세'**
  String get regResidenceRentDeposit;

  /// No description provided for @regResidenceRentMonthly.
  ///
  /// In ko, this message translates to:
  /// **'월세'**
  String get regResidenceRentMonthly;

  /// No description provided for @regResidenceWithParents.
  ///
  /// In ko, this message translates to:
  /// **'부모님 동거'**
  String get regResidenceWithParents;

  /// No description provided for @regHealthNotesLabel.
  ///
  /// In ko, this message translates to:
  /// **'건강 특이사항'**
  String get regHealthNotesLabel;

  /// No description provided for @regHealthNotesHint.
  ///
  /// In ko, this message translates to:
  /// **'특이사항이 있으면 입력하세요'**
  String get regHealthNotesHint;

  /// No description provided for @regPersonalityTypeLabel.
  ///
  /// In ko, this message translates to:
  /// **'성격 유형 (MBTI 등)'**
  String get regPersonalityTypeLabel;

  /// No description provided for @regPersonalityTypeHint.
  ///
  /// In ko, this message translates to:
  /// **'예: ENFP'**
  String get regPersonalityTypeHint;

  /// No description provided for @profileFamilyTitle.
  ///
  /// In ko, this message translates to:
  /// **'가족 정보'**
  String get profileFamilyTitle;

  /// No description provided for @profileLifestyleTitle.
  ///
  /// In ko, this message translates to:
  /// **'라이프스타일'**
  String get profileLifestyleTitle;

  /// No description provided for @profileIdealPartnerTitle.
  ///
  /// In ko, this message translates to:
  /// **'이상형 조건'**
  String get profileIdealPartnerTitle;

  /// No description provided for @profileResidenceTitle.
  ///
  /// In ko, this message translates to:
  /// **'자산/거주'**
  String get profileResidenceTitle;

  /// No description provided for @profilePersonalityTitle.
  ///
  /// In ko, this message translates to:
  /// **'성격'**
  String get profilePersonalityTitle;

  /// No description provided for @profileMaritalHistory.
  ///
  /// In ko, this message translates to:
  /// **'결혼이력'**
  String get profileMaritalHistory;

  /// No description provided for @profileChildren.
  ///
  /// In ko, this message translates to:
  /// **'자녀'**
  String get profileChildren;

  /// No description provided for @profileChildrenCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}명'**
  String profileChildrenCount(int count);

  /// No description provided for @profileFamilyDetail.
  ///
  /// In ko, this message translates to:
  /// **'가족관계'**
  String get profileFamilyDetail;

  /// No description provided for @profileParentsStatus.
  ///
  /// In ko, this message translates to:
  /// **'부모님'**
  String get profileParentsStatus;

  /// No description provided for @profileDrinking.
  ///
  /// In ko, this message translates to:
  /// **'음주'**
  String get profileDrinking;

  /// No description provided for @profileSmoking.
  ///
  /// In ko, this message translates to:
  /// **'흡연'**
  String get profileSmoking;

  /// No description provided for @profileHealthNotes.
  ///
  /// In ko, this message translates to:
  /// **'건강'**
  String get profileHealthNotes;

  /// No description provided for @profilePersonalityType.
  ///
  /// In ko, this message translates to:
  /// **'성격유형'**
  String get profilePersonalityType;

  /// No description provided for @profileAssetRange.
  ///
  /// In ko, this message translates to:
  /// **'자산'**
  String get profileAssetRange;

  /// No description provided for @profileResidenceArea.
  ///
  /// In ko, this message translates to:
  /// **'거주지'**
  String get profileResidenceArea;

  /// No description provided for @profileResidenceType.
  ///
  /// In ko, this message translates to:
  /// **'거주형태'**
  String get profileResidenceType;

  /// No description provided for @profileIdealAge.
  ///
  /// In ko, this message translates to:
  /// **'희망 나이'**
  String get profileIdealAge;

  /// No description provided for @profileIdealHeight.
  ///
  /// In ko, this message translates to:
  /// **'희망 키'**
  String get profileIdealHeight;

  /// No description provided for @profileIdealEducation.
  ///
  /// In ko, this message translates to:
  /// **'희망 학력'**
  String get profileIdealEducation;

  /// No description provided for @profileIdealIncome.
  ///
  /// In ko, this message translates to:
  /// **'희망 연소득'**
  String get profileIdealIncome;

  /// No description provided for @profileIdealReligion.
  ///
  /// In ko, this message translates to:
  /// **'희망 종교'**
  String get profileIdealReligion;

  /// No description provided for @profileIdealNotes.
  ///
  /// In ko, this message translates to:
  /// **'기타 조건'**
  String get profileIdealNotes;

  /// No description provided for @profileIdealAgeRange.
  ///
  /// In ko, this message translates to:
  /// **'{min}~{max}세'**
  String profileIdealAgeRange(int min, int max);

  /// No description provided for @profileIdealHeightRange.
  ///
  /// In ko, this message translates to:
  /// **'{min}~{max}cm'**
  String profileIdealHeightRange(int min, int max);

  /// No description provided for @marketplaceFilterDrinking.
  ///
  /// In ko, this message translates to:
  /// **'음주'**
  String get marketplaceFilterDrinking;

  /// No description provided for @marketplaceFilterSmoking.
  ///
  /// In ko, this message translates to:
  /// **'흡연'**
  String get marketplaceFilterSmoking;

  /// No description provided for @marketplaceFilterMaritalHistory.
  ///
  /// In ko, this message translates to:
  /// **'결혼이력'**
  String get marketplaceFilterMaritalHistory;

  /// No description provided for @marketplaceFilterResidenceArea.
  ///
  /// In ko, this message translates to:
  /// **'거주지'**
  String get marketplaceFilterResidenceArea;

  /// No description provided for @marketplaceFilterResidenceHint.
  ///
  /// In ko, this message translates to:
  /// **'지역명 입력'**
  String get marketplaceFilterResidenceHint;

  /// No description provided for @crmNotesTitle.
  ///
  /// In ko, this message translates to:
  /// **'메모 & 타임라인'**
  String get crmNotesTitle;

  /// No description provided for @crmNoteAdd.
  ///
  /// In ko, this message translates to:
  /// **'메모 추가'**
  String get crmNoteAdd;

  /// No description provided for @crmNoteTypeGeneral.
  ///
  /// In ko, this message translates to:
  /// **'일반'**
  String get crmNoteTypeGeneral;

  /// No description provided for @crmNoteTypePreference.
  ///
  /// In ko, this message translates to:
  /// **'선호도'**
  String get crmNoteTypePreference;

  /// No description provided for @crmNoteTypeMeetingFeedback.
  ///
  /// In ko, this message translates to:
  /// **'미팅 후기'**
  String get crmNoteTypeMeetingFeedback;

  /// No description provided for @crmNoteTypeSchedule.
  ///
  /// In ko, this message translates to:
  /// **'일정'**
  String get crmNoteTypeSchedule;

  /// No description provided for @crmNoteContentHint.
  ///
  /// In ko, this message translates to:
  /// **'메모 내용을 입력하세요'**
  String get crmNoteContentHint;

  /// No description provided for @crmNoteScheduleAt.
  ///
  /// In ko, this message translates to:
  /// **'일정 날짜'**
  String get crmNoteScheduleAt;

  /// No description provided for @crmNoteSaved.
  ///
  /// In ko, this message translates to:
  /// **'메모가 저장되었습니다'**
  String get crmNoteSaved;

  /// No description provided for @crmNoteDeleted.
  ///
  /// In ko, this message translates to:
  /// **'메모가 삭제되었습니다'**
  String get crmNoteDeleted;

  /// No description provided for @crmNoteDeleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'이 메모를 삭제하시겠습니까?'**
  String get crmNoteDeleteConfirm;

  /// No description provided for @crmNoteEmpty.
  ///
  /// In ko, this message translates to:
  /// **'아직 메모가 없습니다'**
  String get crmNoteEmpty;

  /// No description provided for @crmNoteCompleted.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get crmNoteCompleted;

  /// No description provided for @crmScheduleTitle.
  ///
  /// In ko, this message translates to:
  /// **'예정 일정'**
  String get crmScheduleTitle;

  /// No description provided for @crmScheduleEmpty.
  ///
  /// In ko, this message translates to:
  /// **'예정된 일정이 없습니다'**
  String get crmScheduleEmpty;

  /// No description provided for @crmTagsTitle.
  ///
  /// In ko, this message translates to:
  /// **'태그'**
  String get crmTagsTitle;

  /// No description provided for @crmTagsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'태그를 추가하여 회원을 분류하세요'**
  String get crmTagsEmpty;

  /// No description provided for @crmTagsAdd.
  ///
  /// In ko, this message translates to:
  /// **'태그 추가'**
  String get crmTagsAdd;

  /// No description provided for @crmTagsAddButton.
  ///
  /// In ko, this message translates to:
  /// **'추가'**
  String get crmTagsAddButton;

  /// No description provided for @crmTagsCustomHint.
  ///
  /// In ko, this message translates to:
  /// **'커스텀 태그 입력'**
  String get crmTagsCustomHint;

  /// No description provided for @crmDashboardTitle.
  ///
  /// In ko, this message translates to:
  /// **'회원 분석'**
  String get crmDashboardTitle;

  /// No description provided for @crmThisMonth.
  ///
  /// In ko, this message translates to:
  /// **'이번 달 활동'**
  String get crmThisMonth;

  /// No description provided for @crmNewRegistrations.
  ///
  /// In ko, this message translates to:
  /// **'신규 등록'**
  String get crmNewRegistrations;

  /// No description provided for @crmNewMatches.
  ///
  /// In ko, this message translates to:
  /// **'매칭 요청'**
  String get crmNewMatches;

  /// No description provided for @crmTotalNotes.
  ///
  /// In ko, this message translates to:
  /// **'메모'**
  String get crmTotalNotes;

  /// No description provided for @crmClientOverview.
  ///
  /// In ko, this message translates to:
  /// **'회원 현황'**
  String get crmClientOverview;

  /// No description provided for @crmTotalClients.
  ///
  /// In ko, this message translates to:
  /// **'명'**
  String get crmTotalClients;

  /// No description provided for @crmAvgAge.
  ///
  /// In ko, this message translates to:
  /// **'평균 연령'**
  String get crmAvgAge;

  /// No description provided for @crmMatchPerformance.
  ///
  /// In ko, this message translates to:
  /// **'매칭 성과'**
  String get crmMatchPerformance;

  /// No description provided for @crmSuccessRate.
  ///
  /// In ko, this message translates to:
  /// **'매칭 성공률'**
  String get crmSuccessRate;

  /// No description provided for @crmDeclineRate.
  ///
  /// In ko, this message translates to:
  /// **'거절률'**
  String get crmDeclineRate;

  /// No description provided for @crmPendingMatches.
  ///
  /// In ko, this message translates to:
  /// **'대기 중'**
  String get crmPendingMatches;

  /// No description provided for @crmWaitingResponse.
  ///
  /// In ko, this message translates to:
  /// **'응답 대기'**
  String get crmWaitingResponse;

  /// No description provided for @crmTotalMatchesLabel.
  ///
  /// In ko, this message translates to:
  /// **'전체 매칭'**
  String get crmTotalMatchesLabel;

  /// No description provided for @crmAllTime.
  ///
  /// In ko, this message translates to:
  /// **'누적'**
  String get crmAllTime;

  /// No description provided for @supportHeaderTitle.
  ///
  /// In ko, this message translates to:
  /// **'도움이 필요하신가요?'**
  String get supportHeaderTitle;

  /// No description provided for @supportHeaderSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'궁금한 점이나 문제가 있으시면\n언제든지 문의해주세요.'**
  String get supportHeaderSubtitle;

  /// No description provided for @supportEmailTitle.
  ///
  /// In ko, this message translates to:
  /// **'이메일 문의'**
  String get supportEmailTitle;

  /// No description provided for @supportEmailDesc.
  ///
  /// In ko, this message translates to:
  /// **'영업일 기준 24시간 내 답변드립니다.\n문의 시 매니저명과 연락처를 함께 적어주세요.'**
  String get supportEmailDesc;

  /// No description provided for @supportEmailButton.
  ///
  /// In ko, this message translates to:
  /// **'이메일 보내기'**
  String get supportEmailButton;

  /// No description provided for @supportHoursTitle.
  ///
  /// In ko, this message translates to:
  /// **'운영 시간'**
  String get supportHoursTitle;

  /// No description provided for @supportHoursValue.
  ///
  /// In ko, this message translates to:
  /// **'평일 10:00 - 18:00 (주말/공휴일 제외)'**
  String get supportHoursValue;

  /// No description provided for @supportEmailFallback.
  ///
  /// In ko, this message translates to:
  /// **'이메일 앱을 찾을 수 없습니다. 직접 연락해 주세요: {email}'**
  String supportEmailFallback(String email);

  /// No description provided for @supportFaqTitle.
  ///
  /// In ko, this message translates to:
  /// **'자주 묻는 질문'**
  String get supportFaqTitle;

  /// No description provided for @supportFaq1Q.
  ///
  /// In ko, this message translates to:
  /// **'구독을 변경하거나 취소하려면?'**
  String get supportFaq1Q;

  /// No description provided for @supportFaq1A.
  ///
  /// In ko, this message translates to:
  /// **'마이 > 구독 관리에서 플랜을 변경할 수 있습니다. 구독 취소는 앱스토어/플레이스토어에서 직접 관리됩니다.'**
  String get supportFaq1A;

  /// No description provided for @supportFaq2Q.
  ///
  /// In ko, this message translates to:
  /// **'매니저 인증은 얼마나 걸리나요?'**
  String get supportFaq2Q;

  /// No description provided for @supportFaq2A.
  ///
  /// In ko, this message translates to:
  /// **'서류 제출 후 영업일 기준 1-2일 내 검토가 완료됩니다. 결과는 푸시 알림으로 안내드립니다.'**
  String get supportFaq2A;

  /// No description provided for @supportFaq3Q.
  ///
  /// In ko, this message translates to:
  /// **'일일 매칭 횟수는 언제 초기화되나요?'**
  String get supportFaq3Q;

  /// No description provided for @supportFaq3A.
  ///
  /// In ko, this message translates to:
  /// **'매일 자정(00:00)에 자동 초기화됩니다.'**
  String get supportFaq3A;

  /// No description provided for @supportFaq4Q.
  ///
  /// In ko, this message translates to:
  /// **'등록한 회원 정보를 삭제하려면?'**
  String get supportFaq4Q;

  /// No description provided for @supportFaq4A.
  ///
  /// In ko, this message translates to:
  /// **'마이 > 내 회원 관리에서 해당 회원의 상세 페이지로 들어가 삭제할 수 있습니다. 삭제 시 관련 대기 매칭이 취소됩니다.'**
  String get supportFaq4A;

  /// No description provided for @homeTodaySchedules.
  ///
  /// In ko, this message translates to:
  /// **'예정 일정 {count}건'**
  String homeTodaySchedules(int count);

  /// No description provided for @customerSupportUrl.
  ///
  /// In ko, this message translates to:
  /// **'https://cupplus.channel.io'**
  String get customerSupportUrl;

  /// No description provided for @regPhotoRemaining.
  ///
  /// In ko, this message translates to:
  /// **'최대 {count}장'**
  String regPhotoRemaining(int count);

  /// No description provided for @landingHeroTitle.
  ///
  /// In ko, this message translates to:
  /// **'당신의 매칭,\n한 차원 높게'**
  String get landingHeroTitle;

  /// No description provided for @landingHeroSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'결혼정보회사 매니저를 위한\n올인원 매칭 관리 플랫폼'**
  String get landingHeroSubtitle;

  /// No description provided for @landingFeature1Title.
  ///
  /// In ko, this message translates to:
  /// **'스마트 매칭'**
  String get landingFeature1Title;

  /// No description provided for @landingFeature1Desc.
  ///
  /// In ko, this message translates to:
  /// **'회원 데이터 기반 최적의 매칭 추천'**
  String get landingFeature1Desc;

  /// No description provided for @landingFeature2Title.
  ///
  /// In ko, this message translates to:
  /// **'실시간 소통'**
  String get landingFeature2Title;

  /// No description provided for @landingFeature2Desc.
  ///
  /// In ko, this message translates to:
  /// **'매니저간 즉시 채팅으로 빠른 매칭 성사'**
  String get landingFeature2Desc;

  /// No description provided for @landingFeature3Title.
  ///
  /// In ko, this message translates to:
  /// **'체계적 관리'**
  String get landingFeature3Title;

  /// No description provided for @landingFeature3Desc.
  ///
  /// In ko, this message translates to:
  /// **'회원 등록부터 계약까지 한 곳에서'**
  String get landingFeature3Desc;

  /// No description provided for @landingCta.
  ///
  /// In ko, this message translates to:
  /// **'지금 시작하기'**
  String get landingCta;

  /// No description provided for @landingLoginPrompt.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요?'**
  String get landingLoginPrompt;

  /// No description provided for @profileDetailMatchContext.
  ///
  /// In ko, this message translates to:
  /// **'매칭 요청에 포함된 회원입니다'**
  String get profileDetailMatchContext;

  /// No description provided for @matchSheetVerificationRequired.
  ///
  /// In ko, this message translates to:
  /// **'매니저 인증이 필요합니다'**
  String get matchSheetVerificationRequired;

  /// No description provided for @matchSheetVerificationBody.
  ///
  /// In ko, this message translates to:
  /// **'매칭을 수락/거절하려면 매니저 인증을 먼저 완료해주세요.'**
  String get matchSheetVerificationBody;

  /// No description provided for @matchSheetGoVerify.
  ///
  /// In ko, this message translates to:
  /// **'인증하러 가기'**
  String get matchSheetGoVerify;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
