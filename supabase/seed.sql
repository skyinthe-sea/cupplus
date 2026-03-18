-- =============================================================================
-- CupPlus Seed Data
-- 매 supabase db reset 시 자동 적용
-- =============================================================================
-- Dev 계정 2개만 시드로 생성 (카카오 유저는 앱에서 직접 로그인)
-- 김서연: 22222222-2222-2222-2222-222222222222 (verified)
-- 박지훈: 33333333-3333-3333-3333-333333333333 (unverified)
--
-- 임준섭(카카오)은 앱에서 카카오 로그인 후, 아래 SQL로 회원을 연결:
--   UPDATE clients SET manager_id = '<카카오_로그인_UUID>' WHERE manager_id = '11111111-1111-1111-1111-111111111111';

-- =============================================================================
-- 1. Auth Users (Dev 계정 — signUp과 동일한 방식)
-- =============================================================================

-- 임준섭 매니저 (placeholder — 실제로는 카카오 로그인 사용)
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data, confirmation_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '11111111-1111-1111-1111-111111111111',
  'authenticated', 'authenticated',
  'manager.lim@test.com', crypt('testtest', gen_salt('bf')),
  now(), now(), now(),
  '{"provider": "email", "providers": ["email"], "region_id": "default"}'::jsonb,
  '{"full_name": "임준섭"}'::jsonb,
  ''
);

-- 김서연 매니저
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data, confirmation_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '22222222-2222-2222-2222-222222222222',
  'authenticated', 'authenticated',
  'manager.kim@test.com', crypt('testtest', gen_salt('bf')),
  now(), now(), now(),
  '{"provider": "email", "providers": ["email"], "region_id": "default"}'::jsonb,
  '{"full_name": "김서연"}'::jsonb,
  ''
);

-- 박지훈 매니저
INSERT INTO auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data, confirmation_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  '33333333-3333-3333-3333-333333333333',
  'authenticated', 'authenticated',
  'manager.park@test.com', crypt('testtest', gen_salt('bf')),
  now(), now(), now(),
  '{"provider": "email", "providers": ["email"], "region_id": "default"}'::jsonb,
  '{"full_name": "박지훈"}'::jsonb,
  ''
);

-- GoTrue requires these varchar columns to be '' not NULL
UPDATE auth.users SET
  email_change = '',
  phone = NULL,
  phone_change = '',
  phone_change_token = '',
  email_change_token_current = '',
  email_change_token_new = '',
  recovery_token = '',
  reauthentication_token = ''
WHERE id IN (
  '11111111-1111-1111-1111-111111111111',
  '22222222-2222-2222-2222-222222222222',
  '33333333-3333-3333-3333-333333333333'
);

-- Auth identities (email provider)
INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111',
   '{"sub": "11111111-1111-1111-1111-111111111111", "email": "manager.lim@test.com", "email_verified": true}'::jsonb,
   'email', '11111111-1111-1111-1111-111111111111', now(), now(), now()),
  ('22222222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222',
   '{"sub": "22222222-2222-2222-2222-222222222222", "email": "manager.kim@test.com", "email_verified": true}'::jsonb,
   'email', '22222222-2222-2222-2222-222222222222', now(), now(), now()),
  ('33333333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333',
   '{"sub": "33333333-3333-3333-3333-333333333333", "email": "manager.park@test.com", "email_verified": true}'::jsonb,
   'email', '33333333-3333-3333-3333-333333333333', now(), now(), now());

-- =============================================================================
-- 2. Managers 업데이트 (handle_new_user 트리거가 이미 생성)
-- =============================================================================
UPDATE managers SET
  full_name = '김서연',
  phone = '010-9876-5432',
  verification_status = 'verified'
WHERE id = '22222222-2222-2222-2222-222222222222';

UPDATE managers SET
  full_name = '박지훈',
  phone = '010-5555-6666',
  verification_status = 'unverified'
WHERE id = '33333333-3333-3333-3333-333333333333';

UPDATE managers SET
  full_name = '임준섭',
  phone = '010-1234-5678',
  verification_status = 'verified'
