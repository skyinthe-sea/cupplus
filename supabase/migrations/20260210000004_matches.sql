-- Matches (cross-region capable)
CREATE TABLE public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_a_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  client_b_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  client_a_region TEXT NOT NULL,
  client_b_region TEXT NOT NULL,
  manager_id UUID REFERENCES public.managers(id) ON DELETE SET NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'declined', 'meeting_scheduled', 'completed')),
  matched_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  responded_at TIMESTAMPTZ,
  notes TEXT,

  -- Prevent self-matching
  CHECK (client_a_id <> client_b_id)
);

CREATE INDEX idx_matches_client_a ON public.matches(client_a_id);
CREATE INDEX idx_matches_client_b ON public.matches(client_b_id);
CREATE INDEX idx_matches_status ON public.matches(status);

ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;

-- Cross-region read: either side's region matches
CREATE POLICY "matches_cross_region_read" ON public.matches
  FOR SELECT USING (
    client_a_region = public.get_region_id()
    OR client_b_region = public.get_region_id()
  );

-- Only the creating manager's region can insert/update
CREATE POLICY "matches_region_write" ON public.matches
  FOR INSERT WITH CHECK (
    client_a_region = public.get_region_id()
    OR client_b_region = public.get_region_id()
  );

CREATE POLICY "matches_region_update" ON public.matches
  FOR UPDATE USING (
    client_a_region = public.get_region_id()
    OR client_b_region = public.get_region_id()
  );

-- Admins/owners full access
CREATE POLICY "matches_admin_all" ON public.matches
  FOR ALL USING (
    (auth.jwt()->>'user_role') IN ('admin', 'owner')
  );
