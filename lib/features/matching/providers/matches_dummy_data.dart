import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/models/client_summary.dart';
import '../models/match_summary.dart';

part 'matches_dummy_data.g.dart';

const _clientKimSeoYeon = ClientSummary(
  id: '1',
  fullName: '김서연',
  gender: 'F',
  birthYear: 1995,
  occupation: '마케팅 매니저',
  company: '네이버',
  education: '서울대 경영학과',
  heightCm: 165,
  isVerified: true,
);

const _clientLeeJunHo = ClientSummary(
  id: '2',
  fullName: '이준호',
  gender: 'M',
  birthYear: 1992,
  occupation: '소프트웨어 엔지니어',
  company: '삼성전자',
  education: 'KAIST 컴퓨터공학',
  heightCm: 178,
  isVerified: true,
);

const _clientParkJiEun = ClientSummary(
  id: '3',
  fullName: '박지은',
  gender: 'F',
  birthYear: 1994,
  occupation: '변호사',
  company: '김앤장',
  education: '고려대 법학전문대학원',
  heightCm: 168,
);

const _clientChoiMinSu = ClientSummary(
  id: '4',
  fullName: '최민수',
  gender: 'M',
  birthYear: 1990,
  occupation: '외과 전문의',
  company: '서울아산병원',
  education: '연세대 의학과',
  heightCm: 181,
  isVerified: true,
);

const _clientJeongHaEun = ClientSummary(
  id: '5',
  fullName: '정하은',
  gender: 'F',
  birthYear: 1996,
  occupation: 'UX 디자이너',
  company: '카카오',
  education: '홍익대 시각디자인과',
  heightCm: 163,
);

const _clientKangDongHyun = ClientSummary(
  id: '6',
  fullName: '강동현',
  gender: 'M',
  birthYear: 1991,
  occupation: '금융 애널리스트',
  company: 'JP모간',
  education: '서강대 경제학과',
  heightCm: 176,
  isVerified: true,
);

const _clientYoonSoMin = ClientSummary(
  id: '7',
  fullName: '윤소민',
  gender: 'F',
  birthYear: 1993,
  occupation: '치과의사',
  company: '연세치과',
  education: '경희대 치의학과',
  heightCm: 162,
  isVerified: true,
);

const _clientShinWooJin = ClientSummary(
  id: '8',
  fullName: '신우진',
  gender: 'M',
  birthYear: 1993,
  occupation: '건축가',
  company: '삼우설계',
  education: '한양대 건축학과',
  heightCm: 183,
);

@riverpod
List<MatchSummary> allMatches(Ref ref) {
  final now = DateTime.now();
  return [
    MatchSummary(
      id: 'm1',
      clientA: _clientKimSeoYeon,
      clientB: _clientKangDongHyun,
      status: 'pending',
      matchedAt: now.subtract(const Duration(hours: 2)),
      notes: '재테크 관심 공통',
    ),
    MatchSummary(
      id: 'm2',
      clientA: _clientYoonSoMin,
      clientB: _clientLeeJunHo,
      status: 'pending',
      matchedAt: now.subtract(const Duration(hours: 5)),
    ),
    MatchSummary(
      id: 'm3',
      clientA: _clientJeongHaEun,
      clientB: _clientShinWooJin,
      status: 'pending',
      matchedAt: now.subtract(const Duration(days: 1)),
      notes: '전시회 관람 취미',
    ),
    MatchSummary(
      id: 'm4',
      clientA: _clientParkJiEun,
      clientB: _clientChoiMinSu,
      status: 'accepted',
      matchedAt: now.subtract(const Duration(days: 3)),
      respondedAt: now.subtract(const Duration(days: 2)),
      notes: '첫 만남 장소 조율 중',
    ),
    MatchSummary(
      id: 'm5',
      clientA: _clientKimSeoYeon,
      clientB: _clientChoiMinSu,
      status: 'meeting_scheduled',
      matchedAt: now.subtract(const Duration(days: 7)),
      respondedAt: now.subtract(const Duration(days: 5)),
      notes: '2/15 강남 카페 만남 예정',
    ),
    MatchSummary(
      id: 'm6',
      clientA: _clientYoonSoMin,
      clientB: _clientKangDongHyun,
      status: 'completed',
      matchedAt: now.subtract(const Duration(days: 14)),
      respondedAt: now.subtract(const Duration(days: 10)),
      notes: '양측 만족, 2차 진행',
    ),
    MatchSummary(
      id: 'm7',
      clientA: _clientJeongHaEun,
      clientB: _clientLeeJunHo,
      status: 'declined',
      matchedAt: now.subtract(const Duration(days: 5)),
      respondedAt: now.subtract(const Duration(days: 4)),
      notes: '남측 거절 - 거리 문제',
    ),
    MatchSummary(
      id: 'm8',
      clientA: _clientParkJiEun,
      clientB: _clientShinWooJin,
      status: 'declined',
      matchedAt: now.subtract(const Duration(days: 10)),
      respondedAt: now.subtract(const Duration(days: 9)),
    ),
  ];
}

@riverpod
List<MatchSummary> pendingMatches(Ref ref) {
  return ref
      .watch(allMatchesProvider)
      .where((m) => m.status == 'pending')
      .toList();
}

@riverpod
List<MatchSummary> activeMatches(Ref ref) {
  return ref
      .watch(allMatchesProvider)
      .where((m) => m.status == 'accepted' || m.status == 'meeting_scheduled')
      .toList();
}

@riverpod
List<MatchSummary> doneMatches(Ref ref) {
  return ref
      .watch(allMatchesProvider)
      .where((m) => m.status == 'completed' || m.status == 'declined')
      .toList();
}
