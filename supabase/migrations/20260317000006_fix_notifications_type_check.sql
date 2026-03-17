-- Add 'system' and 'client_registered' to notifications type CHECK constraint
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications ADD CONSTRAINT notifications_type_check
  CHECK (type IN ('new_match','new_message','match_response','verification_result','system','client_registered'));
