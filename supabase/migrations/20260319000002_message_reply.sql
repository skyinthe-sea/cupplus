-- Reply/quote support for messages
-- Adds reply_to_id FK with ON DELETE SET NULL (original deleted → reply still works)

ALTER TABLE public.messages
  ADD COLUMN reply_to_id UUID REFERENCES public.messages(id) ON DELETE SET NULL;

CREATE INDEX idx_messages_reply_to ON public.messages(reply_to_id)
  WHERE reply_to_id IS NOT NULL;
