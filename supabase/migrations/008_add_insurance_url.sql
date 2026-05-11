-- ============================================
-- INGGO VTC - Migration 008
-- Add insurance_url column to drivers table
-- ============================================

ALTER TABLE drivers ADD COLUMN IF NOT EXISTS insurance_url TEXT;
