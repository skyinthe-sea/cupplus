-- Notification trigger: 회원 등록 완료 시 매니저에게 알림
CREATE OR REPLACE FUNCTION public.notify_client_registered()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.manager_id IS NULL THEN
    RETURN NEW;
  END IF;

  INSERT INTO notifications (user_id, title, body, type, data, status)
  VALUES (
    NEW.manager_id,
    '회원 등록 완료',
    COALESCE(NEW.full_name, '회원') || '님이 등록되었습니다',
    'system',
    jsonb_build_object(
      'client_id', NEW.id::TEXT,
      'client_name', COALESCE(NEW.full_name, '')
    ),
    'pending'
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_client_registered ON clients;
CREATE TRIGGER trg_notify_client_registered
  AFTER INSERT ON clients
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_client_registered();
