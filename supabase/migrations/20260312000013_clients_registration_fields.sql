-- Add missing columns for client registration 5-step form
-- Step 1: phone, email
-- Step 2: education_level, school, major
-- Step 3: body_type

-- Step 1 fields
ALTER TABLE clients ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS email TEXT;

-- Step 2 fields: structured education (education_level + school + major)
-- Keeps existing 'education' column as legacy/free-text fallback
ALTER TABLE clients ADD COLUMN IF NOT EXISTS education_level TEXT
  CHECK (education_level IS NULL OR education_level IN (
    'high_school', 'associate', 'bachelor', 'master', 'doctorate'
  ));
ALTER TABLE clients ADD COLUMN IF NOT EXISTS school TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS major TEXT;

-- Step 3 fields
ALTER TABLE clients ADD COLUMN IF NOT EXISTS body_type TEXT
  CHECK (body_type IS NULL OR body_type IN (
    'slim', 'slightly_slim', 'average', 'slightly_chubby', 'chubby'
  ));
