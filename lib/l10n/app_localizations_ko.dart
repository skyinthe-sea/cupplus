// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'cup+';

  @override
  String get commonCancel => '취소';

  @override
  String get commonConfirm => '확인';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEdit => '편집';

  @override
  String get commonSearch => '검색';

  @override
  String get commonLoading => '로딩 중...';

  @override
  String get commonError => '오류가 발생했습니다';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonClose => '닫기';

  @override
  String get commonNext => '다음';

  @override
  String get commonBack => '뒤로';

  @override
  String get commonDone => '완료';

  @override
  String get commonAll => '전체';

  @override
  String get commonFemale => '여성';

  @override
  String get commonMale => '남성';

  @override
  String get authLogin => '로그인';

  @override
  String get authLogout => '로그아웃';

  @override
  String get authSignUp => '회원가입';

  @override
  String get authEmail => '이메일';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authForgotPassword => '비밀번호 찾기';

  @override
  String get authComingSoon => '곧 제공됩니다';

  @override
  String get authSubtitle => '매칭 전문가를 위한 플랫폼';

  @override
  String get authLoginWithGoogle => 'Google로 계속하기';

  @override
  String get authLoginWithKakao => '카카오로 계속하기';

  @override
  String get authLoginWithEmail => '이메일로 계속하기';

  @override
  String get authGetStarted => '시작하기';

  @override
  String get authAlreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get authTermsNotice => '계속 진행하면 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.';

  @override
  String get authOr => '또는';

  @override
  String get matchStatusPending => '대기 중';

  @override
  String get matchStatusAccepted => '수락됨';

  @override
  String get matchStatusDeclined => '거절됨';

  @override
  String get matchStatusMeetingScheduled => '만남 예정';

  @override
  String get matchStatusCompleted => '완료';

  @override
  String get matchCreate => '매칭 생성';

  @override
  String get matchList => '매칭 목록';

  @override
  String get profileTitle => '프로필';

  @override
  String get profileEdit => '프로필 편집';

  @override
  String get profileName => '이름';

  @override
  String get profileGender => '성별';

  @override
  String get profileBirthDate => '생년월일';

  @override
  String get profileEducation => '학력';

  @override
  String get profileOccupation => '직업';

  @override
  String get profileCompany => '회사';

  @override
  String get profileIncome => '연소득';

  @override
  String get profileReligion => '종교';

  @override
  String get profileHeight => '키';

  @override
  String get chatTitle => '채팅';

  @override
  String get chatSendMessage => '메시지 보내기';

  @override
  String get chatNoMessages => '메시지가 없습니다';

  @override
  String get chatImageSent => '이미지를 보냈습니다';

  @override
  String get chatListHeadline => '대화함';

  @override
  String chatListUnreadCount(int count) {
    return '읽지 않은 메시지 $count건';
  }

  @override
  String get chatEmptyTitle => '대화가 없습니다';

  @override
  String get chatEmptySubtitle => '다른 매니저와 대화를 시작해보세요';

  @override
  String get chatInputPlaceholder => '메시지를 입력하세요';

  @override
  String get chatOnline => '온라인';

  @override
  String get chatOffline => '오프라인';

  @override
  String get chatToday => '오늘';

  @override
  String get chatYesterday => '어제';

  @override
  String get chatImageMessage => '사진';

  @override
  String get chatFileMessage => '파일';

  @override
  String get chatJustNow => '방금';

  @override
  String chatMinutesAgo(int minutes) {
    return '$minutes분 전';
  }

  @override
  String chatHoursAgo(int hours) {
    return '$hours시간 전';
  }

  @override
  String chatDateFormat(int month, int day) {
    return '$month월 $day일';
  }

  @override
  String get contractTitle => '계약';

  @override
  String get contractAgree => '동의합니다';

  @override
  String get contractSign => '서명하기';

  @override
  String get contractVersion => '계약 버전';

  @override
  String get subscriptionTitle => '구독';

  @override
  String get subscriptionFree => '무료';

  @override
  String get subscriptionStandard => '스탠다드';

  @override
  String get subscriptionPremium => '프리미엄';

  @override
  String subscriptionDailyLimit(int count) {
    return '일일 매칭 제한: $count건';
  }

  @override
  String get notificationTitle => '알림';

  @override
  String get notificationEmpty => '알림이 없습니다';

  @override
  String get navHome => '홈';

  @override
  String get navMatches => '매칭';

  @override
  String get navChat => '채팅';

  @override
  String get navMy => '마이';

  @override
  String get homeTitle => '홈 화면입니다';

  @override
  String homeGreeting(String name) {
    return '안녕하세요, $name님!';
  }

  @override
  String homeRecommendedCount(int count) {
    return '오늘 $count명의 추천 프로필이 있어요.';
  }

  @override
  String get homeRecommendedTitle => '추천 프로필';

  @override
  String get homeStatusTitle => '활동 현황';

  @override
  String get homePendingMatches => '대기 중 매칭';

  @override
  String get homeTodayMatches => '오늘 매칭';

  @override
  String get homePendingVerifications => '서류 대기';

  @override
  String get homeNewMessages => '새 메시지';

  @override
  String get homeVerified => '인증됨';

  @override
  String get homeGenderMale => '남';

  @override
  String get homeGenderFemale => '여';

  @override
  String get homeTipTitle => '매칭 팁';

  @override
  String homeAgeSuffix(int age) {
    return '$age세';
  }

  @override
  String homeHeightCm(int height) {
    return '${height}cm';
  }

  @override
  String get matchesTitle => '매칭';

  @override
  String get matchesTabPending => '대기 중';

  @override
  String get matchesTabActive => '진행 중';

  @override
  String get matchesTabDone => '완료';

  @override
  String matchesTotalCount(int count) {
    return '총 $count건의 매칭';
  }

  @override
  String matchesMatchedAt(String date) {
    return '$date';
  }

  @override
  String get matchesNotesPreview => '메모';

  @override
  String get matchesEmptyPendingTitle => '대기 중인 매칭이 없습니다';

  @override
  String get matchesEmptyPendingSubtitle => '새로운 매칭을 생성해보세요';

  @override
  String get matchesEmptyActiveTitle => '진행 중인 매칭이 없습니다';

  @override
  String get matchesEmptyActiveSubtitle => '대기 중인 매칭이 수락되면 여기에 표시됩니다';

  @override
  String get matchesEmptyDoneTitle => '완료된 매칭이 없습니다';

  @override
  String get matchesEmptyDoneSubtitle => '매칭이 완료되거나 거절되면 여기에 표시됩니다';

  @override
  String get chatListTitle => '대화함';

  @override
  String get myTitle => '마이 화면입니다';

  @override
  String get authRequiredTitle => '로그인이 필요합니다';

  @override
  String get authRequiredMessage => '이 기능을 사용하려면 로그인이 필요합니다.';

  @override
  String get authRequiredLogin => '로그인하기';

  @override
  String get errorNotFound => '페이지를 찾을 수 없습니다';

  @override
  String get errorGoHome => '홈으로 이동';

  @override
  String get mySettingsTitle => '설정';

  @override
  String get mySettingsLanguage => '언어';

  @override
  String get mySettingsLanguageKo => '한국어';

  @override
  String get mySettingsLanguageEn => 'English';

  @override
  String get mySettingsDarkMode => '다크 모드';

  @override
  String get myGeneralTitle => '일반';

  @override
  String get myMatchHistory => '매칭 이력';

  @override
  String get mySubscriptionManage => '구독 관리';

  @override
  String get myNotificationSettings => '알림 설정';

  @override
  String get myCustomerSupport => '고객센터';

  @override
  String get myLogoutConfirmTitle => '로그아웃';

  @override
  String get myLogoutConfirmMessage => '정말 로그아웃하시겠습니까?';

  @override
  String get myProfileDetail => '프로필 상세';

  @override
  String myVersion(String version) {
    return '버전 $version';
  }

  @override
  String get nicknameEditTitle => '닉네임 변경';

  @override
  String get nicknameHint => '닉네임을 입력하세요';

  @override
  String get nicknameRules => '2-20자, 한글/영문/숫자/밑줄(_)';

  @override
  String get nicknameAvailable => '사용 가능';

  @override
  String get nicknameUnavailable => '이미 사용 중';

  @override
  String get nicknameInvalid => '올바르지 않은 형식';

  @override
  String get nicknameConfirm => '확인';

  @override
  String get nicknameEditSuccess => '닉네임이 변경되었습니다';

  @override
  String get nicknameSetHint => '닉네임을 설정해주세요';

  @override
  String get authLoginError => '로그인에 실패했습니다';

  @override
  String get authDevLogin => '개발자 로그인';

  @override
  String get myNickname => '닉네임';

  @override
  String get myLinkedAccountsTitle => '연결된 계정';

  @override
  String get myLinkedAccountConnected => '연결됨';

  @override
  String get myLinkedAccountNotConnected => '미연결';

  @override
  String get authLastUsed => '최근 사용';

  @override
  String get authDifferentProviderTitle => '다른 로그인 방법';

  @override
  String authDifferentProviderMessage(String provider) {
    return '이전에 $provider로 로그인하셨습니다. 다른 방법으로 로그인하면 별도의 계정이 생성될 수 있습니다. 계속하시겠습니까?';
  }

  @override
  String get marketplaceTitle => '프로필 마켓';

  @override
  String marketplaceTotalCount(int count) {
    return '총 $count명의 프로필';
  }

  @override
  String get marketplaceSearchHint => '이름, 직업, 회사, 지역 검색';

  @override
  String get marketplaceEmptyTitle => '프로필이 없습니다';

  @override
  String get marketplaceEmptySubtitle => '검색 조건을 변경해보세요';

  @override
  String get marketplaceFilterTitle => '필터';

  @override
  String get marketplaceFilterClear => '초기화';

  @override
  String get marketplaceFilterApply => '적용하기';

  @override
  String marketplaceFilterAge(int min, int max) {
    return '나이 ($min세 ~ $max세)';
  }

  @override
  String marketplaceFilterHeight(int min, int max) {
    return '키 (${min}cm ~ ${max}cm)';
  }

  @override
  String get marketplaceFilterVerifiedOnly => '인증된 프로필만';

  @override
  String get profileDetailInfoTitle => '기본 정보';

  @override
  String get profileDetailHobbies => '취미/관심사';

  @override
  String get profileDetailBio => '자기소개';

  @override
  String get profileDetailIdealPartner => '이상형';

  @override
  String get profileDetailVerification => '인증 서류';

  @override
  String get profileDetailMatchRequests => '매칭 신청';

  @override
  String get profileDetailMatchRequestUnit => '건';

  @override
  String get profileDetailRequestMatch => '매칭 신청하기';

  @override
  String get profileDetailMatchRequestTitle => '매칭 신청';

  @override
  String profileDetailMatchRequestMessage(String name) {
    return '$name님에게 매칭을 신청하시겠습니까?';
  }

  @override
  String get profileDetailMatchRequestSent => '매칭 신청이 완료되었습니다';
}
