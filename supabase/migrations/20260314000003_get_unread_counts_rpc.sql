-- RPC function to batch-fetch unread message counts per conversation
-- Replaces N+1 individual count queries with a single call
CREATE OR REPLACE FUNCTION get_unread_counts(p_user_id UUID, p_conv_ids UUID[])
RETURNS TABLE(conversation_id UUID, unread_count BIGINT)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path = public
AS $$
  SELECT m.conversation_id, COUNT(*)::BIGINT
  FROM messages m
  WHERE m.conversation_id = ANY(p_conv_ids)
    AND m.sender_id != p_user_id
    AND m.is_read = false
  GROUP BY m.conversation_id;
$$;
