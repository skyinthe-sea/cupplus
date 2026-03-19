-- Client tags for CRM categorization
CREATE TABLE client_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  manager_id UUID NOT NULL REFERENCES managers(id),
  tag TEXT NOT NULL,
  color TEXT DEFAULT '#2D5A8E',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(client_id, tag, manager_id)
);

-- Indexes
CREATE INDEX idx_client_tags_client ON client_tags(client_id);
CREATE INDEX idx_client_tags_manager ON client_tags(manager_id);
CREATE INDEX idx_client_tags_tag ON client_tags(tag);

-- RLS
ALTER TABLE client_tags ENABLE ROW LEVEL SECURITY;

CREATE POLICY "managers_own_tags" ON client_tags
  FOR ALL USING (manager_id = auth.uid());
