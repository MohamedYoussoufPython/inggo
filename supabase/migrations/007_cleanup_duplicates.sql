-- ============================================
-- INGGO VTC - Migration 007
-- Clean up duplicates between migrations 005 and 006
-- ============================================

-- 1. DROP and recreate the INSERT policy cleanly (avoid duplicate_object error)
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (id = auth.uid());

-- 2. Ensure only one trigger exists for driver stats
DROP TRIGGER IF EXISTS rides_driver_stats ON rides;
CREATE TRIGGER rides_driver_stats
    AFTER UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_driver_stats();

-- 3. Fix auto-pay trigger: keep the BEFORE UPDATE version (from 005)
-- which sets NEW.payment_status directly instead of doing an extra UPDATE
DROP TRIGGER IF EXISTS rides_auto_pay_cash ON rides;
DROP TRIGGER IF EXISTS rides_auto_pay_cash_rides ON rides;

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

-- 4. Add rides table to Realtime so client can subscribe to ride status changes
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE rides;
EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'Table "rides" already in supabase_realtime publication, skipping.';
END $$;

-- 5. Add notifications table to Realtime for push notification updates
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'Table "notifications" already in supabase_realtime publication, skipping.';
END $$;

-- 6. Add profiles table to Realtime (for profile update tracking)
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'Table "profiles" already in supabase_realtime publication, skipping.';
END $$;
