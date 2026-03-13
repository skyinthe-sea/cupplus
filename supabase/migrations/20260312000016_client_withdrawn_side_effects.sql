-- Side effects when a client is withdrawn (soft-deleted)
-- 1. Cancel all pending matches
-- 2. Notify counterpart managers of active matches
-- 3. Insert system messages in related conversations

CREATE OR REPLACE FUNCTION handle_client_withdrawn()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_match RECORD;
  v_conversation RECORD;
  v_counterpart_manager_id UUID;
  v_client_name TEXT;
BEGIN
  -- Only fire when status changes to 'withdrawn'
  IF NEW.status <> 'withdrawn' OR OLD.status = 'withdrawn' THEN
    RETURN NEW;
  END IF;

  v_client_name := NEW.full_name;

  -- 1. Cancel all pending matches involving this client
  UPDATE matches
  SET status = 'cancelled', responded_at = now()
  WHERE (client_a_id = NEW.id OR client_b_id = NEW.id)
    AND status = 'pending';

  -- 2. For active matches (accepted, meeting_scheduled), notify counterpart manager
  FOR v_match IN
    SELECT m.id AS match_id,
           m.client_a_id, m.client_b_id,
           ca.full_name AS client_a_name, cb.full_name AS client_b_name,
           ca.manager_id AS manager_a_id, cb.manager_id AS manager_b_id
    FROM matches m
    JOIN clients ca ON ca.id = m.client_a_id
    JOIN clients cb ON cb.id = m.client_b_id
    WHERE (m.client_a_id = NEW.id OR m.client_b_id = NEW.id)
      AND m.status IN ('accepted', 'meeting_scheduled')
  LOOP
    -- Determine the counterpart manager (the one NOT owning the withdrawn client)
    IF v_match.client_a_id = NEW.id THEN
      v_counterpart_manager_id := v_match.manager_b_id;
    ELSE
      v_counterpart_manager_id := v_match.manager_a_id;
    END IF;

    -- Insert notification for counterpart manager
    IF v_counterpart_manager_id IS NOT NULL THEN
      INSERT INTO notifications (user_id, title, body, type, data)
      VALUES (
        v_counterpart_manager_id,
        '매칭 취소',
        v_client_name || ' 회원이 탈퇴하여 ' || v_match.client_a_name || ' ↔ ' || v_match.client_b_name || ' 매칭이 취소되었습니다.',
        'match_response',
        jsonb_build_object('match_id', v_match.match_id, 'reason', 'client_withdrawn')
      );
    END IF;
  END LOOP;

  -- 3. Insert system messages in related conversations
  FOR v_conversation IN
    SELECT c.id AS conversation_id, m.client_a_id, m.client_b_id
    FROM conversations c
    JOIN matches m ON m.id = c.match_id
    WHERE m.client_a_id = NEW.id OR m.client_b_id = NEW.id
  LOOP
    INSERT INTO messages (conversation_id, sender_id, content, type)
    VALUES (
      v_conversation.conversation_id,
      NEW.manager_id,  -- system message attributed to the withdrawing manager
      v_client_name || ' 회원이 탈퇴하였습니다.',
      'text'
    );
  END LOOP;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_client_withdrawn
  AFTER UPDATE ON clients
  FOR EACH ROW
  WHEN (NEW.status = 'withdrawn' AND OLD.status <> 'withdrawn')
  EXECUTE FUNCTION handle_client_withdrawn();
