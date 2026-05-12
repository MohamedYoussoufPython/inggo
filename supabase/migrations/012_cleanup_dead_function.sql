-- ============================================================
-- Migration 012: Cleanup dead DB objects
-- Drops the orphaned auto_pay_cash() function left by
-- migration 006 (replaced by auto_pay_cash_rides() in 007).
-- ============================================================

-- Drop the dead function from migration 006
DROP FUNCTION IF EXISTS auto_pay_cash();
