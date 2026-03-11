-- Clients (members managed by matchmakers)
CREATE TABLE public.clients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  region_id TEXT NOT NULL,
  manager_id UUID REFERENCES public.managers(id) ON DELETE SET NULL,
  full_name TEXT NOT NULL,
  gender TEXT NOT NULL CHECK (gender IN ('M', 'F')),
  birth_date DATE,
  education TEXT,
  occupation TEXT,
  company TEXT,
  annual_income_range TEXT,
  religion TEXT,
  height_cm INT,
  profile_photo_url TEXT,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'paused', 'matched', 'withdrawn')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_clients_region ON public.clients(region_id);
CREATE INDEX idx_clients_manager ON public.clients(manager_id);

ALTER TABLE public.clients ENABLE ROW LEVEL SECURITY;

-- Region isolation
CREATE POLICY "clients_region_isolation" ON public.clients
  FOR ALL USING (region_id = public.get_region_id());

-- Admins/owners full access
CREATE POLICY "clients_admin_all" ON public.clients
  FOR ALL USING (
    (auth.jwt()->>'user_role') IN ('admin', 'owner')
  );

-- Auto-set region_id on insert
CREATE TRIGGER trg_clients_set_region
  BEFORE INSERT ON public.clients
  FOR EACH ROW EXECUTE FUNCTION public.set_region_id();

-- Auto-set updated_at on update
CREATE TRIGGER trg_clients_updated_at
  BEFORE UPDATE ON public.clients
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
