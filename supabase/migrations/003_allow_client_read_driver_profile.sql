-- ============================================
-- 1. Allow clients to read the profile of the driver
--    assigned to their active ride (accepted / in_progress).
--    Without this, TripInProgressScreen cannot fetch
--    the driver's name, phone, or avatar.
-- ============================================

CREATE POLICY "Clients can read assigned driver profile" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM rides
      WHERE rides.client_id = auth.uid()
        AND rides.driver_id = profiles.id
        AND rides.status IN ('accepted', 'in_progress')
    )
  );

-- ============================================
-- 2. Allow a driver to insert a notification for
--    the client of their active/completed ride.
--    The existing policy only allows inserting your
--    own notifications (user_id = auth.uid()), which
--    blocks the driver from notifying the client
--    when they accept or complete a ride.
-- ============================================

CREATE POLICY "Driver can notify ride client" ON notifications
  FOR INSERT WITH CHECK (
    user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM rides
      WHERE rides.driver_id = auth.uid()
        AND rides.client_id = notifications.user_id
        AND rides.status IN ('accepted', 'in_progress', 'completed')
    )
  );
