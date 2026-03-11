# CLAUDE.md — CupPlus (결혼정보회사 매니저 플랫폼)

## 기획 문서 (반드시 참조)

구현 작업 전에 아래 기획 파일들을 먼저 읽을 것:

| 파일 | 내용 |
|---|---|
| `docs/planning/home_screen.md` | 홈 화면 (AppBar/알림, 인사헤더, 빠른액션, 오늘의할일, 활동피드) |
| `docs/planning/matching_tab.md` | 매칭 탭 — 프로필 마켓 (회원탐색, 좋아요, 매칭생성 플로우, 추천알고리즘) |
| `docs/planning/chat_tab.md` | 채팅 탭 (매니저간 채팅, 매칭성사시 자동생성, 읽음확인) |
| `docs/planning/my_tab.md` | 마이 탭 (프로필, 내회원CRUD, 구독관리, 설정, 회원삭제 사이드이펙트) |
| `docs/planning/client_registration.md` | 회원 등록 5스텝 폼 상세 (UI/애니메이션/필드/유효성검사/데이터저장) |
| `docs/planning/verification_and_contract.md` | 매니저 인증 (서류제출→어드민승인) + 간소화 계약서 (체크박스 동의) |
| `docs/planning/push_notification.md` | 푸시 알림 4종 (매칭/채팅/인증/시스템), Edge Function→FCM 아키텍처, 재시도전략, 알림설정 |

### MVP 범위 요약
- **포함**: 홈대시보드, 프로필마켓(좋아요/매칭생성), 채팅(텍스트+이미지), 마이(회원CRUD+구독), 매니저인증, 간소화계약서, 푸시알림(FCM 4종)
- **제외**: 회원서류인증/검토, hand_signature서명, 크로스리전매칭, 어드민웹

### 현재 앱 상태
- Auth(Google/Kakao/Dev): 완성
- UI: 대부분 더미데이터 기반 완성 (Supabase 연동 필요)
- 로컬 Supabase: `127.0.0.1:54321`에서 실행 중, 마이그레이션 적용 완료

---

## Project Overview

CupPlus는 결혼정보회사 매니저를 위한 매칭 관리 플랫폼이다.
한국 시장을 1차 타겟으로 하되, 글로벌 확장(멀티테넌시, 다국어, 다중 통화)을 day-one 아키텍처에 반영한다.

- **앱 이름**: CupPlus (cupplus)
- **플랫폼**: iOS, Android (클라이언트 앱) + Flutter Web PWA (어드민 대시보드)
- **언어**: Dart 3.10+, Flutter
- **백엔드**: Supabase (Auth, Database, Realtime, Storage, Edge Functions)
- **결제**: RevenueCat (purchases_flutter)
- **푸시**: Firebase Cloud Messaging (FCM) via Supabase Edge Functions

---

## Tech Stack & Package Versions

### Core Dependencies

| 패키지 | 버전 | 용도 |
|---|---|---|
| `supabase_flutter` | latest | Supabase 클라이언트 (Auth, DB, Realtime, Storage) |
| `purchases_flutter` | ^9.11.0 | RevenueCat 구독 결제 |
| `firebase_messaging` | ^14.x | FCM 푸시 알림 |
| `flutter_local_notifications` | ^16.x | 포그라운드 알림 표시 |
| `hand_signature` | latest | 전자서명 캔버스 (SVG/PNG 내보내기) |
| `image_picker` | ^1.1.2 | 카메라/갤러리 이미지 선택 |
| `flutter_image_compress` | latest | 이미지 압축 (EXIF 자동 제거) |
| `flutter_riverpod` | latest | Riverpod 상태관리 |
| `riverpod_annotation` | latest | Riverpod 코드 생성 어노테이션 |
| `flutter_screenutil` | ^5.9.3 | 반응형 비례 사이징 |
| `dynamic_color` | ^1.7.0 | Android 12+ 다이나믹 컬러 지원 |
| `flutter_localizations` | SDK | 공식 i18n |
| `intl` | ^0.19.0 | ICU MessageFormat, 한국어 복수형 |

### Dev Dependencies

| 패키지 | 버전 | 용도 |
|---|---|---|
| `flutter_lints` | ^6.0.0 | 린트 규칙 |
| `riverpod_generator` | latest | Riverpod 코드 생성기 |
| `build_runner` | latest | 코드 생성 실행기 |
| `riverpod_lint` | latest | Riverpod 전용 린트 규칙 |
| `custom_lint` | latest | riverpod_lint 의존성 |
| `melos` | latest | 모노레포 관리 (추후 admin_web 분리 시) |

