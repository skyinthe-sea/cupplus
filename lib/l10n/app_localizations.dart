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
  /// **'다른 매니저와 대화를 시작해보세요'**
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

  /// No description provided for @subscriptionStandard.
  ///
  /// In ko, this message translates to:
  /// **'스탠다드'**
  String get subscriptionStandard;

  /// No description provided for @subscriptionPremium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get subscriptionPremium;

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
