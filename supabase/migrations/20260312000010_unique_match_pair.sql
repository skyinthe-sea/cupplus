-- Prevent duplicate matches (A↔B or B↔A) for active matches
CREATE UNIQUE INDEX IF NOT EXISTS idx_matches_unique_pair
  ON matches (LEAST(client_a_id, client_b_id), GREATEST(client_a_id, client_b_id))
  WHERE status NOT IN ('declined', 'completed');
