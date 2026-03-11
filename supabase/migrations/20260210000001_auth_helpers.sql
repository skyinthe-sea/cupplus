-- Helper function: extract region_id from JWT app_metadata
-- NOTE: placed in public schema (auth schema is managed by GoTrue)
CREATE OR REPLACE FUNCTION public.get_region_id()
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT NULLIF(
    ((current_setting('request.jwt.claims', true)::jsonb
      ->>'app_metadata')::jsonb ->>'region_id'), ''
  )::text
$$;

-- Trigger function: auto-set region_id on INSERT
CREATE OR REPLACE FUNCTION public.set_region_id()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.region_id := public.get_region_id();
  RETURN NEW;
END;
$$;

-- Trigger function: auto-set updated_at on UPDATE
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;
