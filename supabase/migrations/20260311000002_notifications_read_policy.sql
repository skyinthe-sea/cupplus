-- Allow authenticated users to update their own notifications (mark as read)
CREATE POLICY "notifications_owner_update_read" ON public.notifications
  FOR UPDATE USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
