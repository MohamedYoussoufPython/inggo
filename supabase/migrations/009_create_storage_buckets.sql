-- ============================================================
-- Migration 009: Create Storage Buckets
-- Creates the "avatars" and "driver-documents" buckets with
-- appropriate policies so the app can upload/read files.
-- ============================================================

-- 1. Create "avatars" bucket (profile photos)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'avatars'
  ) THEN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES (
      'avatars',
      'avatars',
      true,    -- public so images are directly displayable via URL
      5242880, -- 5 MB max
      ARRAY['image/jpeg', 'image/png', 'image/webp']
    );
  END IF;
END $$;

-- Avatars: anyone can view
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies WHERE name = 'avatars_public_select'
  ) THEN
    CREATE POLICY "avatars_public_select"
      ON storage.objects FOR SELECT
      USING (bucket_id = 'avatars');
  END IF;
END $$;

-- Avatars: authenticated users can upload their own
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies WHERE name = 'avatars_auth_insert'
  ) THEN
    CREATE POLICY "avatars_auth_insert"
      ON storage.objects FOR INSERT
      WITH CHECK (
        bucket_id = 'avatars'
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = 'avatars'
        AND (storage.foldername(name))[2] = auth.uid()::text
      );
  END IF;
END $$;

-- Avatars: users can update their own
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies WHERE name = 'avatars_auth_update'
  ) THEN
    CREATE POLICY "avatars_auth_update"
      ON storage.objects FOR UPDATE
      USING (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = 'avatars'
        AND (storage.foldername(name))[2] = auth.uid()::text
      );
  END IF;
END $$;


-- 2. Create "driver-documents" bucket (ID card, license, vehicle photo)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'driver-documents'
  ) THEN
    INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
    VALUES (
      'driver-documents',
      'driver-documents',
      false,   -- NOT public — documents contain sensitive info
      10485760, -- 10 MB max
      ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
    );
  END IF;
END $$;

-- Driver-documents: the owning driver can view their own files
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies WHERE name = 'driver_docs_owner_select'
  ) THEN
    CREATE POLICY "driver_docs_owner_select"
      ON storage.objects FOR SELECT
      USING (
        bucket_id = 'driver-documents'
        AND (storage.foldername(name))[1] = auth.uid()::text
      );
  END IF;
END $$;

-- Driver-documents: authenticated drivers can upload their own docs
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies WHERE name = 'driver_docs_owner_insert'
  ) THEN
    CREATE POLICY "driver_docs_owner_insert"
      ON storage.objects FOR INSERT
      WITH CHECK (
        bucket_id = 'driver-documents'
        AND auth.role() = 'authenticated'
        AND (storage.foldername(name))[1] = auth.uid()::text
      );
  END IF;
END $$;

-- Driver-documents: drivers can update their own docs
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM storage.policies WHERE name = 'driver_docs_owner_update'
  ) THEN
    CREATE POLICY "driver_docs_owner_update"
      ON storage.objects FOR UPDATE
      USING (
        bucket_id = 'driver-documents'
        AND (storage.foldername(name))[1] = auth.uid()::text
      );
  END IF;
END $$;

-- Driver-documents: admin (service_role) can read all — handled automatically
-- by Supabase since service_role bypasses RLS.
