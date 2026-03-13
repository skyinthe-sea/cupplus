-- Allow all authenticated users to read profile_likes for like count display
-- Drop the restrictive policy and replace with a broader read policy
DROP POLICY IF EXISTS "Users can view own likes" ON profile_likes;

-- All authenticated managers can view likes (needed for like count aggregation)
CREATE POLICY "Authenticated users can view all likes"
  ON profile_likes FOR SELECT
  USING (auth.uid() IS NOT NULL);
