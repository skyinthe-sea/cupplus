-- Enable REPLICA IDENTITY FULL on matches table so that Supabase Realtime
-- can evaluate RLS policies (which reference client_a_region / client_b_region)
-- on INSERT events. Without this, WAL only includes the PK and Realtime
-- cannot deliver events to the receiving manager.
ALTER TABLE matches REPLICA IDENTITY FULL;
