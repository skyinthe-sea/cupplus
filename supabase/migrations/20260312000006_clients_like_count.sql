-- Denormalized like_count on clients for server-side sorting
ALTER TABLE clients ADD COLUMN IF NOT EXISTS like_count INT NOT NULL DEFAULT 0;

-- Trigger to auto-update like_count on profile_likes INSERT/DELETE
CREATE OR REPLACE FUNCTION update_client_like_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE clients SET like_count = like_count + 1 WHERE id = NEW.client_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE clients SET like_count = GREATEST(like_count - 1, 0) WHERE id = OLD.client_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER trg_profile_likes_count
AFTER INSERT OR DELETE ON profile_likes
FOR EACH ROW EXECUTE FUNCTION update_client_like_count();

-- Backfill existing like counts (if any)
UPDATE clients c
SET like_count = (
  SELECT COUNT(*) FROM profile_likes pl WHERE pl.client_id = c.id
);

-- Index for sort by likes
CREATE INDEX idx_clients_like_count ON clients(like_count DESC);
