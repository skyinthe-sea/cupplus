import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/marketplace_filter.dart';
import '../models/marketplace_profile.dart';

part 'marketplace_providers.g.dart';

@riverpod
List<MarketplaceProfile> allMarketplaceProfiles(Ref ref) {
  final now = DateTime.now();
  return [
    MarketplaceProfile(
      id: 'mp1',
      fullName: '김서연',
      gender: 'F',
      birthYear: 1995,
      occupation: '마케팅 매니저',
      company: '네이버',
      education: '서울대 경영학과',
      heightCm: 165,
      isVerified: true,
      religion: '무교',
      annualIncomeRange: '5,000만~7,000만',
      regionName: '서울 강남',
      managerName: '박매니저',
      registeredAt: now.subtract(const Duration(days: 3)),
      bio: '활발하고 긍정적인 성격입니다. 여행과 맛집 탐방을 좋아하고, 주말에는 요가를 즐깁니다.',
      hobbies: ['여행', '요가', '맛집탐방', '독서'],
      idealPartnerNotes: '유머감각이 있고 대화가 잘 통하는 분을 선호합니다. 함께 여행 다니는 것을 즐기시는 분이면 좋겠습니다.',
      verifiedDocuments: ['재직증명서', '학위증명서'],
      matchRequestCount: 5,
    ),
    MarketplaceProfile(
      id: 'mp2',
      fullName: '이준호',
      gender: 'M',
      birthYear: 1992,
      occupation: '소프트웨어 엔지니어',
      company: '삼성전자',
      education: 'KAIST 컴퓨터공학',
      heightCm: 178,
      isVerified: true,
      religion: '기독교',
      annualIncomeRange: '7,000만~1억',
      regionName: '서울 서초',
      managerName: '김매니저',
      registeredAt: now.subtract(const Duration(days: 5)),
      bio: '차분하고 성실한 성격입니다. 기술 분야에서 일하지만 문화생활도 즐기는 편입니다.',
      hobbies: ['등산', '코딩', '영화감상', '와인'],
      idealPartnerNotes: '서로의 시간을 존중하면서도 함께하는 시간을 소중히 여기는 분이면 좋겠습니다.',
      verifiedDocuments: ['재직증명서', '학위증명서', '소득증명서'],
      matchRequestCount: 8,
    ),
    MarketplaceProfile(
      id: 'mp3',
      fullName: '박지은',
      gender: 'F',
      birthYear: 1994,
      occupation: '변호사',
      company: '김앤장',
      education: '고려대 법학전문대학원',
      heightCm: 168,
      religion: '불교',
      annualIncomeRange: '1억~1억5천만',
      regionName: '서울 강남',
      managerName: '이매니저',
      registeredAt: now.subtract(const Duration(days: 7)),
      bio: '법조계에서 일하고 있지만 일과 삶의 균형을 중요하게 생각합니다. 클래식 음악과 미술관 방문을 좋아합니다.',
      hobbies: ['클래식', '미술관', '필라테스', '와인'],
      idealPartnerNotes: '지적인 대화가 가능하고, 서로의 커리어를 응원해줄 수 있는 분을 찾고 있습니다.',
      verifiedDocuments: ['명함'],
      matchRequestCount: 3,
    ),
    MarketplaceProfile(
      id: 'mp4',
      fullName: '최민수',
      gender: 'M',
      birthYear: 1990,
      occupation: '외과 전문의',
      company: '서울아산병원',
      education: '연세대 의학과',
      heightCm: 181,
      isVerified: true,
      religion: '무교',
      annualIncomeRange: '1억5천만~2억',
      regionName: '서울 송파',
      managerName: '박매니저',
      registeredAt: now.subtract(const Duration(days: 2)),
      bio: '바쁜 일상이지만 주말에는 충분히 함께 시간을 보낼 수 있습니다. 요리와 운동을 좋아합니다.',
      hobbies: ['요리', '헬스', '골프', '자동차'],
      idealPartnerNotes: '따뜻하고 이해심이 많은 분이면 좋겠습니다. 의사라는 직업 특성을 이해해주실 수 있는 분을 선호합니다.',
      verifiedDocuments: ['재직증명서', '학위증명서', '소득증명서'],
      matchRequestCount: 12,
    ),
    MarketplaceProfile(
      id: 'mp5',
      fullName: '정하은',
      gender: 'F',
      birthYear: 1996,
      occupation: 'UX 디자이너',
      company: '카카오',
      education: '홍익대 시각디자인과',
      heightCm: 163,
      religion: '무교',
      annualIncomeRange: '4,000만~5,000만',
      regionName: '경기 판교',
      managerName: '최매니저',
      registeredAt: now.subtract(const Duration(days: 1)),
      bio: '창의적인 일을 하고 있어요. 새로운 카페 찾아가는 걸 좋아하고, 주말에는 그림을 그립니다.',
      hobbies: ['그림', '카페투어', '전시회', '사진'],
      idealPartnerNotes: '예술적 감성을 공유할 수 있는 분이면 좋겠어요. 같이 전시회 다니는 걸 좋아하시는 분!',
      verifiedDocuments: ['재직증명서'],
      matchRequestCount: 6,
    ),
    MarketplaceProfile(
      id: 'mp6',
      fullName: '강동현',
      gender: 'M',
      birthYear: 1991,
      occupation: '금융 애널리스트',
      company: 'JP모간',
      education: '서강대 경제학과',
      heightCm: 176,
      isVerified: true,
      religion: '천주교',
      annualIncomeRange: '1억~1억5천만',
      regionName: '서울 여의도',
      managerName: '김매니저',
      registeredAt: now.subtract(const Duration(days: 10)),
      bio: '금융업에 종사하고 있습니다. 평일에는 바쁘지만 주말에는 여유롭게 보내려고 합니다.',
      hobbies: ['테니스', '독서', '재테크', '여행'],
      idealPartnerNotes: '밝고 활발한 성격의 분을 선호합니다. 함께 성장할 수 있는 파트너를 찾고 있습니다.',
      verifiedDocuments: ['재직증명서', '학위증명서', '소득증명서'],
      matchRequestCount: 7,
    ),
    MarketplaceProfile(
      id: 'mp7',
      fullName: '윤소민',
      gender: 'F',
      birthYear: 1993,
      occupation: '치과의사',
      company: '연세치과',
      education: '경희대 치의학과',
      heightCm: 162,
      isVerified: true,
      religion: '기독교',
      annualIncomeRange: '7,000만~1억',
      regionName: '서울 강남',
      managerName: '이매니저',
      registeredAt: now.subtract(const Duration(days: 6)),
      bio: '치과의사로 일하고 있어요. 환자분들에게 밝은 미소를 드리는 게 보람있습니다. 성격이 밝은 편이에요.',
      hobbies: ['수영', '베이킹', '반려동물', '뮤지컬'],
      idealPartnerNotes: '성실하고 가정적인 분이면 좋겠습니다. 반려동물을 좋아하시는 분이면 더 좋아요!',
      verifiedDocuments: ['재직증명서', '학위증명서'],
      matchRequestCount: 9,
    ),
    MarketplaceProfile(
      id: 'mp8',
      fullName: '신우진',
      gender: 'M',
      birthYear: 1993,
      occupation: '건축가',
      company: '삼우설계',
      education: '한양대 건축학과',
      heightCm: 183,
      religion: '무교',
      annualIncomeRange: '5,000만~7,000만',
      regionName: '서울 마포',
      managerName: '최매니저',
      registeredAt: now.subtract(const Duration(days: 4)),
      bio: '건축 설계를 하고 있습니다. 공간과 디자인에 대한 관심이 많고, 여행하며 건축물 보는 걸 좋아해요.',
      hobbies: ['건축투어', '사진', '캠핑', '드로잉'],
      idealPartnerNotes: '함께 여행하며 새로운 경험을 공유할 수 있는 분을 찾습니다.',
      verifiedDocuments: ['명함', '학위증명서'],
      matchRequestCount: 4,
    ),
    MarketplaceProfile(
      id: 'mp9',
      fullName: '한예진',
      gender: 'F',
      birthYear: 1995,
      occupation: '외교관',
      company: '외교부',
      education: '서울대 국제학과',
      heightCm: 170,
      isVerified: true,
      religion: '무교',
      annualIncomeRange: '5,000만~7,000만',
      regionName: '서울 종로',
      managerName: '박매니저',
      registeredAt: now.subtract(const Duration(days: 8)),
      bio: '외교관으로 다양한 나라에서 근무한 경험이 있습니다. 영어, 불어 가능하며, 다문화에 열린 마음을 가지고 있습니다.',
      hobbies: ['외국어', '요리', '와인', '클래식'],
      idealPartnerNotes: '글로벌 마인드를 가진 분이면 좋겠습니다. 해외 생활에 대한 이해가 있으신 분을 선호합니다.',
      verifiedDocuments: ['재직증명서', '학위증명서'],
      matchRequestCount: 11,
    ),
    MarketplaceProfile(
      id: 'mp10',
      fullName: '오성민',
      gender: 'M',
      birthYear: 1989,
      occupation: '사업가',
      company: '(주)테크밸리',
      education: '서울대 경영학과 MBA',
      heightCm: 180,
      isVerified: true,
      religion: '불교',
      annualIncomeRange: '2억 이상',
      regionName: '서울 강남',
      managerName: '김매니저',
      registeredAt: now.subtract(const Duration(days: 12)),
      bio: 'IT 스타트업을 운영하고 있습니다. 바쁜 일상이지만 가정을 꾸리고 싶은 마음이 큽니다.',
      hobbies: ['골프', '승마', '와인', '독서'],
      idealPartnerNotes: '서로를 존중하고 응원할 수 있는 따뜻한 분을 찾고 있습니다. 외모보다 내면을 중시합니다.',
      verifiedDocuments: ['재직증명서', '소득증명서'],
      matchRequestCount: 15,
    ),
    MarketplaceProfile(
      id: 'mp11',
      fullName: '임수아',
      gender: 'F',
      birthYear: 1997,
      occupation: '약사',
      company: '올리브약국',
      education: '이화여대 약학과',
      heightCm: 160,
      religion: '천주교',
      annualIncomeRange: '5,000만~7,000만',
      regionName: '서울 송파',
      managerName: '이매니저',
      registeredAt: now.subtract(const Duration(days: 9)),
      bio: '약국을 운영하고 있습니다. 건강한 라이프스타일을 추구하며, 주말에는 산책과 브런치를 즐깁니다.',
      hobbies: ['산책', '브런치', '플라워클래스', '독서'],
      idealPartnerNotes: '건강한 생활습관을 가진 분이면 좋겠어요. 같이 산책하고 맛있는 음식 먹으러 다니고 싶습니다.',
      verifiedDocuments: ['재직증명서', '학위증명서'],
      matchRequestCount: 7,
    ),
    MarketplaceProfile(
      id: 'mp12',
      fullName: '장현우',
      gender: 'M',
      birthYear: 1991,
      occupation: '항공기 조종사',
      company: '대한항공',
      education: '한국항공대 항공운항학과',
      heightCm: 182,
      isVerified: true,
      religion: '무교',
      annualIncomeRange: '1억~1억5천만',
      regionName: '서울 강서',
      managerName: '최매니저',
      registeredAt: now.subtract(const Duration(days: 11)),
      bio: '파일럿으로 일하고 있습니다. 스케줄이 불규칙하지만 쉬는 날에는 오롯이 함께할 수 있습니다.',
      hobbies: ['스쿠버다이빙', '사진', '여행', '와인'],
      idealPartnerNotes: '불규칙한 스케줄을 이해해주실 수 있는 분이면 좋겠습니다. 쉬는 날 같이 여행 다니는 걸 좋아합니다.',
      verifiedDocuments: ['재직증명서', '학위증명서', '소득증명서'],
      matchRequestCount: 10,
    ),
  ];
}

