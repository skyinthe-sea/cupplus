-- handle_new_user: JWT app_metadata에 region_id 자동 설정
-- RLS가 get_region_id() (JWT app_metadata에서 추출)를 사용하므로
-- 신규 사용자에게 region_id가 없으면 INSERT가 RLS에 의해 차단됨
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Set region_id in app_metadata for RLS
  UPDATE auth.users
  SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"region_id": "default"}'::jsonb
  WHERE id = NEW.id;

  INSERT INTO public.managers (id, region_id, full_name, role)
  VALUES (
    NEW.id,
    'default',
    COALESCE(
      NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''),
      NULLIF(TRIM(NEW.raw_user_meta_data->>'name'), ''),
      NULLIF(TRIM(split_part(COALESCE(NEW.email, ''), '@', 1)), ''),
      '매니저#' || LPAD(floor(random() * 10000)::text, 4, '0')
    ),
    'manager'
  );
  RETURN NEW;
END;
$$;

-- 기존 사용자 중 region_id가 없는 경우 보정
UPDATE auth.users
SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || '{"region_id": "default"}'::jsonb
WHERE NOT (raw_app_meta_data ? 'region_id');