WHERE id = '11111111-1111-1111-1111-111111111111';

-- Manager verification docs
INSERT INTO manager_verification_documents (manager_id, document_type, storage_path, status, reviewed_at)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'business_card', 'manager-verification-documents/11111111/business_card.jpg', 'approved', now()),
  ('22222222-2222-2222-2222-222222222222', 'employment_cert', 'manager-verification-documents/22222222/employment_cert.jpg', 'approved', now());

-- =============================================================================
-- 3. Clients — 임준섭 매니저 (5명: 남3 여2)
--    카카오 로그인 후 manager_id를 실제 UUID로 교체 필요
-- =============================================================================
INSERT INTO clients (
  id, region_id, manager_id, full_name, gender, birth_date,
  height_cm, occupation, company, education, annual_income_range, religion,
  hobbies, bio, status, body_type, personality_type,
  marital_history, has_children, children_count, family_detail, parents_status,
  drinking, smoking, health_notes,
  asset_range, residence_area, residence_type,
  ideal_min_age, ideal_max_age, ideal_min_height, ideal_max_height,
  ideal_education_level, ideal_income_range, ideal_religion, ideal_notes,
  created_at
) VALUES
(
  'aaaaaaaa-0001-0000-0000-000000000001', 'default',
  '11111111-1111-1111-1111-111111111111',
  '정민호', 'M', '1993-05-15',
  178, '소프트웨어 엔지니어', '네이버', '대졸', '5000_7000', 'none',
  ARRAY['코딩', '등산', '독서', '커피'],
  '밝고 긍정적인 성격입니다. 주말엔 등산을 즐기고, 카페에서 개발 서적 읽는 걸 좋아합니다. 함께 성장할 수 있는 파트너를 찾고 있어요.',
  'active', 'average', 'INTJ',
  'first_marriage', false, NULL, '1남 1녀 중 장남', 'both_alive',
  'social', 'none', NULL,
  '100_300', '서울 강남구 역삼동', 'rent_deposit',
  28, 34, 158, 172,
  '대졸', '3000_5000', NULL, '밝고 활발한 성격이면 좋겠습니다. 서울 거주 선호.',
  now() - interval '6 days'
),
(
  'aaaaaaaa-0002-0000-0000-000000000002', 'default',
  '11111111-1111-1111-1111-111111111111',
  '이태윤', 'M', '1991-11-22',
  182, '외과 전문의', '서울대학교병원', '박사', '10000_15000', 'none',
  ARRAY['골프', '와인', '여행', '클래식음악', '요리'],
  '일과 삶의 균형을 중요시합니다. 주말에는 골프를 즐기고, 좋은 와인과 함께하는 저녁 시간을 좋아합니다. 가족을 소중히 여기는 따뜻한 가정을 꿈꿉니다.',
  'active', 'average', 'ESTJ',
  'first_marriage', false, NULL, '2남 중 차남', 'both_alive',
  'social', 'none', NULL,
  '500_1000', '서울 서초구 반포동', 'own',
  27, 33, 160, 175,
  '대졸', '5000_7000', NULL, '차분하고 가정적인 분. 의료계 종사자도 환영합니다. 주말 일정이 유동적이라 이해해줄 수 있는 분.',
  now() - interval '5 days'
),
(
  'aaaaaaaa-0003-0000-0000-000000000003', 'default',
  '11111111-1111-1111-1111-111111111111',
  '김도현', 'M', '1995-03-08',
  175, '변호사', '김앤장 법률사무소', '석사', '7000_10000', 'christian',
  ARRAY['피아노', '테니스', '독서'],
  '진지하지만 유머감각이 있습니다. 어릴 때부터 피아노를 쳤고, 주말엔 테니스를 즐깁니다. 지적인 대화를 나눌 수 있는 파트너를 만나고 싶어요.',
  'active', 'slightly_slim', 'ENFJ',
  'first_marriage', false, NULL, '1남 2녀 중 막내', 'both_alive',
  'none', 'none', NULL,
  '300_500', '서울 강남구 대치동', 'rent_deposit',
  26, 32, 158, 170,
  '대졸', NULL, 'christian', '같은 신앙을 가진 분이면 더 좋겠습니다. 예술이나 문화 활동을 함께 즐길 수 있는 분.',
  now() - interval '4 days'
),
(
  'aaaaaaaa-0004-0000-0000-000000000004', 'default',
  '11111111-1111-1111-1111-111111111111',
  '박수빈', 'F', '1994-08-20',
  165, '피부과 전문의', '청담 에스테틱 피부과', '박사', '7000_10000', 'catholic',
  ARRAY['필라테스', '카페투어', '요리', '여행'],
  '따뜻하고 배려심 있는 성격입니다. 요리하는 걸 좋아하고, 주말엔 카페를 찾아다닙니다. 서로 존중하며 함께 성장하는 관계를 원합니다.',
  'active', 'slim', 'ISFJ',
  'first_marriage', false, NULL, '2녀 중 장녀', 'both_alive',
  'none', 'none', '경미한 비염 (일상 지장 없음)',
  '300_500', '서울 강남구 신사동', 'own',
  30, 37, 175, 188,
  '대졸', '7000_10000', NULL, '키 175 이상. 비흡연자 필수. 가정적이고 성실한 분. 종교는 무관합니다.',
  now() - interval '3 days'
),
(
  'aaaaaaaa-0005-0000-0000-000000000005', 'default',
  '11111111-1111-1111-1111-111111111111',
  '한지은', 'F', '1996-01-10',
  162, '마케팅 매니저', '삼성전자 마케팅본부', '대졸', '5000_7000', 'none',
  ARRAY['러닝', '드로잉', '넷플릭스', '맛집탐방', '강아지'],
  '활발하고 사교적인 성격이에요. 한강 러닝 크루에서 활동 중이고, 취미로 일러스트를 그립니다. 유머 코드가 맞는 사람을 만나고 싶어요!',
  'active', 'average', 'ENFP',
  'first_marriage', false, NULL, '1남 1녀 중 막내', 'both_alive',
  'social', 'none', NULL,
  '100_300', '서울 마포구 연남동', 'rent_deposit',
  28, 35, 173, 188,
  '대졸', '5000_7000', NULL, '유머감각 있고 활동적인 분. 반려동물 좋아하는 분이면 더 좋아요. 서울 거주 필수.',
  now() - interval '2 days'
);

