-- Add marketing_consent column to contract_agreements for tracking opt-in
ALTER TABLE contract_agreements
  ADD COLUMN IF NOT EXISTS marketing_consent BOOLEAN NOT NULL DEFAULT false;
