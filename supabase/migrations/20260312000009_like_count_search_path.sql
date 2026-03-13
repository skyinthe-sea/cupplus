-- Fix update_client_like_count: add search_path for SECURITY DEFINER safety
CREATE OR REPLACE FUNCTION public.update_client_like_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.clients SET like_count = like_count + 1 WHERE id = NEW.client_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.clients SET like_count = GREATEST(like_count - 1, 0) WHERE id = OLD.client_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;
