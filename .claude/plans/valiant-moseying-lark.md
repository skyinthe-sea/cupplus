# 3가지 작업 구현 계획

## 1. 연소득 표시 포맷팅 (간단)

**문제**: `idealIncomeRange`가 raw 값(`50m_70m`)으로 표시됨. `annualIncomeRange`는 `_incomeLabel()` 헬퍼로 포맷팅 완료.

**수정**:
- `lib/features/matching/views/profile_detail_screen.dart` — `idealIncomeRange` 표시에 `_incomeLabel()` 적용
- `lib/features/profile/views/my_client_detail_screen.dart` — 동일

---

## 2. 고객센터 이메일 문의 화면 (중간)

**현재**: channel.io 외부 링크만 존재
**구현**: 인앱 고객센터 화면 (이메일: myclick90@gmail.com)

**파일**: `lib/features/profile/views/customer_support_screen.dart` (신규)

**UI 구성**:
- AppBar: "고객센터"
- 헤더 카드: 앱 로고 + "도움이 필요하신가요?"
- 이메일 문의 카드: 아이콘 + myclick90@gmail.com + "이메일 보내기" 버튼 (mailto: 링크)
- FAQ 섹션 (아코디언): 자주 묻는 질문 3-4개 (구독, 매칭, 인증 관련)
- 운영시간 안내: "평일 10:00 - 18:00 (주말/공휴일 제외)"
- 하단: 앱 버전 표시

**라우팅**: `/my/support` 추가
**my_screen.dart**: onTap을 외부 URL → 내부 라우트로 변경
**i18n**: 고객센터 관련 문자열 추가

---

## 3. CRM 강화 — 태그/라벨 + 검색 (핵심)

### 3a. 태그 시스템

**DB 마이그레이션**: `client_tags` 테이블
```sql
CREATE TABLE client_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  manager_id UUID NOT NULL REFERENCES managers(id),
  tag TEXT NOT NULL,
  color TEXT, -- hex color code
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(client_id, tag, manager_id)
);
```

**프리셋 태그** (constants에 정의):
- VIP, 급한, 신규, 장기, 재상담, 적극적, 소극적, 까다로움

**UI**:
- 클라이언트 상세 화면: 태그 표시 (Chip 리스트) + 태그 추가/삭제
- 내 회원 목록: 태그 필터 (다중 선택)
- 태그 추가 시: 프리셋 선택 또는 커스텀 입력

**Provider**:
- `clientTagsProvider(clientId)` — 해당 클라이언트의 태그 목록
- `addClientTag(clientId, tag)` — 태그 추가
- `removeClientTag(tagId, clientId)` — 태그 삭제
- `allMyTagsProvider` — 내가 사용한 모든 태그 (필터용)

### 3b. 검색 기능 강화

**내 회원 목록 검색 확장** (`my_clients_screen.dart`):
- 현재: 이름만 검색
- 확장: 이름 + 직업 + 회사 + 메모 내용 + 태그
- 태그 필터 칩: 검색바 아래에 태그 필터 UI

**Provider 수정**:
- `myClientsProvider`에 태그 필터 파라미터 추가
- 검색 시 `client_notes` 테이블도 조인하여 메모 내용 검색

---

## 수정/생성 파일 목록

| 파일 | 작업 |
|---|---|
| `lib/features/matching/views/profile_detail_screen.dart` | idealIncome 포맷팅 |
| `lib/features/profile/views/my_client_detail_screen.dart` | idealIncome 포맷팅 + 태그 UI |
| `lib/features/profile/views/customer_support_screen.dart` | **신규** — 고객센터 화면 |
| `lib/features/profile/views/my_screen.dart` | 고객센터 라우트 변경 |
| `lib/app/router.dart` | 라우트 추가 |
| `supabase/migrations/YYYYMMDD_client_tags.sql` | **신규** — 태그 테이블 |
| `lib/features/profile/providers/client_tags_provider.dart` | **신규** — 태그 Provider |
| `lib/features/profile/widgets/client_tags_section.dart` | **신규** — 태그 UI 위젯 |
| `lib/features/profile/views/my_clients_screen.dart` | 태그 필터 + 확장 검색 |
| `lib/features/profile/providers/my_clients_provider.dart` | 검색/필터 확장 |
| `lib/l10n/app_ko.arb` / `app_en.arb` | 문자열 추가 |

## 검증
1. `flutter gen-l10n` + `dart run build_runner build`
2. `flutter analyze` — 에러 없음 확인
3. 연소득 표시 확인 (이상형 섹션)
4. 고객센터 화면 진입 + 이메일 버튼
5. 태그 추가/삭제/필터 동작 확인
