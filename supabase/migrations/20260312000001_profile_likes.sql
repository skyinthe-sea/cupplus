-- Profile likes table for marketplace heart/like feature
CREATE TABLE profile_likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manager_id UUID NOT NULL REFERENCES managers(id) ON DELETE CASCADE,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(manager_id, client_id)
);

-- Indexes
CREATE INDEX idx_profile_likes_manager ON profile_likes(manager_id);
CREATE INDEX idx_profile_likes_client ON profile_likes(client_id);

-- RLS
ALTER TABLE profile_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own likes"
  ON profile_likes FOR SELECT
  USING (manager_id = auth.uid());

CREATE POLICY "Users can insert own likes"
  ON profile_likes FOR INSERT
  WITH CHECK (manager_id = auth.uid());

CREATE POLICY "Users can delete own likes"
  ON profile_likes FOR DELETE
  USING (manager_id = auth.uid());
