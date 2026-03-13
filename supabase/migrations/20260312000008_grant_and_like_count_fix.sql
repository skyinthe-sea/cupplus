-- Grant execute on create_match_atomic to authenticated users
GRANT EXECUTE ON FUNCTION public.create_match_atomic(UUID, UUID, TEXT, TEXT, INT) TO authenticated;