---

## Architecture

### Mono-Repo Structure (목표)

```
cupplus/
├── apps/
│   ├── client_app/        # 매니저용 모바일 앱 (iOS/Android)
│   └── admin_web/         # 대표 어드민 (Flutter Web PWA)
├── packages/
│   ├── core/              # 비즈니스 로직, 리포지토리
│   ├── shared_models/     # Profile, Match, Contract 모델
│   └── shared_services/   # Supabase 클라이언트, Auth 서비스
├── supabase/
│   ├── migrations/        # SQL 마이그레이션
│   └── functions/         # Edge Functions (Deno/TypeScript)
└── CLAUDE.md
```

> MVP 단계에서는 단일 앱(`lib/`)으로 시작하고, admin_web 분리 시점에 Melos 모노레포로 전환한다.

### State Management — Riverpod

- **flutter_riverpod** + **riverpod_annotation** + **riverpod_generator** 사용
- Provider 종류 가이드:
  - `@riverpod` (자동 dispose) — 대부분의 경우 기본 사용
  - `@Riverpod(keepAlive: true)` — Supabase 클라이언트, Auth 상태 등 앱 수명 동안 유지할 것
  - `StreamProvider` — Supabase Realtime 채팅 메시지 등 스트림 데이터
  - `FutureProvider` — 1회성 비동기 fetch (프로필 조회 등)
  - `NotifierProvider` — 복잡한 상태 로직 (매칭 생성 플로우, 폼 상태 등)
- `ref.watch`로 UI 리빌드, `ref.read`로 이벤트 핸들러 내 1회성 접근
- `ConsumerWidget` / `ConsumerStatefulWidget` 사용 (StatelessWidget/StatefulWidget 대신)
- Provider 파일 위치: 각 feature 폴더 내 `providers/` 디렉토리
  ```
  features/matching/
  ├── providers/
  │   ├── match_list_provider.dart
  │   └── match_detail_provider.dart
  ├── views/
  ├── models/
  └── widgets/
  ```
- 코드 생성: `dart run build_runner watch` 로 개발 중 자동 생성

### Folder Convention (단일 앱 단계)

```
lib/
├── main.dart
├── app/
│   ├── app.dart               # MaterialApp 설정
│   └── router.dart            # 라우팅
├── config/
│   ├── theme.dart             # 테마/컬러
│   ├── constants.dart         # 상수
│   └── supabase_config.dart   # Supabase 초기화
├── features/
│   ├── auth/                  # 인증 (로그인, 회원가입)
│   ├── profile/               # 회원 프로필 관리
│   ├── matching/              # 매칭 (생성, 조회, 상태관리)
│   ├── chat/                  # 실시간 채팅
│   ├── contract/              # 계약서/전자서명
│   ├── verification/          # 서류 인증 (재직증명서, 명함 등)
│   ├── subscription/          # 구독/결제
│   └── notification/          # 알림
├── shared/
│   ├── models/                # 공통 데이터 모델
│   ├── services/              # Supabase, FCM 등 서비스
│   ├── widgets/               # 공통 위젯
│   └── utils/                 # 유틸리티
└── l10n/
    ├── app_en.arb             # 영어 번역
    └── app_ko.arb             # 한국어 번역
```

---

## Database Schema (Supabase / PostgreSQL)

### Multi-Tenancy: JWT app_metadata 기반 RLS

모든 테넌트 스코프 테이블에 `region_id` 컬럼을 포함하고, JWT `app_metadata.region_id`를 기반으로 RLS 정책을 적용한다.

```sql
-- 헬퍼 함수: JWT에서 region_id 추출
CREATE OR REPLACE FUNCTION auth.region_id()
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT NULLIF(
    ((current_setting('request.jwt.claims')::jsonb
      ->>'app_metadata')::jsonb ->>'region_id'), ''
  )::text
$$;
```

### Core Tables

