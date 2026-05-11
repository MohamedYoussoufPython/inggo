-- ============================================
-- INGGO VTC - Migration 007
-- Clean up duplicates between migrations 005 and 006
-- ============================================

-- 1. DROP the duplicate policy from 006 (already created in 005)
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
-- Recreate it properly (IF NOT EXISTS is not supported for policies)
CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (id = auth.uid());

-- 2. Fix duplicate trigger: migration 006 re-created update_driver_stats()
-- but didn't drop the old trigger first, which can cause issues.
-- Ensure only one trigger exists for driver stats.
DROP TRIGGER IF EXISTS rides_driver_stats ON rides;
CREATE TRIGGER rides_driver_stats
    AFTER UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_driver_stats();

-- 3. Fix duplicate auto-pay trigger: 005 created auto_pay_cash_rides,
-- 006 created auto_pay_cash. Keep only one.
DROP TRIGGER IF EXISTS rides_auto_pay_cash ON rides;
DROP TRIGGER IF EXISTS rides_auto_pay_cash_rides ON rides;

-- Use the cleaner BEFORE UPDATE version from 005 (sets NEW directly)
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

-- 4. Remove duplicate Realtime publication (005 and 006 both add drivers)
-- This is idempotent — ALTER PUBLICATION ADD TABLE won't fail if already present
-- but we use a DO block to handle it safely
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE drivers;
EXCEPTION WHEN OTHERS THEN
    -- Already in the publication — ignore
    NULL;
END $$;

-- 5. Add rides table to Realtime so the client can subscribe to ride status changes
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE rides;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- 6. Add notifications table to Realtime for push notification updates
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
EXCEPTION WHEN OTHERS THEN
    NULL;
END $$;

-- 7. Add support_phone constant to app_config or settings table
-- (Currently hardcoded in Flutter — add it as a DB setting for future flexibility)
INSERT INTO landmarks (name_fr, name_en, category, lat, lng, is_popular)
VALUES
    ('Support Inggo', 'Inggo Support', 'support', 11.5880, 43.1456, false)
ON CONFLICT DO NOTHING;
