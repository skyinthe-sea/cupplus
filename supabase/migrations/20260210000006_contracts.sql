-- Contract agreements (e-signature records)
CREATE TABLE public.contract_agreements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  manager_id UUID NOT NULL REFERENCES public.managers(id) ON DELETE CASCADE,
  region_id TEXT NOT NULL,
  contract_version TEXT NOT NULL,
  contract_hash TEXT NOT NULL,
  agreed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ip_address INET,
  device_info JSONB,
  signature_storage_path TEXT,
  UNIQUE(client_id, contract_version)
);

ALTER TABLE public.contract_agreements ENABLE ROW LEVEL SECURITY;

-- Region isolation
CREATE POLICY "contracts_region_isolation" ON public.contract_agreements
  FOR ALL USING (region_id = public.get_region_id());

-- Admins/owners full access
CREATE POLICY "contracts_admin_all" ON public.contract_agreements
  FOR ALL USING (
    (auth.jwt()->>'user_role') IN ('admin', 'owner')
  );

-- Auto-set region_id on insert
CREATE TRIGGER trg_contracts_set_region
  BEFORE INSERT ON public.contract_agreements
  FOR EACH ROW EXECUTE FUNCTION public.set_region_id();
