-- Allow generic 'verification_doc' type (simplified UI without type selection)
ALTER TABLE manager_verification_documents DROP CONSTRAINT IF EXISTS manager_verification_documents_document_type_check;
ALTER TABLE manager_verification_documents ADD CONSTRAINT manager_verification_documents_document_type_check
  CHECK (document_type IN ('business_card', 'employment_cert', 'business_registration', 'verification_doc'));
