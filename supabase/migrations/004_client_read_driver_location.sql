-- ============================================
-- Allow clients to read the driver's real-time location
-- when they have an active ride together.
-- Without this, the Realtime subscription on the
-- drivers table returns no rows for the client.
-- ============================================

CREATE POLICY "Clients can read assigned driver location" ON drivers
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM rides
      WHERE rides.client_id = auth.uid()
        AND rides.driver_id = drivers.id
        AND rides.status IN ('accepted', 'in_progress')
    )
  );
