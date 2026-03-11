import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/client_summary.dart';
import '../models/home_stats.dart';

part 'home_dummy_data.g.dart';

@riverpod
List<ClientSummary> recommendedClients(Ref ref) {
  return const [
    ClientSummary(
      id: '1',
      fullName: '김서연',
      gender: 'F',
      birthYear: 1995,
      occupation: '마케팅 매니저',
      company: '네이버',
      education: '서울대 경영학과',
      heightCm: 165,
      isVerified: true,
    ),
    ClientSummary(
      id: '2',
      fullName: '이준호',
      gender: 'M',
      birthYear: 1992,
      occupation: '소프트웨어 엔지니어',
      company: '삼성전자',
      education: 'KAIST 컴퓨터공학',
      heightCm: 178,
      isVerified: true,
      matchStatus: 'pending',
    ),
    ClientSummary(
      id: '3',
      fullName: '박지은',
      gender: 'F',
      birthYear: 1994,
      occupation: '변호사',
      company: '김앤장',
      education: '고려대 법학전문대학원',
      heightCm: 168,
    ),
    ClientSummary(
      id: '4',
      fullName: '최민수',
      gender: 'M',
      birthYear: 1990,
      occupation: '외과 전문의',
      company: '서울아산병원',
      education: '연세대 의학과',
      heightCm: 181,
      isVerified: true,
      matchStatus: 'accepted',
    ),
    ClientSummary(
      id: '5',
      fullName: '정하은',
      gender: 'F',
      birthYear: 1996,
      occupation: 'UX 디자이너',
      company: '카카오',
      education: '홍익대 시각디자인과',
      heightCm: 163,
    ),
  ];
}

@riverpod
HomeStats homeStats(Ref ref) {
  return const HomeStats(
    pendingMatches: 3,
    todayMatches: 1,
    pendingVerifications: 5,
    newMessages: 8,
  );
}

@riverpod
String homeTipText(Ref ref) {
  return '프로필 정보가 상세할수록 매칭 성공률이 높아집니다. 회원의 취미와 가치관도 함께 기록해보세요!';
}
