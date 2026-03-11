-- Verification documents (business cards, certificates, etc.)
CREATE TABLE public.verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID NOT NULL REFERENCES public.clients(id) ON DELETE CASCADE,
  region_id TEXT NOT NULL,
  document_type TEXT NOT NULL
    CHECK (document_type IN ('business_card', 'employment_cert', 'degree_cert', 'income_cert')),
  storage_path TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewer_id UUID REFERENCES public.managers(id) ON DELETE SET NULL,
  rejection_reason TEXT,
  expires_at DATE,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ
);

ALTER TABLE public.verification_documents ENABLE ROW LEVEL SECURITY;

-- Region isolation
CREATE POLICY "verification_region_isolation" ON public.verification_documents
  FOR ALL USING (region_id = public.get_region_id());

-- Admins/owners full access
CREATE POLICY "verification_admin_all" ON public.verification_documents
  FOR ALL USING (
    (auth.jwt()->>'user_role') IN ('admin', 'owner')
  );

-- Auto-set region_id on insert
CREATE TRIGGER trg_verification_set_region
  BEFORE INSERT ON public.verification_documents
  FOR EACH ROW EXECUTE FUNCTION public.set_region_id();
