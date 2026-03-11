-- handle_new_user 트리거 수정: 빈 문자열을 NULLIF로 처리, 임의 이름 생성
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
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

-- 기존 빈 full_name 보정
UPDATE public.managers
SET full_name = '매니저#' || LPAD(floor(random() * 10000)::text, 4, '0')
WHERE full_name IS NULL OR TRIM(full_name) = '';
