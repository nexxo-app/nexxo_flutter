-- SQL Migration: Add has_imported_balance column to profiles table
-- Run this in Supabase SQL Editor

-- 1. Add the column to profiles table if it doesn't exist
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS has_imported_balance BOOLEAN DEFAULT FALSE;

-- 2. Add a comment for documentation
COMMENT ON COLUMN public.profiles.has_imported_balance IS 'Indicates if the user has imported their initial balance during onboarding';

-- 3. Create an index for faster queries (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_profiles_has_imported_balance 
ON public.profiles(has_imported_balance) 
WHERE has_imported_balance = FALSE;

-- 4. Update RLS policy to allow users to update their own has_imported_balance
-- Note: This assumes you already have a policy for users to update their own profile
-- If not, you'll need to create one:

-- Check if policy exists, if not create it
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE schemaname = 'public' 
        AND tablename = 'profiles' 
        AND policyname = 'Users can update own profile'
    ) THEN
        CREATE POLICY "Users can update own profile" ON public.profiles
            FOR UPDATE USING (auth.uid() = id)
            WITH CHECK (auth.uid() = id);
    END IF;
END $$;
