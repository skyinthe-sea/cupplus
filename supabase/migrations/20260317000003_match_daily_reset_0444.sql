-- Update create_match_atomic to use 04:44 KST business date instead of CURRENT_DATE.
-- Before 04:44, the business date is the previous calendar day.
-- Also updates free tier default from 1 to 3.
CREATE OR REPLACE FUNCTION create_match_atomic(
  p_client_a_id UUID,
  p_client_b_id UUID,
  p_client_a_region TEXT,
  p_client_b_region TEXT,
  p_daily_limit INT DEFAULT 3
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_manager_id UUID := auth.uid();
  v_now TIMESTAMPTZ := now();
  v_kst TIMESTAMPTZ := v_now AT TIME ZONE 'Asia/Seoul';
  -- Business date: before 04:44 KST counts as previous day
  v_today DATE := CASE
    WHEN v_kst::time < '04:44:00'::time
      THEN (v_kst - interval '1 day')::date
    ELSE v_kst::date
  END;
  v_current_count INT;
  v_match_id UUID;
BEGIN
  -- Lock the daily_match_counts row for this manager+date to prevent concurrent inserts
  INSERT INTO daily_match_counts (manager_id, match_date, count)
  VALUES (v_manager_id, v_today, 0)
  ON CONFLICT (manager_id, match_date) DO NOTHING;

  SELECT count INTO v_current_count
  FROM daily_match_counts
  WHERE manager_id = v_manager_id AND match_date = v_today
  FOR UPDATE;

  IF v_current_count >= p_daily_limit THEN
    RETURN jsonb_build_object('error', 'daily_limit');
  END IF;

  -- Insert match
  INSERT INTO matches (client_a_id, client_b_id, client_a_region, client_b_region, manager_id, status)
  VALUES (p_client_a_id, p_client_b_id, p_client_a_region, p_client_b_region, v_manager_id, 'pending')
  RETURNING id INTO v_match_id;

  -- Increment daily count
  UPDATE daily_match_counts
  SET count = count + 1
  WHERE manager_id = v_manager_id AND match_date = v_today;

  -- Notification is handled by notify_new_match trigger on matches table

  RETURN jsonb_build_object('match_id', v_match_id);
END;
$$;
