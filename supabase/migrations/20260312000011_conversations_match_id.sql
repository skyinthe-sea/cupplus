-- Add match_id to conversations for 1:1 match-conversation mapping
ALTER TABLE public.conversations
  ADD COLUMN match_id UUID REFERENCES public.matches(id) ON DELETE SET NULL;

-- Unique constraint: one conversation per match
CREATE UNIQUE INDEX idx_conversations_match_id ON public.conversations(match_id)
  WHERE match_id IS NOT NULL;

-- Enable Realtime for conversations
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
