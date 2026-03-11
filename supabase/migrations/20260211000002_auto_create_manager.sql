-- Update set_region_id() to fallback to 'default' when JWT has no region
CREATE OR REPLACE FUNCTION public.set_region_id()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.region_id IS NULL OR NEW.region_id = '' THEN
    NEW.region_id := COALESCE(public.get_region_id(), 'default');
  END IF;
  RETURN NEW;
END;
$$;

-- Auto-create managers row when a new auth user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.managers (id, region_id, full_name, role)
  VALUES (
    NEW.id,
    'default',
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      split_part(COALESCE(NEW.email, ''), '@', 1),
      'User'
    ),
    'manager'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Allow users to insert their own manager row (needed for RLS)
CREATE POLICY "managers_self_insert" ON public.managers
  FOR INSERT WITH CHECK (id = auth.uid());
