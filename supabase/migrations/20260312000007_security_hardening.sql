-- Security hardening: Fix create_match_atomic with search_path + single-statement lock
CREATE OR REPLACE FUNCTION public.create_match_atomic(
  p_client_a_id UUID,
  p_client_b_id UUID,
  p_client_a_region TEXT,
  p_client_b_region TEXT,
  p_daily_limit INT DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_manager_id UUID := auth.uid();
  v_today DATE := CURRENT_DATE;
  v_current_count INT;
  v_match_id UUID;
  v_target_manager_id UUID;
BEGIN
  -- Single-statement upsert + lock: returns current count
  INSERT INTO public.daily_match_counts (manager_id, match_date, count)
  VALUES (v_manager_id, v_today, 0)
  ON CONFLICT (manager_id, match_date) DO UPDATE SET count = public.daily_match_counts.count
  RETURNING count INTO v_current_count;

  IF v_current_count >= p_daily_limit THEN
    RETURN jsonb_build_object('error', 'daily_limit');
  END IF;

  -- Insert match
  INSERT INTO public.matches (client_a_id, client_b_id, client_a_region, client_b_region, manager_id, status)
  VALUES (p_client_a_id, p_client_b_id, p_client_a_region, p_client_b_region, v_manager_id, 'pending')
  RETURNING id INTO v_match_id;

  -- Increment daily count
  UPDATE public.daily_match_counts
  SET count = count + 1
  WHERE manager_id = v_manager_id AND match_date = v_today;

  -- Create notification for target manager
  SELECT manager_id INTO v_target_manager_id
  FROM public.clients WHERE id = p_client_b_id;

  IF v_target_manager_id IS NOT NULL THEN
    INSERT INTO public.notifications (user_id, title, body, type, data)
    VALUES (
      v_target_manager_id,
      '새 매칭 요청',
      '새로운 매칭 요청이 도착했습니다.',
      'new_match',
      jsonb_build_object('match_id', v_match_id, 'client_a_id', p_client_a_id, 'client_b_id', p_client_b_id)
    );
  END IF;

  RETURN jsonb_build_object('match_id', v_match_id);
END;
$$;
