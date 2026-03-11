-- Private storage buckets
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('verification-documents', 'verification-documents', false),
  ('chat-images', 'chat-images', false),
  ('profile-photos', 'profile-photos', false),
  ('contract-signatures', 'contract-signatures', false);

-- Storage RLS: verification-documents
-- Authenticated users can upload to their own folder
CREATE POLICY "verification_docs_upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'verification-documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- Authenticated users can read from their region (via manager access)
CREATE POLICY "verification_docs_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'verification-documents');

-- Storage RLS: chat-images
CREATE POLICY "chat_images_upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'chat-images');

CREATE POLICY "chat_images_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'chat-images');

-- Storage RLS: profile-photos
CREATE POLICY "profile_photos_upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'profile-photos');

CREATE POLICY "profile_photos_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'profile-photos');

-- Storage RLS: contract-signatures
CREATE POLICY "contract_sigs_upload" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'contract-signatures');

CREATE POLICY "contract_sigs_read" ON storage.objects
  FOR SELECT TO authenticated
  USING (bucket_id = 'contract-signatures');
