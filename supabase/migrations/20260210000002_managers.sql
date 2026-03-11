-- Managers (users / matchmakers)
CREATE TABLE public.managers (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id TEXT NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  role TEXT NOT NULL DEFAULT 'manager'
    CHECK (role IN ('manager', 'admin', 'owner')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_managers_region ON public.managers(region_id);

ALTER TABLE public.managers ENABLE ROW LEVEL SECURITY;

-- Managers can read within their region
CREATE POLICY "managers_region_read" ON public.managers
  FOR SELECT USING (region_id = public.get_region_id());

-- Managers can update their own row
CREATE POLICY "managers_self_update" ON public.managers
  FOR UPDATE USING (id = auth.uid());

-- Admins/owners full access
CREATE POLICY "managers_admin_all" ON public.managers
  FOR ALL USING (
    (auth.jwt()->>'user_role') IN ('admin', 'owner')
  );

-- Auto-set region_id on insert
CREATE TRIGGER trg_managers_set_region
  BEFORE INSERT ON public.managers
  FOR EACH ROW EXECUTE FUNCTION public.set_region_id();