-- =============================================================================
-- 4. Clients — 김서연 매니저 (4명: 남2 여2)
-- =============================================================================
INSERT INTO clients (
  id, region_id, manager_id, full_name, gender, birth_date,
  height_cm, occupation, company, education, annual_income_range, religion,
  hobbies, bio, status, body_type, personality_type,
  marital_history, has_children, children_count, family_detail, parents_status,
  drinking, smoking, health_notes,
  asset_range, residence_area, residence_type,
  ideal_min_age, ideal_max_age, ideal_min_height, ideal_max_height,
  ideal_education_level, ideal_income_range, ideal_religion, ideal_notes,
  created_at
) VALUES
(
  'bbbbbbbb-0001-0000-0000-000000000001', 'default',
  '22222222-2222-2222-2222-222222222222',
  '최준혁', 'M', '1992-07-03',
  180, '금융 애널리스트', 'JP모건 서울지점', '석사', '10000_15000', 'none',
  ARRAY['수영', '독서', '주식투자', '와인', '골프'],
  '차분하고 계획적인 성격입니다. 금융 분야에서 10년째 일하고 있고, 주말엔 수영과 독서로 리프레시합니다. 같은 가치관을 공유할 수 있는 분을 찾습니다.',
  'active', 'average', 'ISTJ',
  'first_marriage', false, NULL, '1남 1녀 중 장남', 'both_alive',
  'social', 'none', NULL,
  '500_1000', '서울 용산구 이태원동', 'own',
  27, 33, 160, 172,
  '대졸', '3000_5000', NULL, '지적이고 자기 분야에 열정이 있는 분. 해외 출장이 잦아 이해해주실 분이면 좋겠습니다.',
  now() - interval '5 days'
),
(
  'bbbbbbbb-0002-0000-0000-000000000002', 'default',
  '22222222-2222-2222-2222-222222222222',
  '윤성민', 'M', '1990-12-18',
  176, '치과의사', '윤성민치과의원 (개원)', '박사', '15000_plus', 'buddhist',
  ARRAY['자전거', '캠핑', '요리', '와인'],
  '가족을 중요시하는 사람입니다. 서울 강동에서 치과를 운영하고 있어요. 주말엔 한강 자전거 타기와 캠핑을 즐깁니다. 따뜻한 가정을 함께 만들어갈 분을 찾고 있습니다.',
  'active', 'slightly_chubby', 'INFJ',
  'first_marriage', false, NULL, '2남 중 장남', 'both_alive',
  'none', 'none', '경미한 허리 디스크 (운동으로 관리 중)',
  '1000_plus', '서울 강동구 천호동', 'own',
  28, 35, 158, 170,
  '대졸', NULL, NULL, '가정적이고 성실한 분. 아이를 좋아하는 분이면 좋겠습니다. 불교 신자이지만 종교 강요하지 않습니다.',
  now() - interval '4 days'
),
(
  'bbbbbbbb-0003-0000-0000-000000000003', 'default',
  '22222222-2222-2222-2222-222222222222',
  '서윤아', 'F', '1993-04-25',
  168, '대학교수', '이화여자대학교 영문학과', '박사', '7000_10000', 'none',
  ARRAY['독서', '클래식음악', '와인', '미술관', '에세이쓰기'],
  '지적 대화를 즐기는 편입니다. 영문학을 전공했고, 현재 이화여대에서 강의하고 있어요. 고요한 카페에서 글을 쓰거나 미술관에 가는 걸 좋아합니다. 서로의 세계를 존중하면서도 깊이 교감할 수 있는 관계를 원해요.',
  'active', 'slim', 'INTP',
  'first_marriage', false, NULL, '외동딸', 'both_alive',
  'social', 'none', NULL,
  '300_500', '서울 서대문구 연희동', 'rent_deposit',
  30, 37, 175, 188,
  '석사', '7000_10000', NULL, '지적 호기심이 많은 분. 문화생활을 함께 즐길 수 있는 분이면 좋겠습니다. 독립적이면서도 따뜻한 분.',
  now() - interval '3 days'
),
(
  'bbbbbbbb-0004-0000-0000-000000000004', 'default',
  '22222222-2222-2222-2222-222222222222',
  '강하늘', 'F', '1995-09-14',
  163, '약사', '강남온누리약국 (관리약사)', '석사', '5000_7000', 'christian',
  ARRAY['요가', '베이킹', '여행', '캘리그라피'],
  '따뜻한 마음을 가진 사람이에요. 약사로 일하면서 건강한 생활에 관심이 많아요. 베이킹이 취미인데, 친구들이 제 빵을 좋아해서 보람을 느껴요. 함께 웃고 대화할 수 있는 분을 만나고 싶습니다.',
  'active', 'average', 'ESFJ',
  'first_marriage', false, NULL, '1남 1녀 중 장녀', 'both_alive',
  'none', 'none', NULL,
  '100_300', '서울 강남구 논현동', 'rent_monthly',
  28, 35, 175, 185,
  '대졸', '5000_7000', NULL, '건강하고 성실한 분. 주말에 함께 베이킹하거나 카페 가는 걸 즐겨주시면 좋겠어요. 비흡연자 필수.',
  now() - interval '1 day'
);