```sql
-- 매니저 (사용자)
CREATE TABLE managers (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  region_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'manager', -- 'manager' | 'admin' | 'owner'
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 회원 (고객)
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region_id TEXT NOT NULL,
  manager_id UUID REFERENCES managers(id),
  full_name TEXT NOT NULL,
  gender TEXT NOT NULL,
  birth_date DATE,
  education TEXT,
  occupation TEXT,
  company TEXT,
  annual_income_range TEXT,
  religion TEXT,
  height_cm INT,
  profile_photo_url TEXT,
  status TEXT DEFAULT 'active', -- 'active' | 'paused' | 'matched' | 'withdrawn'
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 매칭
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_a_id UUID REFERENCES clients(id),
  client_b_id UUID REFERENCES clients(id),
  client_a_region TEXT NOT NULL,
  client_b_region TEXT NOT NULL,
  manager_id UUID REFERENCES managers(id),
  status TEXT DEFAULT 'pending', -- 'pending' | 'accepted' | 'declined' | 'meeting_scheduled' | 'completed'
  matched_at TIMESTAMPTZ DEFAULT now(),
  responded_at TIMESTAMPTZ,
  notes TEXT
);

-- 채팅 대화
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_a UUID REFERENCES managers(id),
  participant_b UUID REFERENCES managers(id),
  last_message_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 메시지
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id),
  sender_id UUID REFERENCES managers(id),
  content TEXT,
  type TEXT DEFAULT 'text', -- 'text' | 'image' | 'file'
  image_url TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
-- 인덱스: CREATE INDEX idx_messages_conv_created ON messages(conversation_id, created_at DESC);

-- 읽음 확인
CREATE TABLE read_receipts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id),
  user_id UUID REFERENCES managers(id),
  last_read_message_id UUID REFERENCES messages(id),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(conversation_id, user_id)
);

-- 계약 동의
CREATE TABLE contract_agreements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  manager_id UUID REFERENCES managers(id),
  region_id TEXT NOT NULL,
  contract_version TEXT NOT NULL,          -- 예: 'v1.0'
  contract_hash TEXT NOT NULL,             -- SHA-256 해시
  agreed_at TIMESTAMPTZ DEFAULT now(),
  ip_address INET,
  device_info JSONB,
  signature_storage_path TEXT,             -- 서명 이미지 경로 (선택)
  UNIQUE(client_id, contract_version)
);

-- 서류 인증
CREATE TABLE verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  region_id TEXT NOT NULL,
  document_type TEXT NOT NULL,  -- 'business_card' | 'employment_cert' | 'degree_cert' | 'income_cert'
  storage_path TEXT NOT NULL,
  status TEXT DEFAULT 'pending', -- 'pending' | 'approved' | 'rejected'
  reviewer_id UUID REFERENCES managers(id),
  rejection_reason TEXT,
  expires_at DATE,
  uploaded_at TIMESTAMPTZ DEFAULT now(),
  reviewed_at TIMESTAMPTZ
);

-- FCM 토큰
CREATE TABLE fcm_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  token TEXT NOT NULL,
  platform TEXT NOT NULL, -- 'ios' | 'android'
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, platform)
);

-- 알림
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  type TEXT NOT NULL,  -- 'new_match' | 'new_message' | 'match_response' | 'verification_result'
  status TEXT DEFAULT 'pending', -- 'pending' | 'sent' | 'failed'
  retries INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  sent_at TIMESTAMPTZ
);

-- 일일 매칭 카운터 (무료 티어 제한)
CREATE TABLE daily_match_counts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manager_id UUID REFERENCES managers(id),
  match_date DATE NOT NULL DEFAULT CURRENT_DATE,
  count INT DEFAULT 0,
  UNIQUE(manager_id, match_date)
);
```

### RLS Policy 패턴

```sql
-- 기본 패턴: 자기 region만 조회
CREATE POLICY "region_isolation" ON clients
  FOR ALL USING (region_id = auth.region_id());

-- 크로스 리전 매칭: 양쪽 region 허용
CREATE POLICY "cross_region_match_read" ON matches
  FOR SELECT USING (
    client_a_region = auth.region_id()
    OR client_b_region = auth.region_id()
  );

-- 어드민 전체 접근
CREATE POLICY "admin_full_access" ON clients
  FOR ALL USING (
    (auth.jwt()->>'user_role') = 'admin'
    OR (auth.jwt()->>'user_role') = 'owner'
  );

-- region_id 자동 세팅 트리거
CREATE OR REPLACE FUNCTION set_region_id()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.region_id := auth.region_id();
  RETURN NEW;
END;
$$;
```

