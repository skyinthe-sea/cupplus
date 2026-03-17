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
  String get matchStatusCancelled => '취소됨';

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
  String get chatEmptySubtitle => '아직 채팅이 없습니다.\n매칭이 성사되면 자동으로 채팅방이 생성됩니다.';

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
  String chatDaysAgo(int days) {
    return '$days일 전';
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

  @override
  String homeGreetingMorning(String name) {
    return '좋은 아침이에요, $name님';
  }

  @override
  String homeGreetingAfternoon(String name) {
    return '좋은 오후예요, $name님';
  }

  @override
  String homeGreetingEvening(String name) {
    return '좋은 저녁이에요, $name님';
  }

  @override
  String homeGreetingNight(String name) {
    return '늦은 시간 고생하세요, $name님';
  }

  @override
  String get homeQuickRegister => '회원등록';

  @override
  String get homeQuickMatch => '매칭생성';

  @override
  String get homeTodayTasks => '오늘의 할일';

  @override
  String homeTodayPendingMatches(int count) {
    return '대기 매칭 $count건';
  }

  @override
  String homeTodayNewMessages(int count) {
    return '새 메시지 $count건';
  }

  @override
  String get homeTodayView => '보기';

  @override
  String get homeRecentActivity => '최근 활동';

  @override
  String homeActivityMatchRequested(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭 요청';
  }

  @override
  String homeActivityMatchReceived(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭 요청 받음';
  }

  @override
  String homeActivityMatchAccepted(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭 성사';
  }

  @override
  String homeActivityMatchDeclined(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭 거절';
  }

  @override
  String homeActivityMatchCancelled(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭 취소';
  }

  @override
  String homeActivityClientRegistered(String name) {
    return '$name 신규 회원 등록';
  }

  @override
  String get homeActivityEmpty => '아직 활동 내역이 없습니다';

  @override
  String get homeActivityEmptyAction => '첫 회원을 등록해보세요!';

  @override
  String get homeActivityToday => '오늘';

  @override
  String get homeActivityYesterday => '어제';

  @override
  String get homeNotificationMarkAllRead => '모두 읽음';

  @override
  String get homeClientRegTitle => '간편 회원 등록';

  @override
  String get homeClientRegNameRequired => '이름을 입력해주세요';

  @override
  String get homeClientRegSuccess => '회원이 등록되었습니다';

  @override
  String get homeMatchCreateTitle => '오늘의 추천';

  @override
  String get homeMatchCreateEmpty => '추천할 프로필이 없습니다';

  @override
  String get homeMatchMgmtTitle => '매칭 관리';

  @override
  String get homeMatchAccept => '수락';

  @override
  String get homeMatchDecline => '거절';

  @override
  String get homeMatchMemo => '메모';

  @override
  String get homeMatchDeclineReason => '거절 사유 (선택)';

  @override
  String get homeMatchAcceptSuccess => '매칭이 수락되었습니다';

  @override
  String get homeMatchDeclineSuccess => '매칭이 거절되었습니다';

  @override
  String get homeMatchCancel => '요청 취소';

  @override
  String get homeMatchCancelConfirm => '이 매칭 요청을 취소하시겠습니까?';

  @override
  String get homeMatchCancelSuccess => '매칭 요청이 취소되었습니다';

  @override
  String get homeMatchMemoHint => '메모를 입력하세요';

  @override
  String get homeMatchMemoSaved => '메모가 저장되었습니다';

  @override
  String get matchCardSent => '보낸 요청';

  @override
  String get matchCardReceived => '받은 요청';

  @override
  String get matchCardMyClient => '내 회원';

  @override
  String get matchCardOtherClient => '상대 회원';

  @override
  String get marketplaceLikesTab => '좋아요';

  @override
  String get marketplaceSortNewest => '최신순';

  @override
  String get marketplaceSortMostLikes => '좋아요순';

  @override
  String get marketplaceSortRecommended => '추천순';

  @override
  String get marketplaceFilterEducation => '학력';

  @override
  String get marketplaceFilterOccupation => '직업군';

  @override
  String get marketplaceFilterIncome => '연소득대';

  @override
  String get marketplaceMatchCompleted => '매칭완료';

  @override
  String get matchRequestVerificationPending =>
      '제출하신 서류를 검토하고 있습니다.\n승인 완료 후 매칭 요청이 가능합니다.\n잠시만 기다려주세요!';

  @override
  String get matchRequestVerificationPendingTitle => '인증 검토 중';

  @override
  String get matchRequestVerificationRequired => '매니저 인증이 필요합니다';

  @override
  String get matchRequestVerificationRequiredDesc =>
      '매칭 요청을 위해 결혼정보회사 소속을\n증명하는 서류를 제출해주세요.';

  @override
  String get matchRequestVerify => '인증하기';

  @override
  String get matchRequestSelectClient => '매칭할 회원을 선택해주세요';

  @override
  String get matchRequestNoEligible => '매칭 가능한 이성 회원이 없습니다';

  @override
  String matchRequestConfirmMessage(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭을 요청하시겠습니까?';
  }

  @override
  String get matchRequestSuccess => '매칭 요청이 완료되었습니다';

  @override
  String get matchRequestDailyLimit => '오늘의 매칭 횟수를 초과했습니다';

  @override
  String chatMatchContext(String clientA, String clientB) {
    return '$clientA ↔ $clientB 매칭';
  }

  @override
  String get chatImagePickerTitle => '이미지 전송';

  @override
  String get chatImagePickerCamera => '카메라';

  @override
  String get chatImagePickerGallery => '갤러리';

  @override
  String get chatImageUploading => '이미지 업로드 중...';

  @override
  String get chatMessageSendFailed => '메시지 전송에 실패했습니다';

  @override
  String get regTitle => '회원 등록';

  @override
  String regStepOf(int current, int total) {
    return 'Step $current/$total';
  }

  @override
  String get regStep1Title => '기본 정보';

  @override
  String get regStep2Title => '직업/학력';

  @override
  String get regStep3Title => '신체/외모';

  @override
  String get regStep4Title => '성격/취미';

  @override
  String get regStep5Title => '동의 및 완료';

  @override
  String get regPrevious => '이전';

  @override
  String get regComplete => '등록 완료';

  @override
  String get regNameLabel => '이름';

  @override
  String get regNameHint => '이름을 입력하세요';

  @override
  String get regNameValidation => '이름은 2~20자여야 합니다';

  @override
  String get regPhoneLabel => '핸드폰';

  @override
  String get regPhoneHint => '010-0000-0000';

  @override
  String get regEmailLabel => '이메일';

  @override
  String get regEmailHint => '이메일을 입력하세요';

  @override
  String get regEmailValidation => '올바른 이메일 형식이 아닙니다';

  @override
  String get regOccupationLabel => '직업';

  @override
  String get regOccupationHint => '직업을 입력하세요';

  @override
  String get regOccupationRequired => '직업을 입력해주세요';

  @override
  String get regCompanyLabel => '회사';

  @override
  String get regCompanyHint => '회사를 입력하세요';

  @override
  String get regEducationLevel => '학력 수준';

  @override
  String get regEduHighSchool => '고졸';

  @override
  String get regEduAssociate => '전문대';

  @override
  String get regEduBachelor => '대졸';

  @override
  String get regEduMaster => '석사';

  @override
  String get regEduDoctorate => '박사';

  @override
  String get regSchoolLabel => '학교명';

  @override
  String get regSchoolHint => '학교명을 입력하세요';

  @override
  String get regMajorLabel => '전공';

  @override
  String get regMajorHint => '전공을 입력하세요';

  @override
  String get regIncomeLabel => '연소득대';

  @override
  String get regIncome1 => '3,000만원 미만';

  @override
  String get regIncome2 => '3,000~5,000만원';

  @override
  String get regIncome3 => '5,000~7,000만원';

  @override
  String get regIncome4 => '7,000만~1억원';

  @override
  String get regIncome5 => '1억~1.5억원';

  @override
  String get regIncome6 => '1.5억원 이상';

  @override
  String get regHeightLabel => '키';

  @override
  String regHeightValue(int height) {
    return '$height cm';
  }

  @override
  String get regBodyTypeLabel => '체형';

  @override
  String get regBodySlim => '마른';

  @override
  String get regBodySlightlySlim => '약간마른';

  @override
  String get regBodyAverage => '보통';

  @override
  String get regBodySlightlyChubby => '약간통통';

  @override
  String get regBodyChubby => '통통';

  @override
  String get regPhotoLabel => '프로필 사진 (최대 5장)';

  @override
  String get regPhotoAdd => '추가';

  @override
  String get regPhotoMain => '대표';

  @override
  String get regPhotoHint => '첫 번째 사진이 대표 사진으로 사용됩니다.';

  @override
  String get regPhotoMax => '최대 5장까지 등록 가능합니다';

  @override
  String get regReligionLabel => '종교';

  @override
  String get regReligionNone => '무교';

  @override
  String get regReligionChristian => '기독교';

  @override
  String get regReligionCatholic => '천주교';

  @override
  String get regReligionBuddhist => '불교';

  @override
  String get regReligionOther => '기타';

  @override
  String get regHobbiesLabel => '취미 (최대 5개)';

  @override
  String get regHobbiesMax => '최대 5개까지 선택 가능합니다';

  @override
  String regHobbiesCount(int count) {
    return '$count/5';
  }

  @override
  String get regHobbiesCustom => '+ 직접 입력';

  @override
  String get regHobbiesAdd => '추가';

  @override
  String get regBioLabel => '자기소개';

  @override
  String get regBioHint => '밝고 긍정적인 성격으로, 주말엔 카페에서 책 읽는 것을 좋아합니다...';

  @override
  String regBioCount(int count) {
    return '$count/300';
  }

  @override
  String get regAgreeAll => '전체 동의';

  @override
  String get regAgreeAllRequired => '필수 전체 동의';

  @override
  String get regAgreeTerms => '서비스 이용 약관';

  @override
  String get regAgreePrivacy => '개인정보 수집/이용';

  @override
  String get regAgreeMarketing => '마케팅 정보 수신';

  @override
  String get regRequired => '(필수)';

  @override
  String get regOptional => '(선택)';

  @override
  String get regView => '보기';

  @override
  String get regAgreeDesc => '등록 정보를 확인하고 약관에 동의해주세요.';

  @override
  String get regSuccessTitle => '회원 등록 완료!';

  @override
  String regSuccessMessage(String name) {
    return '$name님이 등록되었습니다';
  }

  @override
  String get regSuccessViewProfile => '프로필 확인';

  @override
  String get regSuccessGoHome => '홈으로';

  @override
  String get regExitTitle => '나가시겠습니까?';

  @override
  String get regExitMessage => '입력 중인 정보가 있습니다.\n임시저장됩니다.';

  @override
  String get regExitLeave => '나가기';

  @override
  String get regDraftFound => '작성 중인 회원 정보가 있습니다.\n이어서 작성하시겠습니까?';

  @override
  String get regDraftContinue => '이어서 작성';

  @override
  String get regDraftNew => '새로 작성';

  @override
  String get myClientsTitle => '내 회원 관리';

  @override
  String get myClientsRegister => '등록';

  @override
  String get myClientsSearchHint => '이름으로 검색';

  @override
  String get myClientsTabAll => '전체';

  @override
  String get myClientsTabActive => '활성';

  @override
  String get myClientsTabPaused => '휴지';

  @override
  String get myClientsTabMatched => '매칭중';

  @override
  String myClientsCount(int count) {
    return '$count명';
  }

  @override
  String get myClientsEmpty => '등록된 회원이 없습니다';

  @override
  String get myClientsEmptyAction => '첫 회원을 등록해보세요';

  @override
  String get myClientDetailTitle => '회원 상세';

  @override
  String get myClientDetailEdit => '수정';

  @override
  String get myClientDetailStatus => '상태';

  @override
  String get myClientDetailStatusActive => '활성';

  @override
  String get myClientDetailStatusPaused => '휴지';

  @override
  String get myClientDetailStatusMatched => '매칭중';

  @override
  String get myClientDetailStatusWithdrawn => '탈퇴';

  @override
  String get myClientDetailMatchHistory => '매칭 이력';

  @override
  String get myClientDetailMatchEmpty => '매칭 이력이 없습니다';

  @override
  String get myClientDetailRegisteredAt => '등록일';

  @override
  String get myClientDetailPhone => '연락처';

  @override
  String get myClientDetailEmail => '이메일';

  @override
  String get myClientDetailEducationLevel => '학력';

  @override
  String get myClientDetailSchool => '학교';

  @override
  String get myClientDetailMajor => '전공';

  @override
  String get myClientDetailBodyType => '체형';

  @override
  String get myClientEditTitle => '회원 정보 수정';

  @override
  String get myClientEditSaved => '수정 사항이 저장되었습니다';

  @override
  String get myClientEditFailed => '저장에 실패했습니다';

  @override
  String get myClientStatusChange => '상태 변경';

  @override
  String myClientStatusChangeConfirm(String name, String status) {
    return '$name님의 상태를 $status(으)로 변경하시겠습니까?';
  }

  @override
  String get myClientStatusChanged => '상태가 변경되었습니다';

  @override
  String get myClientDeleteTitle => '회원 삭제';

  @override
  String myClientDeleteMessage(String name) {
    return '$name님을 삭제하시겠습니까?\n삭제 시 해당 회원의 대기 매칭이 취소되고, 프로필 마켓에서 사라집니다.';
  }

  @override
  String get myClientDeleteSuccess => '회원이 삭제되었습니다';

  @override
  String get myClientDeleteFailed => '삭제에 실패했습니다';

  @override
  String get verificationTitle => '매니저 인증';

  @override
  String get verificationDesc =>
      '결혼정보회사 소속을 증명할 서류를 제출해주세요.\n검토 후 알림으로 결과를 안내드립니다.';

  @override
  String get verificationDocTypeTitle => '서류 종류 선택';

  @override
  String get verificationBusinessCard => '명함';

  @override
  String get verificationEmploymentCert => '재직증명서';

  @override
  String get verificationBusinessReg => '사업자등록증';

  @override
  String get verificationAcceptedDocs => '인정되는 서류';

  @override
  String get verificationUpload => '서류 업로드';

  @override
  String get verificationUploadHint => '서류 사진을 촬영하거나 선택하세요';

  @override
  String get verificationUploadSub => '카메라 촬영 또는 갤러리에서 선택';

  @override
  String get verificationChangeImage => '변경';

  @override
  String get verificationCamera => '카메라';

  @override
  String get verificationGallery => '갤러리';

  @override
  String get verificationSubmit => '제출하기';

  @override
  String get verificationSubmitSuccess => '제출 완료! 검토 후 알림드리겠습니다.';

  @override
  String get verificationSubmitFailed => '제출에 실패했습니다';

  @override
  String get verificationUploading => '업로드 중...';

  @override
  String get verificationStatusUnverified => '미인증';

  @override
  String get verificationStatusPending => '인증 대기중';

  @override
  String get verificationStatusVerified => '인증 완료';

  @override
  String get verificationStatusRejected => '반려됨';

  @override
  String get verificationRejectedMessage => '인증이 반려되었습니다. 서류를 다시 제출해주세요.';

  @override
  String verificationRejectedReason(String reason) {
    return '반려 사유: $reason';
  }

  @override
  String get verificationResubmit => '재제출하기';

  @override
  String get verificationImageRequired => '서류 이미지를 선택해주세요';

  @override
  String get contractEmptyTitle => '계약 이력이 없습니다';

  @override
  String get contractAgreedAt => '동의 일시';

  @override
  String get contractHashLabel => '계약 해시';

  @override
  String get contractMarketingConsent => '마케팅 동의';

  @override
  String get contractDeviceInfo => '디바이스';

  @override
  String get contractHistory => '계약 이력';

  @override
  String get subscriptionCurrentPlan => '현재 플랜';

  @override
  String subscriptionDailyUsage(int used, int limit) {
    return '오늘 $used/$limit건 사용';
  }

  @override
  String subscriptionDailyUnlimited(int used) {
    return '오늘 $used건 사용 · 무제한';
  }

  @override
  String get subscriptionChangePlan => '플랜 변경';

  @override
  String get subscriptionFeatureMatches => '일일 매칭';

  @override
  String subscriptionFeatureMatchesValue(int count) {
    return '$count건/일';
  }

  @override
  String get subscriptionFeatureUnlimited => '무제한';

  @override
  String get subscriptionFreePlanDesc => '무료 플랜';

  @override
  String get subscriptionStandardPlanDesc => '스탠다드 플랜';

  @override
  String get subscriptionPremiumPlanDesc => '프리미엄 플랜';

  @override
  String get subscriptionRestoreTitle => '구매 복원';

  @override
  String get subscriptionRestoreSuccess => '구매가 복원되었습니다';

  @override
  String get subscriptionRestoreFailed => '복원할 구매가 없습니다';

  @override
  String get subscriptionNotConfigured => '구독 서비스 준비 중입니다';

  @override
  String get notificationSettingsTitle => '알림 설정';

  @override
  String get notificationSettingsDesc =>
      '알림 종류별로 푸시 알림 수신 여부를 설정할 수 있습니다. 앱 내 알림은 항상 표시됩니다.';

  @override
  String get notificationSettingsMatch => '매칭 알림';

  @override
  String get notificationSettingsMatchDesc => '매칭 요청, 수락, 거절 알림';

  @override
  String get notificationSettingsMessage => '채팅 알림';

  @override
  String get notificationSettingsMessageDesc => '새 메시지 수신 알림';

  @override
  String get notificationSettingsVerification => '인증 알림';

  @override
  String get notificationSettingsVerificationDesc => '매니저 인증 승인/반려 알림';

  @override
  String get notificationSettingsSystem => '시스템 알림';

  @override
  String get notificationSettingsSystemDesc => '공지사항, 구독 만료 등';

  @override
  String get notificationSettingsFcmNote =>
      '푸시 알림은 Firebase 설정 후 활성화됩니다. 앱 내 알림은 항상 수신됩니다.';

  @override
  String get notificationSettingsSaved => '알림 설정이 저장되었습니다';

  @override
  String get matchDetailTitle => '매칭 상세';

  @override
  String get matchDetailNotFound => '매칭 정보를 찾을 수 없습니다';

  @override
  String get matchDetailClientA => '회원 A';

  @override
  String get matchDetailClientB => '회원 B';

  @override
  String get matchDetailCreatedBy => '생성자';

  @override
  String get matchDetailCreatedAt => '생성일';

  @override
  String get matchDetailRespondedAt => '응답일';

  @override
  String get matchDetailOpenChat => '채팅 열기';

  @override
  String get matchDetailAcceptConfirm =>
      '이 매칭 요청을 수락하시겠습니까? 수락 시 상대 매니저와 채팅방이 생성됩니다.';

  @override
  String get matchDetailWaitingResponse => '상대 매니저의 응답을 기다리고 있습니다';

  @override
  String get matchHistoryEmpty => '매칭 이력이 없습니다';

  @override
  String get regStep6Title => '가족/라이프스타일';

  @override
  String get regMaritalHistoryLabel => '결혼 이력';

  @override
  String get regMaritalFirst => '초혼';

  @override
  String get regMaritalRemarriage => '재혼';

  @override
  String get regMaritalDivorced => '이혼';

  @override
  String get regHasChildrenLabel => '자녀 유무';

  @override
  String get regChildrenCountLabel => '자녀 수';

  @override
  String get regFamilyDetailLabel => '가족 관계';

  @override
  String get regFamilyDetailHint => '예: 1남2녀 중 장남';

  @override
  String get regParentsStatusLabel => '부모님 상태';

  @override
  String get regParentsBothAlive => '양부모 건재';

  @override
  String get regParentsFatherOnly => '부친만';

  @override
  String get regParentsMotherOnly => '모친만';

  @override
  String get regParentsDeceased => '모두 별세';

  @override
  String get regDrinkingLabel => '음주';

  @override
  String get regDrinkingNone => '안 함';

  @override
  String get regDrinkingSocial => '가끔';

  @override
  String get regDrinkingRegular => '자주';

  @override
  String get regSmokingLabel => '흡연';

  @override
  String get regSmokingNone => '안 함';

  @override
  String get regSmokingSometimes => '가끔';

  @override
  String get regSmokingRegular => '자주';

  @override
  String get regAssetRangeLabel => '자산 범위';

  @override
  String get regAssetRange1 => '1억 미만';

  @override
  String get regAssetRange2 => '1~3억';

  @override
  String get regAssetRange3 => '3~5억';

  @override
  String get regAssetRange4 => '5~10억';

  @override
  String get regAssetRange5 => '10억 이상';

  @override
  String get regResidenceAreaLabel => '거주 지역';

  @override
  String get regResidenceAreaHint => '예: 서울 강남구';

  @override
  String get regResidenceTypeLabel => '거주 형태';

  @override
  String get regResidenceOwn => '자가';

  @override
  String get regResidenceRentDeposit => '전세';

  @override
  String get regResidenceRentMonthly => '월세';

  @override
  String get regResidenceWithParents => '부모님 동거';

  @override
  String get regHealthNotesLabel => '건강 특이사항';

  @override
  String get regHealthNotesHint => '특이사항이 있으면 입력하세요';

  @override
  String get regPersonalityTypeLabel => '성격 유형 (MBTI 등)';

  @override
  String get regPersonalityTypeHint => '예: ENFP';

  @override
  String get profileFamilyTitle => '가족 정보';

  @override
  String get profileLifestyleTitle => '라이프스타일';

  @override
  String get profileIdealPartnerTitle => '이상형 조건';

  @override
  String get profileResidenceTitle => '자산/거주';

  @override
  String get profilePersonalityTitle => '성격';

  @override
  String get profileMaritalHistory => '결혼이력';

  @override
  String get profileChildren => '자녀';

  @override
  String profileChildrenCount(int count) {
    return '$count명';
  }

  @override
  String get profileFamilyDetail => '가족관계';

  @override
  String get profileParentsStatus => '부모님';

  @override
  String get profileDrinking => '음주';

  @override
  String get profileSmoking => '흡연';

  @override
  String get profileHealthNotes => '건강';

  @override
  String get profilePersonalityType => '성격유형';

  @override
  String get profileAssetRange => '자산';

  @override
  String get profileResidenceArea => '거주지';

  @override
  String get profileResidenceType => '거주형태';

  @override
  String get profileIdealAge => '희망 나이';

  @override
  String get profileIdealHeight => '희망 키';

  @override
  String get profileIdealEducation => '희망 학력';

  @override
  String get profileIdealIncome => '희망 연소득';

  @override
  String get profileIdealReligion => '희망 종교';

  @override
  String get profileIdealNotes => '기타 조건';

  @override
  String profileIdealAgeRange(int min, int max) {
    return '$min~$max세';
  }

  @override
  String profileIdealHeightRange(int min, int max) {
    return '$min~${max}cm';
  }

  @override
  String get marketplaceFilterDrinking => '음주';

  @override
  String get marketplaceFilterSmoking => '흡연';

  @override
  String get marketplaceFilterMaritalHistory => '결혼이력';

  @override
  String get marketplaceFilterResidenceArea => '거주지';

  @override
  String get marketplaceFilterResidenceHint => '지역명 입력';

  @override
  String get crmNotesTitle => '메모 & 타임라인';

  @override
  String get crmNoteAdd => '메모 추가';

  @override
  String get crmNoteTypeGeneral => '일반';

  @override
  String get crmNoteTypePreference => '선호도';

  @override
  String get crmNoteTypeMeetingFeedback => '미팅 후기';

  @override
  String get crmNoteTypeSchedule => '일정';

  @override
  String get crmNoteContentHint => '메모 내용을 입력하세요';

  @override
  String get crmNoteScheduleAt => '일정 날짜';

  @override
  String get crmNoteSaved => '메모가 저장되었습니다';

  @override
  String get crmNoteDeleted => '메모가 삭제되었습니다';

  @override
  String get crmNoteDeleteConfirm => '이 메모를 삭제하시겠습니까?';

  @override
  String get crmNoteEmpty => '아직 메모가 없습니다';

  @override
  String get crmNoteCompleted => '완료';

  @override
  String get crmScheduleTitle => '예정 일정';

  @override
  String get crmScheduleEmpty => '예정된 일정이 없습니다';

  @override
  String homeTodaySchedules(int count) {
    return '예정 일정 $count건';
  }

  @override
  String get customerSupportUrl => 'https://cupplus.channel.io';

  @override
  String regPhotoRemaining(int count) {
    return '최대 $count장';
  }

  @override
  String get landingHeroTitle => '당신의 매칭,\n한 차원 높게';

  @override
  String get landingHeroSubtitle => '결혼정보회사 매니저를 위한\n올인원 매칭 관리 플랫폼';

  @override
  String get landingFeature1Title => '스마트 매칭';

  @override
  String get landingFeature1Desc => '회원 데이터 기반 최적의 매칭 추천';

  @override
  String get landingFeature2Title => '실시간 소통';

  @override
  String get landingFeature2Desc => '매니저간 즉시 채팅으로 빠른 매칭 성사';

  @override
  String get landingFeature3Title => '체계적 관리';

  @override
  String get landingFeature3Desc => '회원 등록부터 계약까지 한 곳에서';

  @override
  String get landingCta => '지금 시작하기';

  @override
  String get landingLoginPrompt => '이미 계정이 있으신가요?';

  @override
  String get profileDetailMatchContext => '매칭 요청에 포함된 회원입니다';

  @override
  String get matchSheetVerificationRequired => '매니저 인증이 필요합니다';

  @override
  String get matchSheetVerificationBody => '매칭을 수락/거절하려면 매니저 인증을 먼저 완료해주세요.';

  @override
  String get matchSheetGoVerify => '인증하러 가기';
}
