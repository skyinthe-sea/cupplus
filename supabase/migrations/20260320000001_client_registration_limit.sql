-- Server-side safety net: prevent any manager from exceeding the absolute max (Gold = 10)
CREATE OR REPLACE FUNCTION check_client_limit()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM clients
  WHERE manager_id = NEW.manager_id AND status = 'active';

  IF v_count >= 10 THEN
    RAISE EXCEPTION 'Client limit exceeded (max 10 active clients)';
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_client_limit
  BEFORE INSERT ON clients
  FOR EACH ROW EXECUTE FUNCTION check_client_limit();
