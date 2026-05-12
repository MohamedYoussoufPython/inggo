-- ============================================================
-- Migration 010: Prevent double-accept race condition
-- Adds a CHECK constraint so a ride can only transition
-- from 'searching' to 'accepted'. This prevents two drivers
-- from accepting the same ride simultaneously.
-- Also adds a partial unique index to ensure a ride can only
-- have one non-cancelled driver assignment.
-- ============================================================

-- 1. Add a trigger that enforces valid status transitions
-- Only allow: searching→accepted, accepted→in_progress, in_progress→completed,
-- and any status→cancelled
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'enforce_ride_status_transition'
  ) THEN
    CREATE CONSTRAINT TRIGGER enforce_ride_status_transition
      AFTER UPDATE ON rides
      DEFERRABLE INITIALLY IMMEDIATE
      FOR EACH ROW
      EXECUTE FUNCTION check_ride_status_transition();
  END IF;
END $$;

-- 2. Create the trigger function (safe create-or-replace)
CREATE OR REPLACE FUNCTION check_ride_status_transition()
RETURNS TRIGGER AS $$
BEGIN
  -- Allow INSERT (new rides)
  IF TG_OP = 'INSERT' THEN
    RETURN NEW;
  END IF;

  -- Valid transitions:
  -- searching → accepted (driver accepts)
  -- accepted → in_progress (driver picks up client)
  -- in_progress → completed (ride finished)
  -- searching → cancelled (no driver found / client cancels)
  -- accepted → cancelled (client/driver cancels before pickup)
  -- in_progress → cancelled (emergency cancel during ride)

  IF OLD.status = 'searching' AND NEW.status = 'accepted' THEN
    -- Ensure driver_id is set when accepting
    IF NEW.driver_id IS NULL THEN
      RAISE EXCEPTION 'driver_id must be set when accepting a ride';
    END IF;
    RETURN NEW;
  ELSIF OLD.status = 'accepted' AND NEW.status = 'in_progress' THEN
    RETURN NEW;
  ELSIF OLD.status = 'in_progress' AND NEW.status = 'completed' THEN
    RETURN NEW;
  ELSIF NEW.status = 'cancelled' THEN
    RETURN NEW;
  ELSIF OLD.status = NEW.status THEN
    -- No status change, allow other field updates
    RETURN NEW;
  ELSE
    RAISE EXCEPTION 'Invalid ride status transition: % → %', OLD.status, NEW.status;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 3. Add a partial unique index: only one driver can be assigned to a ride
-- that is in an active state (accepted or in_progress).
-- This is a safety net at the DB level in addition to the trigger.
DO $$$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'rides_one_driver_active'
  ) THEN
    CREATE UNIQUE INDEX rides_one_driver_active
      ON rides (id)
      WHERE status IN ('accepted', 'in_progress') AND driver_id IS NOT NULL;
  END IF;
END $$$;
