-- Trigger function: auto-create conversation when match is accepted
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
BEGIN
  -- Only fire when status changes TO 'accepted'
  IF NEW.status <> 'accepted' OR OLD.status = 'accepted' THEN
    RETURN NEW;
  END IF;

  -- Check if conversation already exists for this match
  IF EXISTS (SELECT 1 FROM public.conversations WHERE match_id = NEW.id) THEN
    RETURN NEW;
  END IF;

  -- Get manager IDs from clients
  SELECT manager_id INTO v_manager_a FROM public.clients WHERE id = NEW.client_a_id;
  SELECT manager_id INTO v_manager_b FROM public.clients WHERE id = NEW.client_b_id;

  -- Don't create conversation if same manager owns both clients
  IF v_manager_a IS NULL OR v_manager_b IS NULL OR v_manager_a = v_manager_b THEN
    RETURN NEW;
  END IF;

  -- Get client names for system message
  SELECT full_name INTO v_client_a_name FROM public.clients WHERE id = NEW.client_a_id;
  SELECT full_name INTO v_client_b_name FROM public.clients WHERE id = NEW.client_b_id;

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

  -- Notify both managers
  INSERT INTO public.notifications (user_id, title, body, type, data)
  VALUES
    (v_manager_a, '매칭 성사', v_client_a_name || ' ↔ ' || v_client_b_name || ' 매칭이 성사되었습니다.', 'match_response', jsonb_build_object('match_id', NEW.id, 'conversation_id', v_conv_id)),
    (v_manager_b, '매칭 성사', v_client_a_name || ' ↔ ' || v_client_b_name || ' 매칭이 성사되었습니다.', 'match_response', jsonb_build_object('match_id', NEW.id, 'conversation_id', v_conv_id));

  RETURN NEW;
END;
$$;

-- Attach trigger to matches table
CREATE TRIGGER on_match_accepted
  AFTER UPDATE ON public.matches
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_match_accepted();

-- Auto-update conversations.last_message_at when a new message is inserted
CREATE OR REPLACE FUNCTION public.update_conversation_last_message_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE public.conversations
  SET last_message_at = NEW.created_at
  WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_message_inserted
  AFTER INSERT ON public.messages
  FOR EACH ROW
  EXECUTE FUNCTION public.update_conversation_last_message_at();