### 필수 인덱스

```sql
CREATE INDEX idx_clients_region ON clients(region_id);
CREATE INDEX idx_clients_manager ON clients(manager_id);
CREATE INDEX idx_matches_client_a ON matches(client_a_id);
CREATE INDEX idx_matches_client_b ON matches(client_b_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_messages_conv_created ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_notifications_status ON notifications(status) WHERE status = 'pending';
CREATE INDEX idx_daily_match_manager_date ON daily_match_counts(manager_id, match_date);
```

---

## Subscription Tiers (RevenueCat)

| 티어 | 일일 매칭 | 가격 | RevenueCat Entitlement |
|---|---|---|---|
| Free | 1건/일 | 무료 | (없음 — 서버측 카운터로 제한) |
| Standard | 10건/일 | TBD | `standard` |
| Premium | 무제한 | TBD | `premium` |

### 매칭 제한 로직

```dart
// 간소화된 로직 — 실제 구현 시 서버사이드(Edge Function 또는 RLS)에서 검증
Future<bool> canCreateMatch() async {
  final customerInfo = await Purchases.getCustomerInfo();
  if (customerInfo.entitlements.all["premium"]?.isActive == true) return true;

  final isStandard = customerInfo.entitlements.all["standard"]?.isActive == true;
  final dailyLimit = isStandard ? 10 : 1;

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final result = await supabase
      .from('daily_match_counts')
      .select('count')
      .eq('manager_id', currentUserId)
      .eq('match_date', today)
      .maybeSingle();

  return (result?['count'] ?? 0) < dailyLimit;
}
```

---

## E-Signature (전자서명)

### 법적 근거

- **한국 전자서명법** (법률 제17354호, 2020년 개정): 제3조 — 전자서명은 전자적 형태라는 이유만으로 법적 효력이 부인되지 않음
- **미국 ESIGN Act**: "I Accept" 클릭이 유효한 전자서명
- **EU eIDAS**: Simple Electronic Signature (SES) 수준으로 일반 서비스 계약에 충분

### 구현 방식

1. **체크박스 동의** (필수): 비사전체크 명시적 동의 + 서버 타임스탬프, 사용자 ID, 계약 버전 SHA-256 해시, IP, 디바이스 정보 저장
2. **서명 그리기** (권장): `hand_signature` 패키지로 캔버스 서명 → SVG/PNG로 Supabase private Storage 버킷에 저장

### Post-MVP 고려

- 모두싸인(Modusign) API 연동: 카카오톡 기반 전자서명
- 카카오 인증서: 블록체인 기반 본인 확인

---

## Chat System

### Supabase Realtime 기반

```dart
// 메시지 스트림 (초기 데이터 + 실시간 업데이트)
final messagesStream = supabase
    .from('messages')
    .stream(primaryKey: ['id'])
    .eq('conversation_id', conversationId)
    .order('created_at', ascending: true);
```

### 핵심 규칙

- Realtime 퍼블리싱 활성화: `ALTER PUBLICATION supabase_realtime ADD TABLE messages;`
- 이미지 공유: private `chat-images` 버킷 + Supabase Image Transformation (`?width=200&height=200`)으로 썸네일
- 서명된 URL 사용: 적절한 만료 시간 설정, DB에 서명된 URL 저장 금지
- 페이지네이션: `.range(page * pageSize, (page + 1) * pageSize - 1)` + `created_at DESC`
- 위젯 dispose 시 반드시 채널 해제 (커넥션 누수 방지)

---

## Push Notifications

### 아키텍처 Flow

```
DB 이벤트 (INSERT on notifications)
  → Database Webhook
    → Supabase Edge Function
      → FCM HTTP v1 API
        → 사용자 디바이스
```

### 재시도 전략

- `notifications` 테이블의 `status`/`retries` 컬럼 활용
- 실패 시 `status = 'failed'`, `retries++`
- `pg_cron`으로 주기적 재시도 (지수 백오프, 최대 임계값까지)

---

## Theme & Design System

### Color Palette (Material 3)

```dart
// config/theme.dart
final colorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF2D5A8E),  // Sophisticated Deep Blue
  secondary: const Color(0xFF7B5EA7),   // Muted Violet (DUO Korea 브랜드 참고)
  tertiary: const Color(0xFFB4637A),    // Dusty Rose
);

// Light mode surface: #F8F9FD (블루 언더톤)
// Dark mode surface: #121316 (딥 차콜)
```

