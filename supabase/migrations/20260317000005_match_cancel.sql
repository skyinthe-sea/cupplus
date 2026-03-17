-- Add 'cancelled' to matches status CHECK constraint
ALTER TABLE matches DROP CONSTRAINT IF EXISTS matches_status_check;
ALTER TABLE matches ADD CONSTRAINT matches_status_check
  CHECK (status IN ('pending','accepted','declined','meeting_scheduled','completed','cancelled'));

-- Trigger: notify target manager when a match request is cancelled
CREATE OR REPLACE FUNCTION public.notify_match_cancelled()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_client_a_name TEXT;
  v_client_b_name TEXT;
  v_target_manager_id UUID;
BEGIN
  IF OLD.status != 'pending' OR NEW.status != 'cancelled' THEN RETURN NEW; END IF;

  SELECT full_name INTO v_client_a_name FROM clients WHERE id = NEW.client_a_id;
  SELECT full_name INTO v_client_b_name FROM clients WHERE id = NEW.client_b_id;
  SELECT manager_id INTO v_target_manager_id FROM clients WHERE id = NEW.client_b_id;

  IF v_target_manager_id IS NOT NULL AND v_target_manager_id != NEW.manager_id THEN
    INSERT INTO notifications (user_id, title, body, type, data, status)
    VALUES (
      v_target_manager_id,
      '매칭 요청 취소',
      COALESCE(v_client_a_name,'?') || '↔' || COALESCE(v_client_b_name,'?') || ' 매칭 요청이 취소되었습니다',
      'match_response',
      jsonb_build_object('match_id', NEW.id::TEXT, 'match_status', 'cancelled',
        'client_a_name', COALESCE(v_client_a_name,''), 'client_b_name', COALESCE(v_client_b_name,'')),
      'pending'
    );
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_notify_match_cancelled
  AFTER UPDATE OF status ON matches
  FOR EACH ROW EXECUTE FUNCTION public.notify_match_cancelled();
