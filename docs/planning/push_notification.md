# 푸시 알림 기획서

---

## 아키텍처

```
DB 이벤트 (INSERT/UPDATE)
  → Database Webhook (pg_net 또는 Supabase Webhook)
    → Supabase Edge Function
      → FCM HTTP v1 API
        → 사용자 디바이스
```

---

## 푸시 알림 종류 (MVP 4종)

### 1. 매칭 관련
| 트리거 | 수신자 | 제목 | 본문 | 탭 시 이동 |
|---|---|---|---|---|
| 매칭 요청 생성 | 상대 매니저 | "새 매칭 요청" | "OOO매니저님이 김서연↔이준호 매칭을 요청했습니다" | 홈 → 대기매칭 바텀시트 |
| 매칭 수락 | 요청 매니저 | "매칭 수락" | "김서연↔이준호 매칭이 수락되었습니다" | 매칭 상세 |
| 매칭 거절 | 요청 매니저 | "매칭 거절" | "김서연↔이준호 매칭이 거절되었습니다" | 매칭 상세 |
| 매칭 취소 (회원 삭제 등) | 상대 매니저 | "매칭 취소" | "김서연↔이준호 매칭이 취소되었습니다" | 매칭 상세 |

### 2. 채팅 메시지
| 트리거 | 수신자 | 제목 | 본문 | 탭 시 이동 |
|---|---|---|---|---|
| 새 메시지 수신 | 상대 매니저 | "OOO매니저" | "메시지 내용 미리보기..." (최대 50자) | 해당 채팅방 |
| 이미지 메시지 수신 | 상대 매니저 | "OOO매니저" | "사진을 보냈습니다" | 해당 채팅방 |

#### 채팅 푸시 특수 규칙
- **앱이 포그라운드 + 해당 채팅방 열려있으면**: 푸시 안 보냄 (Realtime으로 이미 수신)
- **앱이 포그라운드 + 다른 화면**: 인앱 배너 알림 (flutter_local_notifications)
- **앱이 백그라운드/종료**: FCM 푸시

### 3. 매니저 인증
| 트리거 | 수신자 | 제목 | 본문 | 탭 시 이동 |
|---|---|---|---|---|
| 인증 승인 | 해당 매니저 | "매니저 인증 완료" | "매니저 인증이 승인되었습니다. 이제 매칭 요청이 가능합니다!" | 마이탭 |
| 인증 반려 | 해당 매니저 | "매니저 인증 반려" | "매니저 인증이 반려되었습니다. 사유: {reason}" | 마이탭 → 인증 재제출 |

### 4. 시스템 알림
| 트리거 | 수신자 | 제목 | 본문 | 탭 시 이동 |
|---|---|---|---|---|
| 구독 만료 3일 전 | 해당 매니저 | "구독 만료 예정" | "구독이 3일 후 만료됩니다. 갱신하세요." | 마이탭 → 구독관리 |
| 구독 만료 | 해당 매니저 | "구독 만료" | "구독이 만료되었습니다." | 마이탭 → 구독관리 |
| 공지사항 | 전체 매니저 | "공지사항" | "{공지 내용}" | 알림 바텀시트 |

---

## FCM 토큰 관리

### 토큰 등록 시점
- 앱 최초 실행 시
- 로그인 성공 시
- 토큰 갱신 시 (FCM onTokenRefresh)

### 토큰 저장
- `fcm_tokens` 테이블 (이미 스키마에 존재)
  - user_id, token, platform ('ios' | 'android'), updated_at
  - UNIQUE(user_id, platform)

### 토큰 삭제
- 로그아웃 시: 해당 유저의 토큰 삭제

---

## Edge Function 구현

### notify-match (매칭 알림)
```
트리거: matches INSERT/UPDATE webhook
로직:
  1. 매칭 상태 확인 (pending/accepted/declined/cancelled)
  2. 수신자 결정 (상대 매니저)
  3. 수신자의 알림 설정 확인 (match_notifications = true?)
  4. fcm_tokens에서 수신자 토큰 조회
  5. FCM API 호출
  6. notifications 테이블에 기록
  7. 실패 시 retries++ , status = 'failed'
```

### notify-message (채팅 알림)
```
트리거: messages INSERT webhook
로직:
  1. 발신자 ≠ 수신자 확인
  2. 수신자의 알림 설정 확인 (message_notifications = true?)
  3. 수신자가 현재 해당 채팅방에 접속 중인지 확인
     → 접속 중이면 푸시 스킵 (Realtime으로 처리)
  4. fcm_tokens에서 수신자 토큰 조회
  5. FCM API 호출 (메시지 내용 50자 미리보기)
  6. notifications 테이블에 기록
```

### notify-verification (인증 알림)
```
트리거: manager_verification_documents UPDATE webhook (status 변경 시)
로직:
  1. 승인/반려 확인
  2. 해당 매니저의 fcm_tokens 조회
  3. FCM API 호출
  4. notifications 테이블에 기록
```

### notify-system (시스템 알림)
```
트리거: pg_cron 스케줄 또는 수동
로직:
  1. 대상 사용자 조회
  2. fcm_tokens 조회
  3. FCM API 일괄 호출
  4. notifications 테이블에 기록
```

---

## 재시도 전략

- `notifications` 테이블의 `status`/`retries` 컬럼 활용
- 실패 시: `status = 'failed'`, `retries++`
- `pg_cron`으로 주기적 재시도:
  - 1차: 1분 후
  - 2차: 5분 후
  - 3차: 30분 후
  - 최대 3회 재시도 후 포기 (status = 'permanently_failed')

---

## 알림 설정 (종류별 토글)

### 마이탭 → 설정에 추가

```
┌───────────────────────────────┐
│ 알림 설정                      │
│                               │
│  매칭 알림              [ON]  │  ← 매칭 요청/수락/거절
│  채팅 알림              [ON]  │  ← 새 메시지
│  인증 알림              [ON]  │  ← 매니저 인증 결과
│  시스템 알림            [ON]  │  ← 공지/구독
└───────────────────────────────┘
```

### 데이터 저장
- `managers` 테이블에 `notification_settings JSONB` 컬럼 추가:
  ```json
  {
    "match_notifications": true,
    "message_notifications": true,
    "verification_notifications": true,
    "system_notifications": true
  }
  ```
- 기본값: 모두 true

---

## 인앱 알림 (포그라운드)

### 앱이 열려있을 때 푸시 수신
- `flutter_local_notifications`으로 상단 배너 표시
- 배너 탭 → 해당 화면으로 이동
- 해당 채팅방에 있으면 배너 표시 안 함

---

## DB 스키마 변경 필요

### managers 테이블
```sql
ALTER TABLE managers ADD COLUMN notification_settings JSONB DEFAULT '{"match_notifications":true,"message_notifications":true,"verification_notifications":true,"system_notifications":true}';
```