@riverpod
class MarketplaceFilterNotifier extends _$MarketplaceFilterNotifier {
  @override
  MarketplaceFilter build() => const MarketplaceFilter();

  void updateGender(String? gender) {
    state = state.copyWith(gender: () => gender);
  }

  void updateAgeRange(int? min, int? max) {
    state = state.copyWith(
      minAge: () => min,
      maxAge: () => max,
    );
  }

  void updateHeightRange(int? min, int? max) {
    state = state.copyWith(
      minHeight: () => min,
      maxHeight: () => max,
    );
  }

  void updateReligion(String? religion) {
    state = state.copyWith(religion: () => religion);
  }

  void updateVerifiedOnly(bool value) {
    state = state.copyWith(isVerifiedOnly: value);
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(
      searchQuery: () => query?.isEmpty == true ? null : query,
    );
  }

  void clearFilters() {
    state = MarketplaceFilter(searchQuery: state.searchQuery);
  }

  void clearAll() {
    state = const MarketplaceFilter();
  }
}

@riverpod
List<MarketplaceProfile> filteredMarketplaceProfiles(Ref ref) {
  final all = ref.watch(allMarketplaceProfilesProvider);
  final filter = ref.watch(marketplaceFilterNotifierProvider);

  return all.where((p) {
    if (filter.gender != null && p.gender != filter.gender) return false;
    if (filter.minAge != null && p.age < filter.minAge!) return false;
    if (filter.maxAge != null && p.age > filter.maxAge!) return false;
    if (filter.minHeight != null &&
        (p.heightCm == null || p.heightCm! < filter.minHeight!)) {
      return false;
    }
    if (filter.maxHeight != null &&
        (p.heightCm == null || p.heightCm! > filter.maxHeight!)) {
      return false;
    }
    if (filter.religion != null && p.religion != filter.religion) return false;
    if (filter.isVerifiedOnly && !p.isVerified) return false;
    if (filter.searchQuery != null) {
      final query = filter.searchQuery!.toLowerCase();
      final searchable = [
        p.fullName,
        p.occupation,
        p.company ?? '',
        p.education ?? '',
        p.regionName ?? '',
        ...p.hobbies,
      ].join(' ').toLowerCase();
      if (!searchable.contains(query)) return false;
    }
    return true;
  }).toList();
}

@riverpod
MarketplaceProfile? marketplaceProfileById(Ref ref, String id) {
  final all = ref.watch(allMarketplaceProfilesProvider);
  try {
    return all.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
}

@riverpod
List<MarketplaceProfile> femaleProfiles(Ref ref) {
  return ref
      .watch(filteredMarketplaceProfilesProvider)
      .where((p) => p.gender == 'F')
      .toList();
}

@riverpod
List<MarketplaceProfile> maleProfiles(Ref ref) {
  return ref
      .watch(filteredMarketplaceProfilesProvider)
      .where((p) => p.gender == 'M')
      .toList();
}
