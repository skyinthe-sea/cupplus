-- Add hobbies and bio columns to clients table
ALTER TABLE clients ADD COLUMN IF NOT EXISTS hobbies TEXT[] DEFAULT '{}';
ALTER TABLE clients ADD COLUMN IF NOT EXISTS bio TEXT;
