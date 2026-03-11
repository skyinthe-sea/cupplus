# 서류 인증 & 계약서 기획서

---

## 5-1. 매니저 인증 (MVP)

### 목적
- 매니저가 실제 결혼정보회사 직원임을 인증
- **인증 없이도 회원가입, 앱 구경, 회원 등록 가능**
- **최초 매칭 요청 시** 인증이 안 되어 있으면 인증 요구

### 인증 서류 (택 1 이상)
| 서류 | 설명 |
|---|---|
| 명함 | 결혼정보회사 명함 사진 |
| 재직증명서 | 결혼정보회사 재직증명서 |
| 사업자등록증 | 결혼정보회사 사업자등록증 |

### 인증 플로우
```
매니저가 매칭 요청 탭
  → 인증 상태 체크
    → 인증 완료: 정상 매칭 요청 진행
    → 미인증: 인증 요청 바텀시트/모달
      → 서류 종류 선택 (명함/재직증명서/사업자등록증)
        → 카메라/갤러리에서 이미지 선택
          → 이미지 압축 후 Supabase Storage 업로드
            → "제출 완료. 검토 후 알림드리겠습니다" 안내
              → 어드민이 검토 후 승인/반려
                → 승인 시: 매니저 인증 상태 변경 + 알림
                → 반려 시: 사유와 함께 알림, 재제출 유도
```

### 인증 상태
| 상태 | 설명 | 매칭 요청 가능 |
|---|---|---|
| unverified | 미인증 (기본) | ❌ |
| pending | 서류 제출, 검토 대기 | ❌ |
| verified | 인증 완료 | ✅ |
| rejected | 반려 (재제출 필요) | ❌ |

### 데이터
- `managers` 테이블에 `verification_status` 컬럼 추가 필요
  - 값: 'unverified' | 'pending' | 'verified' | 'rejected'
- `manager_verification_documents` 테이블 신규:
  ```sql
  CREATE TABLE manager_verification_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    manager_id UUID REFERENCES managers(id),
    document_type TEXT NOT NULL,  -- 'business_card' | 'employment_cert' | 'business_registration'
    storage_path TEXT NOT NULL,
    status TEXT DEFAULT 'pending',  -- 'pending' | 'approved' | 'rejected'
    rejection_reason TEXT,
    uploaded_at TIMESTAMPTZ DEFAULT now(),
    reviewed_at TIMESTAMPTZ
  );
  ```

### 인증 상태 표시 위치
- **마이탭 프로필 카드**: 인증 뱃지 또는 "인증 필요" 표시
- **매칭 요청 시**: 미인증이면 인증 유도 모달

### 승인 주체
- **어드민 수동 승인** (어드민 웹 대시보드 또는 Supabase Studio에서)
- 승인/반려 시 매니저에게 알림 발송

---

## 5-2. 서비스 이용 계약서 (MVP 간소화)

### 목적
- 회원 등록 시 서비스 이용 약관 동의 받기
- 전자서명법 제3조 충족 (체크박스 동의 = 유효한 전자서명)

### 플로우 (회원 등록 폼의 마지막 단계)
```
회원 프로필 입력
  → 마지막 단계: 서비스 이용 계약 동의
    → 약관 내용 표시 (스크롤 가능)
    → ☐ 서비스 이용 약관에 동의합니다 (필수)
    → ☐ 개인정보 수집/이용에 동의합니다 (필수)
    → ☐ 마케팅 정보 수신에 동의합니다 (선택)
    → [등록 완료] 버튼
```

### MVP 범위 (간소화)
- **체크박스 동의만** (hand_signature 서명 그리기 없음)
- 동의 기록 저장:
  - 동의 시각 (서버 타임스탬프)
  - 사용자 ID (매니저 ID + 회원 ID)
  - 약관 버전 해시 (SHA-256)
  - IP 주소
  - 디바이스 정보

### 데이터
- `contract_agreements` 테이블 활용 (이미 스키마에 존재)
- `signature_storage_path`는 MVP에서 NULL (서명 그리기 없으므로)

### Post-MVP
- hand_signature 패키지로 서명 그리기 추가
- 모두싸인(Modusign) / 카카오 인증서 연동

---

## 5-3. 회원 서류 인증 (Post-MVP)

> **MVP에서 제외**
>
> 회원의 재직증명서, 졸업증명서, 소득증명서 등의 서류 검토 기능은
> Post-MVP에서 구현한다.
>
> 이에 따라:
> - 홈 빠른액션 [서류검토] → MVP에서 제거
> - 홈 오늘의 할일 "서류검토 N건" → MVP에서 제거
> - 프로필 카드의 인증 뱃지(✅) → MVP에서 제거 또는 매니저 인증만 표시
