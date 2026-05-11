-- ============================================
-- INGGO VTC - Migration 006
-- Add missing columns used by Flutter app
-- ============================================

-- Add sexe, pays, phone_verified columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS sexe TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS pays TEXT DEFAULT 'Djibouti';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN NOT NULL DEFAULT false;

-- Add profiles INSERT policy for new user registration
-- (The signUp flow inserts into profiles from the client side)
-- Use DO block to avoid error if policy already exists from migration 005
DO $$
BEGIN
    CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (id = auth.uid());
EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'Policy "Users can insert own profile" already exists, skipping.';
END $$;

-- Add reviews table for driver ratings
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ride_id UUID NOT NULL REFERENCES rides(id) ON DELETE CASCADE,
    from_user_id UUID NOT NULL REFERENCES profiles(id),
    to_user_id UUID NOT NULL REFERENCES profiles(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_reviews_ride_id ON reviews(ride_id);
CREATE INDEX IF NOT EXISTS idx_reviews_to_user_id ON reviews(to_user_id);

ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read reviews" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can insert reviews" ON reviews FOR INSERT WITH CHECK (from_user_id = auth.uid());

-- Fix: Update driver stats trigger should use (price - commission) as earnings
-- The original trigger adds `commission` but driver earns `price - commission`
-- For 250 FDJ price with 125 FDJ commission, driver earns 125 FDJ (same value here but conceptually wrong)
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

-- Auto-pay cash rides on completion
CREATE OR REPLACE FUNCTION auto_pay_cash()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        IF NEW.payment_method = 'cash' THEN
            UPDATE rides SET payment_status = 'paid' WHERE id = NEW.id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS rides_auto_pay_cash ON rides;
CREATE TRIGGER rides_auto_pay_cash
    AFTER UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION auto_pay_cash();

-- Add password reset tokens table
CREATE TABLE IF NOT EXISTS password_resets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    used BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at TIMESTAMPTZ NOT NULL DEFAULT (now() + interval '1 hour')
);

CREATE INDEX IF NOT EXISTS idx_password_resets_token ON password_resets(token);
CREATE INDEX IF NOT EXISTS idx_password_resets_user_id ON password_resets(user_id);

ALTER TABLE password_resets ENABLE ROW LEVEL SECURITY;

-- Add Realtime for drivers table (for driver location tracking)
-- Use DO block to avoid error if already added by migration 005
DO $$
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE drivers;
EXCEPTION WHEN duplicate_object THEN
    RAISE NOTICE 'Table "drivers" already in supabase_realtime publication, skipping.';
END $$;
