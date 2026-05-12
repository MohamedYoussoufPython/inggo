-- ============================================================
-- Migration 011: Fix missing RLS policies
-- Adds policies for password_resets and reviews tables
-- that had RLS enabled but no access policies.
-- ============================================================

-- 1. password_resets: users can insert their own reset tokens
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Users can insert own reset'
  ) THEN
    CREATE POLICY "Users can insert own reset"
      ON password_resets FOR INSERT
      WITH CHECK (user_id = auth.uid());
  END IF;
END $$;

-- password_resets: users can read their own reset tokens
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Users can read own resets'
  ) THEN
    CREATE POLICY "Users can read own resets"
      ON password_resets FOR SELECT
      USING (user_id = auth.uid());
  END IF;
END $$;

-- password_resets: users can update their own reset tokens (e.g., mark as used)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own resets'
  ) THEN
    CREATE POLICY "Users can update own resets"
      ON password_resets FOR UPDATE
      USING (user_id = auth.uid());
  END IF;
END $$;

-- 2. reviews: users can update their own reviews
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own reviews'
  ) THEN
    CREATE POLICY "Users can update own reviews"
      ON reviews FOR UPDATE
      USING (from_user_id = auth.uid());
  END IF;
END $$;

-- reviews: users can delete their own reviews
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Users can delete own reviews'
  ) THEN
    CREATE POLICY "Users can delete own reviews"
      ON reviews FOR DELETE
      USING (from_user_id = auth.uid());
  END IF;
END $$;
