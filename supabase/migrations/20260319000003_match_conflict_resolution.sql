-- Match conflict resolution: auto-cancel competing pending matches when one is accepted
-- Also sets matched clients' status to 'matched'

-- 1. Add cancellation_reason column
ALTER TABLE matches ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- 2. Recreate unique index to exclude 'cancelled' status (allows re-matching after cancel)
DROP INDEX IF EXISTS idx_matches_unique_pair;
CREATE UNIQUE INDEX idx_matches_unique_pair
  ON matches (LEAST(client_a_id, client_b_id), GREATEST(client_a_id, client_b_id))
  WHERE status NOT IN ('declined', 'completed', 'cancelled');

-- 3. Extend handle_match_accepted() to resolve conflicts + update client status
CREATE OR REPLACE FUNCTION public.handle_match_accepted()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_conv_id UUID;
  v_manager_a UUID;
  v_manager_b UUID;
  v_client_a_name TEXT;
  v_client_b_name TEXT;
  v_conflicting RECORD;
  v_other_manager UUID;
  v_conflict_client_a_name TEXT;
  v_conflict_client_b_name TEXT;
BEGIN
  -- Only fire when status changes TO 'accepted'
  IF NEW.status <> 'accepted' OR OLD.status = 'accepted' THEN
    RETURN NEW;
  END IF;

  -- === Conflict resolution: cancel other pending matches involving these clients ===
  -- This must run before any early-return guards to ensure data integrity
  FOR v_conflicting IN
    SELECT m.id AS match_id, m.client_a_id, m.client_b_id, m.manager_id
    FROM public.matches m
    WHERE m.status = 'pending'
      AND m.id <> NEW.id
      AND (
        m.client_a_id IN (NEW.client_a_id, NEW.client_b_id)
        OR m.client_b_id IN (NEW.client_a_id, NEW.client_b_id)
      )
  LOOP
    -- Cancel the conflicting match
    UPDATE public.matches
    SET status = 'cancelled',
        responded_at = now(),
        cancellation_reason = 'conflict_resolved'
    WHERE id = v_conflicting.match_id;

    -- Get client names for notification
    SELECT full_name INTO v_conflict_client_a_name FROM public.clients WHERE id = v_conflicting.client_a_id;
    SELECT full_name INTO v_conflict_client_b_name FROM public.clients WHERE id = v_conflicting.client_b_id;

    -- Notify the manager who created the conflicting match
    IF v_conflicting.manager_id IS NOT NULL THEN
      INSERT INTO public.notifications (user_id, title, body, type, data, status)
      VALUES (
        v_conflicting.manager_id,
        '매칭 자동 취소',
        COALESCE(v_conflict_client_a_name, '?') || ' ↔ ' || COALESCE(v_conflict_client_b_name, '?') ||
        ' 매칭이 취소되었습니다. 다른 회원과 매칭이 먼저 완료되었습니다.',
        'match_response',
        jsonb_build_object(
          'match_id', v_conflicting.match_id::TEXT,
          'match_status', 'cancelled',
          'reason', 'already_matched',
          'client_a_name', COALESCE(v_conflict_client_a_name, ''),
          'client_b_name', COALESCE(v_conflict_client_b_name, '')
        ),
        'pending'
      );
    END IF;

    -- Also notify the target manager of the conflicting match (client_b's manager)
    SELECT manager_id INTO v_other_manager FROM public.clients WHERE id = v_conflicting.client_b_id;
    IF v_other_manager IS NOT NULL AND v_other_manager <> COALESCE(v_conflicting.manager_id, '00000000-0000-0000-0000-000000000000'::UUID) THEN
      INSERT INTO public.notifications (user_id, title, body, type, data, status)
      VALUES (
        v_other_manager,
        '매칭 자동 취소',
        COALESCE(v_conflict_client_a_name, '?') || ' ↔ ' || COALESCE(v_conflict_client_b_name, '?') ||
        ' 매칭이 취소되었습니다. 다른 회원과 매칭이 먼저 완료되었습니다.',
        'match_response',
        jsonb_build_object(
          'match_id', v_conflicting.match_id::TEXT,
          'match_status', 'cancelled',
          'reason', 'already_matched',
          'client_a_name', COALESCE(v_conflict_client_a_name, ''),
          'client_b_name', COALESCE(v_conflict_client_b_name, '')
        ),
        'pending'
      );
    END IF;
  END LOOP;

  -- === Update client status to 'matched' ===
  UPDATE public.clients SET status = 'matched' WHERE id IN (NEW.client_a_id, NEW.client_b_id);

  -- Get manager IDs from clients
  SELECT manager_id INTO v_manager_a FROM public.clients WHERE id = NEW.client_a_id;
  SELECT manager_id INTO v_manager_b FROM public.clients WHERE id = NEW.client_b_id;

  -- Don't create conversation if same manager owns both clients or manager missing
  IF v_manager_a IS NULL OR v_manager_b IS NULL OR v_manager_a = v_manager_b THEN
    RETURN NEW;
  END IF;

  -- Get client names for system message
  SELECT full_name INTO v_client_a_name FROM public.clients WHERE id = NEW.client_a_id;
  SELECT full_name INTO v_client_b_name FROM public.clients WHERE id = NEW.client_b_id;

  -- === Create conversation ===
  -- Check if conversation already exists for this match
  IF EXISTS (SELECT 1 FROM public.conversations WHERE match_id = NEW.id) THEN
    RETURN NEW;
  END IF;

  -- Create conversation
  INSERT INTO public.conversations (participant_a, participant_b, match_id)
  VALUES (v_manager_a, v_manager_b, NEW.id)
  RETURNING id INTO v_conv_id;

  -- Insert system message
  INSERT INTO public.messages (conversation_id, sender_id, content, type)
  VALUES (
    v_conv_id,
    v_manager_a,
    '매칭이 성사되었습니다. ' || v_client_a_name || ' ↔ ' || v_client_b_name,
    'text'
  );

  -- Notify both managers about successful match
  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES
    (v_manager_a, '매칭 성사', v_client_a_name || ' ↔ ' || v_client_b_name || ' 매칭이 성사되었습니다.', 'match_response', jsonb_build_object('match_id', NEW.id, 'conversation_id', v_conv_id)),
    (v_manager_b, '매칭 성사', v_client_a_name || ' ↔ ' || v_client_b_name || ' 매칭이 성사되었습니다.', 'match_response', jsonb_build_object('match_id', NEW.id, 'conversation_id', v_conv_id));

  RETURN NEW;
END;
$$;

-- 4. Update notify_match_cancelled() to skip conflict-resolved cancellations
CREATE OR REPLACE FUNCTION public.notify_match_cancelled()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_client_a_name TEXT;
  v_client_b_name TEXT;
  v_target_manager_id UUID;
BEGIN
  IF OLD.status != 'pending' OR NEW.status != 'cancelled' THEN RETURN NEW; END IF;

  -- Skip notification for auto-cancelled conflicts (handled by handle_match_accepted)
  IF NEW.cancellation_reason = 'conflict_resolved' THEN RETURN NEW; END IF;

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