-- =============================================================================
-- 5. Clients — 박지훈 매니저 (3명: 남2 여1)
-- =============================================================================
INSERT INTO clients (
  id, region_id, manager_id, full_name, gender, birth_date,
  height_cm, occupation, company, education, annual_income_range, religion,
  hobbies, bio, status, body_type, personality_type,
  marital_history, has_children, children_count, family_detail, parents_status,
  drinking, smoking, health_notes,
  asset_range, residence_area, residence_type,
  ideal_min_age, ideal_max_age, ideal_min_height, ideal_max_height,
  ideal_education_level, ideal_income_range, ideal_religion, ideal_notes,
  created_at
) VALUES
(
  'cccccccc-0001-0000-0000-000000000001', 'default',
  '33333333-3333-3333-3333-333333333333',
  '오현우', 'M', '1994-02-28',
  177, '건축가', '삼성물산 건설부문', '석사', '5000_7000', 'none',
  ARRAY['사진', '인테리어', '커피', '전시회', '서핑'],
  '디자인과 예술을 사랑합니다. 건축 설계를 하면서 공간이 사람에게 주는 영향에 대해 항상 생각합니다. 주말엔 전시회를 보거나 카페에서 스케치를 합니다. 감성을 공유할 수 있는 파트너를 만나고 싶어요.',
  'active', 'slim', 'INFP',
  'first_marriage', false, NULL, '1남 1녀 중 장남', 'both_alive',
  'social', 'none', NULL,
  '100_300', '서울 성동구 성수동', 'rent_deposit',
  27, 33, 158, 170,
  '대졸', NULL, NULL, '예술적 감성이 있는 분. 전시회나 갤러리를 함께 다닐 수 있는 분이면 좋겠습니다. 자유로운 영혼이되 따뜻한 분.',
  now() - interval '2 days'
),
(
  'cccccccc-0002-0000-0000-000000000002', 'default',
  '33333333-3333-3333-3333-333333333333',
  '장예진', 'F', '1993-06-07',
  164, 'UX 디자이너', '카카오 프로덕트디자인팀', '대졸', '5000_7000', 'none',
  ARRAY['그림', '전시회', '요가', '빈티지쇼핑', '넷플릭스'],
  '감성적이고 예술적인 성격입니다. 카카오에서 UX 디자이너로 일하면서 사용자 경험을 설계하고 있어요. 주말엔 성수동 갤러리를 돌아보거나 빈티지숍을 탐방합니다. 서로의 취향을 존중하는 편안한 관계를 원해요.',
  'active', 'slim', 'ISFP',
  'first_marriage', false, NULL, '2녀 중 차녀', 'both_alive',
  'none', 'none', NULL,
  '100_300', '서울 성동구 성수동', 'rent_monthly',
  29, 36, 173, 185,
  '대졸', '5000_7000', NULL, '감성적이고 대화가 통하는 분. IT 업계 종사자면 서로 이해가 빠를 것 같아요. 깔끔하고 패션 센스 있는 분.',
  now() - interval '1 day'
),
(
  'cccccccc-0003-0000-0000-000000000003', 'default',
  '33333333-3333-3333-3333-333333333333',
  '신재원', 'M', '1991-10-11',
  183, 'CEO', '넥스트비전 (AI 스타트업)', '대졸', '10000_15000', 'none',
  ARRAY['골프', '와인', '스키', '투자', '독서'],
  '도전적이고 리더십이 있습니다. 3년 전 AI 기반 스타트업을 창업했고, 시리즈 B 투자를 받았습니다. 바쁜 일정 속에서도 운동과 자기계발을 꾸준히 합니다. 서로 응원하며 함께 성장할 수 있는 파트너를 원합니다.',
  'active', 'average', 'ENTJ',
  'first_marriage', false, NULL, '1남 중 외아들', 'both_alive',
  'social', 'none', NULL,
  '1000_plus', '서울 강남구 청담동', 'own',
  27, 34, 160, 172,
  '대졸', NULL, NULL, '자기 분야에 열정이 있는 분. 창업이나 비즈니스에 이해가 있으면 좋겠습니다. 독립적이면서도 가정적인 분. 해외 출장이 잦아서 이해해주실 수 있는 분.',
  now() - interval '6 hours'
);

-- 이후 데이터(매칭, 채팅, 좋아요, 알림 등)는 앱에서 직접 테스트하며 생성
