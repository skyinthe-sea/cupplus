-- Auto-sync managers.verification_status when document is approved/rejected
CREATE OR REPLACE FUNCTION public.sync_manager_verification_status()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.status = 'approved' THEN
    UPDATE managers SET verification_status = 'verified'
    WHERE id = NEW.manager_id;
  ELSIF NEW.status = 'rejected' THEN
    -- Only set rejected if no other approved doc exists
    IF NOT EXISTS (
      SELECT 1 FROM manager_verification_documents
      WHERE manager_id = NEW.manager_id
        AND status = 'approved'
        AND id != NEW.id
    ) THEN
      UPDATE managers SET verification_status = 'rejected'
      WHERE id = NEW.manager_id;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_manager_verification ON manager_verification_documents;
CREATE TRIGGER trg_sync_manager_verification
  AFTER UPDATE OF status ON manager_verification_documents
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_manager_verification_status();
