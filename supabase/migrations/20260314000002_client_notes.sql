-- CRM: Client notes & timeline

CREATE TABLE client_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
  manager_id UUID NOT NULL REFERENCES managers(id),
  region_id TEXT NOT NULL,
  note_type TEXT DEFAULT 'general',  -- general|preference|meeting_feedback|schedule
  content TEXT NOT NULL,
  scheduled_at TIMESTAMPTZ,
  is_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_client_notes_client ON client_notes(client_id);
CREATE INDEX idx_client_notes_manager ON client_notes(manager_id);
CREATE INDEX idx_client_notes_schedule ON client_notes(scheduled_at)
  WHERE note_type = 'schedule' AND is_completed = false;

-- RLS
ALTER TABLE client_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "client_notes_select" ON client_notes
  FOR SELECT USING (
    region_id = (
      SELECT NULLIF(
        ((current_setting('request.jwt.claims')::jsonb->>'app_metadata')::jsonb->>'region_id'), ''
      )::text
    )
    AND manager_id = auth.uid()
  );

CREATE POLICY "client_notes_insert" ON client_notes
  FOR INSERT WITH CHECK (
    region_id = (
      SELECT NULLIF(
        ((current_setting('request.jwt.claims')::jsonb->>'app_metadata')::jsonb->>'region_id'), ''
      )::text
    )
    AND manager_id = auth.uid()
  );

CREATE POLICY "client_notes_update" ON client_notes
  FOR UPDATE USING (manager_id = auth.uid());

CREATE POLICY "client_notes_delete" ON client_notes
  FOR DELETE USING (manager_id = auth.uid());
