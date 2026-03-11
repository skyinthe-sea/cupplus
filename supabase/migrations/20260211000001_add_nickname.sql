-- Add nickname column to managers
ALTER TABLE public.managers ADD COLUMN nickname TEXT;

-- Case-insensitive unique index
CREATE UNIQUE INDEX idx_managers_nickname_unique
  ON public.managers (LOWER(nickname));

-- RPC: check if a nickname is available
CREATE OR REPLACE FUNCTION public.check_nickname_available(p_nickname TEXT)
RETURNS BOOLEAN LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN NOT EXISTS (
    SELECT 1 FROM public.managers WHERE LOWER(nickname) = LOWER(p_nickname)
  );
END;
$$;

-- RPC: update nickname with validation + uniqueness check
CREATE OR REPLACE FUNCTION public.update_nickname(p_nickname TEXT)
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  -- Validate format: 2-20 chars, Korean/English/numbers/underscore
  IF p_nickname !~ '^[a-zA-Z0-9가-힣_]{2,20}$' THEN
    RAISE EXCEPTION 'Invalid nickname format';
  END IF;

  -- Check uniqueness (excluding current user)
  IF EXISTS (
    SELECT 1 FROM public.managers
    WHERE LOWER(nickname) = LOWER(p_nickname) AND id != auth.uid()
  ) THEN
    RAISE EXCEPTION 'Nickname already taken';
  END IF;

  UPDATE public.managers SET nickname = p_nickname WHERE id = auth.uid();
END;
$$;
