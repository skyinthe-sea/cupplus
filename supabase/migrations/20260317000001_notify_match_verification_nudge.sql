-- Update notify_new_match to include verification nudge for unverified managers
CREATE OR REPLACE FUNCTION public.notify_new_match()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_requester_name TEXT;
  v_client_a_name TEXT;
  v_client_b_name TEXT;
  v_target_manager_id UUID;
  v_target_verification TEXT;
  v_body TEXT;
  v_data JSONB;
BEGIN
  IF NEW.status != 'pending' THEN
    RETURN NEW;
  END IF;

  SELECT full_name INTO v_requester_name
  FROM managers WHERE id = NEW.manager_id;

  SELECT full_name INTO v_client_a_name
  FROM clients WHERE id = NEW.client_a_id;

  SELECT full_name INTO v_client_b_name
  FROM clients WHERE id = NEW.client_b_id;

  SELECT manager_id INTO v_target_manager_id
  FROM clients WHERE id = NEW.client_b_id;

  IF v_target_manager_id IS NOT NULL AND v_target_manager_id != NEW.manager_id THEN
    -- Check target manager verification status
    SELECT verification_status INTO v_target_verification
    FROM managers WHERE id = v_target_manager_id;

    v_body := COALESCE(v_requester_name, '매니저') || '님이 ' ||
      COALESCE(v_client_a_name, '?') || '↔' ||
      COALESCE(v_client_b_name, '?') || ' 매칭을 요청했습니다';

    v_data := jsonb_build_object(
      'match_id', NEW.id::TEXT,
      'client_a_name', COALESCE(v_client_a_name, ''),
      'client_b_name', COALESCE(v_client_b_name, '')
    );

    IF v_target_verification IS DISTINCT FROM 'verified' THEN
      v_body := v_body || E'\n매니저 인증을 완료하면 매칭을 수락할 수 있어요!';
      v_data := v_data || '{"requires_verification": true}'::jsonb;
    END IF;

    INSERT INTO notifications (user_id, title, body, type, data, status)
    VALUES (
      v_target_manager_id,
      '새 매칭 요청',
      v_body,
      'new_match',
      v_data,
      'pending'
    );
  END IF;

  RETURN NEW;
END;
$$;
