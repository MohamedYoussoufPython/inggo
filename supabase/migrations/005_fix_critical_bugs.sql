-- ============================================
-- INGGO VTC - Fix Critical Bugs
-- This migration fixes 5 critical issues:
--   1. No INSERT policy on profiles → users cannot register
--   2. drivers table not in Realtime → no GPS tracking, no verification redirect
--   3. Double counting: trigger + Dart both increment stats
--   4. Trigger adds commission instead of driver earning (price - commission)
--   5. Unverified driver can go online and receive rides
-- ============================================

-- ============================================
-- 1. FIX: Add INSERT policy on profiles
-- Without this, new users CANNOT register at all.
-- ============================================
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (id = auth.uid());

-- ============================================
-- 2. FIX: Add drivers table to Realtime
-- Required for:
--   - Client to see driver GPS position on map
--   - Driver to be redirected after admin verification
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE drivers;

-- ============================================
-- 3. FIX: Replace double-counting trigger
-- The old trigger incremented total_rides +1 and added commission.
-- But completeRide() in Dart ALSO did the same.
-- Now the trigger is the SINGLE source of truth for stats.
-- Dart code no longer updates total_rides/total_earnings.
-- ============================================
DROP TRIGGER IF EXISTS rides_driver_stats ON rides;
DROP FUNCTION IF EXISTS update_driver_stats();

CREATE OR REPLACE FUNCTION update_driver_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE drivers
        SET total_rides = total_rides + 1,
            total_earnings = total_earnings + (NEW.price - NEW.commission)
        WHERE id = NEW.driver_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rides_driver_stats
    AFTER UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_driver_stats();

-- ============================================
-- 4. FIX: Prevent unverified drivers from going online
-- The RLS policy now requires is_verified = true
-- to set is_online = true.
-- ============================================
DROP POLICY IF EXISTS "Driver can update own record" ON drivers;

CREATE POLICY "Driver can update own record" ON drivers FOR UPDATE USING (id = auth.uid())
  WITH CHECK (
    -- Allow all updates EXCEPT setting is_online = true when not verified
    CASE
      WHEN is_online = true AND is_verified = false THEN false
      ELSE true
    END
  );

-- ============================================
-- 5. FIX: Set payment_status to 'paid' when ride is completed with cash
-- This trigger auto-pays cash rides on completion.
-- ============================================
CREATE OR REPLACE FUNCTION auto_pay_cash_rides()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND NEW.payment_method = 'cash' AND NEW.payment_status = 'pending' THEN
        NEW.payment_status = 'paid';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rides_auto_pay_cash
    BEFORE UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION auto_pay_cash_rides();
