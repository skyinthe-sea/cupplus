-- Daily match counter (free tier rate limiting)
CREATE TABLE public.daily_match_counts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manager_id UUID NOT NULL REFERENCES public.managers(id) ON DELETE CASCADE,
  match_date DATE NOT NULL DEFAULT CURRENT_DATE,
  count INT NOT NULL DEFAULT 0,
  UNIQUE(manager_id, match_date)
);

CREATE INDEX idx_daily_match_manager_date ON public.daily_match_counts(manager_id, match_date);

ALTER TABLE public.daily_match_counts ENABLE ROW LEVEL SECURITY;

-- Managers can read their own counts
CREATE POLICY "daily_match_counts_owner_read" ON public.daily_match_counts
  FOR SELECT USING (manager_id = auth.uid());

-- Increment handled server-side (Edge Function or DB function)
-- No direct INSERT/UPDATE for clients to prevent manipulation
