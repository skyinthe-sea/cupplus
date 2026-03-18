-- Soft delete support for messages
-- Adds deleted_at/deleted_by columns and sets REPLICA IDENTITY FULL
-- so Realtime UPDATE events include the full row.

ALTER TABLE public.messages
  ADD COLUMN deleted_at TIMESTAMPTZ,
  ADD COLUMN deleted_by UUID REFERENCES public.managers(id);

-- Realtime UPDATE events need full row to detect soft-delete changes
ALTER TABLE public.messages REPLICA IDENTITY FULL;
