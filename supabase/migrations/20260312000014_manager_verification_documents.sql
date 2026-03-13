-- Manager verification documents table
-- For manager identity verification (business card, employment cert, business registration)
CREATE TABLE IF NOT EXISTS public.manager_verification_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  manager_id UUID NOT NULL REFERENCES public.managers(id) ON DELETE CASCADE,
  document_type TEXT NOT NULL
    CHECK (document_type IN ('business_card', 'employment_cert', 'business_registration')),
  storage_path TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  reviewed_at TIMESTAMPTZ
);

-- Indexes
CREATE INDEX idx_mgr_verification_manager_status
  ON public.manager_verification_documents(manager_id, status);

-- Enable RLS
ALTER TABLE public.manager_verification_documents ENABLE ROW LEVEL SECURITY;

-- Managers can read their own documents
CREATE POLICY "mgr_verification_own_read"
  ON public.manager_verification_documents
  FOR SELECT
  USING (manager_id = auth.uid());

-- Managers can insert their own documents
CREATE POLICY "mgr_verification_own_insert"
  ON public.manager_verification_documents
  FOR INSERT
  WITH CHECK (manager_id = auth.uid());

-- Admins/owners full access (for review)
CREATE POLICY "mgr_verification_admin_all"
  ON public.manager_verification_documents
  FOR ALL
  USING ((auth.jwt()->>'user_role') IN ('admin', 'owner'));
