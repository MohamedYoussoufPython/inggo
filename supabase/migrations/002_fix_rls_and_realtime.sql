-- ============================================
-- INGGO VTC - Fix RLS Policies & Enable Realtime
-- This migration fixes the 3 RLS bugs that block the app:
--   1. Drivers cannot SEE rides with status='searching'
--   2. Drivers cannot ACCEPT (UPDATE) rides with status='searching'
--   3. Nobody can INSERT notifications
-- It also enables Supabase Realtime on rides table.
-- ============================================

-- ============================================
-- 1. FIX RIDES RLS — Drop broken policies and recreate
-- ============================================

-- Drop old SELECT policy (only allowed client_id or driver_id to read)
DROP POLICY IF EXISTS "Users can read own rides" ON rides;

-- New SELECT policy: participants can read their rides,
-- AND verified online drivers can see available (searching) rides
CREATE POLICY "Users can read own rides or available rides" ON rides FOR SELECT USING (
    client_id = auth.uid()
    OR driver_id = auth.uid()
    OR (
        status = 'searching'
        AND EXISTS (
            SELECT 1 FROM drivers
            WHERE id = auth.uid()
            AND is_verified = true
            AND is_online = true
        )
    )
);

-- Drop old UPDATE policy (only allowed client_id or driver_id to update)
DROP POLICY IF EXISTS "Driver or client can update ride" ON rides;

-- New UPDATE policy: participants can update their rides,
-- AND verified online drivers can accept (update) searching rides
CREATE POLICY "Driver or client can update ride" ON rides FOR UPDATE USING (
    client_id = auth.uid()
    OR driver_id = auth.uid()
    OR (
        status = 'searching'
        AND EXISTS (
            SELECT 1 FROM drivers
            WHERE id = auth.uid()
            AND is_verified = true
            AND is_online = true
        )
    )
);

-- ============================================
-- 2. FIX NOTIFICATIONS RLS — Add missing INSERT policy
-- ============================================

-- The original schema had no INSERT policy for notifications.
-- Without this, NotificationService.sendNotification() fails silently.
CREATE POLICY "Users can insert own notifications" ON notifications
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- ============================================
-- 3. ENABLE REALTIME on rides & notifications tables
-- ============================================
-- Required for the Realtime Supabase subscription that notifies
-- drivers of new rides and clients of ride status changes.
-- Run this ALSO in Supabase Dashboard → Database → Replication
-- by enabling Realtime for these tables.

ALTER PUBLICATION supabase_realtime ADD TABLE rides;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- ============================================
-- 4. FIX PROFILES RLS — Drivers need to read client profiles
-- ============================================
-- When a driver accepts a ride, they need to see the client's name/phone.
-- The current policy only allows users to read their own profile.
-- Add: verified drivers can read client profiles.

DROP POLICY IF EXISTS "Users can read own profile" ON profiles;

CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (
    auth.uid() = id
);

-- New policy: verified drivers can read client profiles (for ride info)
CREATE POLICY "Drivers can read client profiles" ON profiles FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM drivers
        WHERE id = auth.uid()
        AND is_verified = true
    )
);

-- Keep admin policy
DROP POLICY IF EXISTS "Admins can read all profiles" ON profiles;
CREATE POLICY "Admins can read all profiles" ON profiles FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