### Status Colors (ColorScheme Extension)

| 상태 | 색상 | 용도 |
|---|---|---|
| Pending | Amber | 대기 중인 매칭 |
| Accepted | Green | 수락된 매칭 |
| Declined | Red | 거절된 매칭 |
| Verified | Primary Blue (#2D5A8E) | 인증된 프로필 |

### 디자인 원칙

- 소비자 데이팅 앱(Tinder, Bumble)과 차별화: 사진 중심 스와이프 UI 금지
- **데이터 밀도 > 비주얼 드라마**: 학력, 직업, 가족 정보, 인증 배지가 포함된 구조화된 프로필 카드
- DUO, Sunoo 등 한국 결혼정보회사의 네이비/딥블루 + 따뜻한 악센트 + 충분한 여백 참고
- Android 12+ `dynamic_color` 지원, 미지원 기기에서는 커스텀 스킴 폴백

---

## Image Upload & Document Verification

### 압축 설정 (flutter_image_compress)

| 문서 유형 | 품질 | 최대 해상도 | 예상 크기 |
|---|---|---|---|
| 명함 | 85% | 1920x1080 | 200-400 KB |
| 재직증명서 | 90% | 2048x2048 | 300-600 KB |
| 프로필 사진 | 80% | 1024x1024 | 100-300 KB |

### Storage 구조

```
verification-documents/  (private bucket)
  └── {user_id}/
      ├── business_card/
      ├── employment_cert/
      ├── degree_cert/
      └── income_cert/

chat-images/  (private bucket)
  └── {conversation_id}/
      └── {message_id}.jpg

profile-photos/  (private bucket)
  └── {client_id}/
      └── photo.jpg
```

### PIPA (개인정보보호법) 준수

- 인증 서류 수집 전 명시적 동의 필수
- 목적과 보관 기간 고지
- 삭제 메커니즘 제공
- 위반 시 글로벌 매출의 최대 3% 과징금

---

## Internationalization (i18n)

### 설정

```yaml
# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb  # 한국어가 기본
output-localization-file: app_localizations.dart
```

### 사용법

```dart
// 번역 접근
AppLocalizations.of(context)!.matchFound

// 코드 생성
// flutter gen-l10n
```

### ARB 파일 규칙

- `app_ko.arb`: 한국어 (템플릿/기본)
- `app_en.arb`: 영어
- ICU MessageFormat으로 복수형, 성별 처리
- 키 네이밍: camelCase, feature 접두사 (예: `matchStatusPending`, `chatSendMessage`)

---

## Responsive Design

### 전략

1. **flutter_screenutil**: 디자인 기준 사이즈 `Size(375, 812)` (iPhone 기반)에서 비례 사이징
2. **LayoutBuilder/MediaQuery**: 태블릿 브레이크포인트 (`shortestSide >= 600`)

### ScreenUtil 사용법

```dart
// 초기화
ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (context, child) => child!,
  child: const MyApp(),
);

// 사이징
Container(
  width: 100.w,    // 비례 너비
  height: 50.h,    // 비례 높이
  padding: EdgeInsets.all(16.r),  // 비례 반지름
  child: Text('Hello', style: TextStyle(fontSize: 14.sp)),  // 비례 폰트
);
```

### 태블릿 대응

- MVP: 폰 레이아웃 + `maxWidth` 제약으로 충분
- Post-MVP: 매칭 피드, 프로필 뷰에 사이드바이사이드 패널 레이아웃 추가

---

## Security Rules

### 절대 금지 사항

- `service_role` 키를 클라이언트 앱에 포함하지 않는다 (모든 RLS 우회됨)
- `user_metadata`에 권한 정보를 저장하지 않는다 (사용자가 수정 가능)
- 서명된 URL을 DB에 저장하지 않는다 (만료 후 무효)
- 인증 서류의 원본 URL을 클라이언트에 노출하지 않는다

### 필수 보안 사항

- 권한 정보는 `app_metadata`에만 저장 (서버 사이드에서만 수정 가능)
- Admin 접근: Custom Access Token Auth Hook으로 JWT에 `user_role` 주입
- Admin 계정: MFA 필수
- 서류 접근: 단기 서명 URL (300-3600초)로 온디맨드 생성
- 첫 Admin 계정: Supabase SQL 에디터에서 직접 생성

---

## Admin Dashboard (Flutter Web PWA)

### 왜 웹인가

- APK 사이드로딩 없이 즉시 업데이트
- 데스크톱에서 데이터 집약적 작업 (인증 서류 검토, 매칭 관리)
- Play Store 리뷰 프로세스 불필요

### 보안 모델

- 클라이언트 앱과 동일한 Supabase `anon` 키 사용
- RLS에서 `(auth.jwt()->>'user_role') = 'admin'` 체크로 권한 분리
- 디바이스 핑거프린트 저장 (`admin_devices` 테이블)
- 로그인 시 디바이스 검증

---

## Coding Conventions

### Dart/Flutter

- 파일명: `snake_case.dart`
- 클래스명: `PascalCase`
- 변수/함수명: `camelCase`
- private 멤버: `_prefix`
- const 가능한 위젯은 항상 `const` 사용
- 불필요한 주석 금지 — 코드가 자체 설명적이어야 함
- Feature 폴더 구조: 각 feature 폴더 안에 `models/`, `views/`, `services/`, `widgets/` 하위 구조

### Git

- 브랜치: `feature/{feature-name}`, `fix/{bug-description}`, `chore/{task}`
- 커밋 메시지: 영어, 간결하게 "why"에 집중
- PR 단위: 하나의 기능 또는 하나의 버그 픽스

### Supabase

- 마이그레이션 파일: `supabase/migrations/` 디렉토리에 타임스탬프 순서
- Edge Functions: `supabase/functions/` 디렉토리, TypeScript(Deno)
- RLS 정책: 모든 테이블에 반드시 적용, 테스트 필수
- 인덱스: `region_id` 컬럼에 항상 인덱스, `EXPLAIN ANALYZE`로 검증

---

## Post-MVP Roadmap

1. Melos 모노레포로 admin_web 분리
2. 전용 태블릿 레이아웃 (ScreenUtil → 적응형 레이아웃)
3. 모두싸인(Modusign) / 카카오 인증서 연동
4. `slang` 패키지로 i18n DX 개선 (번역 코드 복잡해질 경우)
5. RevenueCat Web Billing (Stripe) 연동 — 웹 확장 시
6. `pg_net` 직접 호출 평가 (Edge Function 대체 가능 여부)
7. Riverpod 고도화 — AsyncNotifier 패턴 정립, 에러 핸들링 공통화

---

## Environment Variables (절대 커밋 금지)

```
SUPABASE_URL=
SUPABASE_ANON_KEY=
REVENUECAT_API_KEY_IOS=
REVENUECAT_API_KEY_ANDROID=
GOOGLE_SERVICE_ACCOUNT_JSON=  # FCM용, Edge Function에만 배포
```

> `.env` 파일은 `.gitignore`에 반드시 포함. Supabase Edge Function secrets는 `supabase secrets set`으로 관리.

---

## Quick Reference: 핵심 의사결정 요약

| 영역 | 결정 | 근거 |
|---|---|---|
| 결제 | RevenueCat | 서버사이드 영수증 검증 내장, 무료 티어 $2,500 MTR, 2-4주 개발 절약 |
| 전자서명 | 체크박스 + hand_signature | 전자서명법 제3조 충족, MVP에 외부 벤더 불필요 |
| 멀티테넌시 | JWT app_metadata + RLS | 별도 스키마/프로젝트 불필요, 강력한 데이터 격리 |
| 채팅 | Supabase Realtime (.stream()) | 초기 데이터 + 실시간 업데이트 단일 스트림 |
| 어드민 | Flutter Web PWA | 즉시 업데이트, 데스크톱 접근, Store 리뷰 불필요 |
| 테마 | #2D5A8E seed + Material 3 | 신뢰감/프리미엄, 소비자 데이팅앱과 차별화 |
| 이미지 | image_picker + flutter_image_compress | EXIF 자동 제거, private 버킷 + 서명 URL |
| i18n | 공식 flutter_localizations + intl | 컴파일 타임 안전성, ICU MessageFormat |
| 반응형 | ScreenUtil + LayoutBuilder | 폰 비례 사이징 + 태블릿 브레이크포인트 |
| 푸시 | DB webhook → Edge Function → FCM | Supabase 네이티브 푸시 미지원, pg_cron 재시도 |
