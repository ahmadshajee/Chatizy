-- ============================================================
--  CHATIZY — Complete Supabase Setup Script
--  Run this ONCE in your Supabase SQL Editor (Dashboard → SQL)
--  It is safe to re-run: every CREATE uses IF NOT EXISTS
--  and every policy uses DROP IF EXISTS before CREATE.
-- ============================================================


-- ╔════════════════════════════════════════════════════════════╗
-- ║  1. EXTENSIONS                                            ║
-- ╚════════════════════════════════════════════════════════════╝

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- ╔════════════════════════════════════════════════════════════╗
-- ║  2. CUSTOM ENUM TYPE                                      ║
-- ╚════════════════════════════════════════════════════════════╝

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_role') THEN
    CREATE TYPE public.user_role AS ENUM (
      'super_admin',
      'business_admin',
      'employee',
      'personal'
    );
  END IF;
END $$;


-- ╔════════════════════════════════════════════════════════════╗
-- ║  3. TABLES                                                ║
-- ╚════════════════════════════════════════════════════════════╝

-- ── 3a. profiles ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.profiles (
  id             UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role           public.user_role NOT NULL DEFAULT 'personal',
  company_domain TEXT,
  employee_id    TEXT,
  full_name      TEXT NOT NULL DEFAULT 'Unknown',
  nickname       TEXT,
  email          TEXT,
  avatar_url     TEXT,
  is_online      BOOLEAN NOT NULL DEFAULT false,
  last_seen      TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 3b. chat_rooms ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_rooms (
  id             UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_domain TEXT,
  is_group       BOOLEAN NOT NULL DEFAULT false,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── 3c. room_members ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.room_members (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id   UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(room_id, user_id)
);

-- ── 3d. messages ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.messages (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  room_id         UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id       UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  sender_name     TEXT NOT NULL DEFAULT 'Unknown',
  receiver_domain TEXT,
  content         TEXT NOT NULL DEFAULT '',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ╔════════════════════════════════════════════════════════════╗
-- ║  4. INDEXES (for performance)                             ║
-- ╚════════════════════════════════════════════════════════════╝

CREATE INDEX IF NOT EXISTS idx_profiles_company_domain   ON public.profiles(company_domain);
CREATE INDEX IF NOT EXISTS idx_profiles_role             ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_email            ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_room_members_user_id      ON public.room_members(user_id);
CREATE INDEX IF NOT EXISTS idx_room_members_room_id      ON public.room_members(room_id);
CREATE INDEX IF NOT EXISTS idx_messages_room_id          ON public.messages(room_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at       ON public.messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_domain  ON public.messages(receiver_domain);


-- ╔════════════════════════════════════════════════════════════╗
-- ║  5. ENABLE ROW LEVEL SECURITY                             ║
-- ╚════════════════════════════════════════════════════════════╝

ALTER TABLE public.profiles     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages     ENABLE ROW LEVEL SECURITY;


-- ╔════════════════════════════════════════════════════════════╗
-- ║  6. RLS POLICIES                                          ║
-- ╚════════════════════════════════════════════════════════════╝

-- ── 6a. PROFILES policies ───────────────────────────────────

-- Everyone can read all profiles (needed for search, contact lists, etc.)
DROP POLICY IF EXISTS "profiles_select_all" ON public.profiles;
CREATE POLICY "profiles_select_all"
  ON public.profiles FOR SELECT
  USING (true);

-- Users can insert their own profile (signup)
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Users can update their own profile
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);


-- ── 6b. CHAT_ROOMS policies ────────────────────────────────

-- Users can see rooms they are a member of
DROP POLICY IF EXISTS "chat_rooms_select_member" ON public.chat_rooms;
CREATE POLICY "chat_rooms_select_member"
  ON public.chat_rooms FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_members.room_id = chat_rooms.id
        AND room_members.user_id = auth.uid()
    )
  );

-- Any authenticated user can create a room
DROP POLICY IF EXISTS "chat_rooms_insert_auth" ON public.chat_rooms;
CREATE POLICY "chat_rooms_insert_auth"
  ON public.chat_rooms FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);


-- ── 6c. ROOM_MEMBERS policies ──────────────────────────────

-- Users can see members of rooms they belong to
DROP POLICY IF EXISTS "room_members_select" ON public.room_members;
CREATE POLICY "room_members_select"
  ON public.room_members FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.room_members rm2
      WHERE rm2.room_id = room_members.room_id
        AND rm2.user_id = auth.uid()
    )
  );

-- Any authenticated user can add members to a room
DROP POLICY IF EXISTS "room_members_insert_auth" ON public.room_members;
CREATE POLICY "room_members_insert_auth"
  ON public.room_members FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);


-- ── 6d. MESSAGES policies ──────────────────────────────────

-- Users can read messages from rooms they are a member of
DROP POLICY IF EXISTS "messages_select_member" ON public.messages;
CREATE POLICY "messages_select_member"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_members.room_id = messages.room_id
        AND room_members.user_id = auth.uid()
    )
  );

-- Users can insert messages into rooms they are a member of
DROP POLICY IF EXISTS "messages_insert_member" ON public.messages;
CREATE POLICY "messages_insert_member"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_members.room_id = messages.room_id
        AND room_members.user_id = auth.uid()
    )
  );


-- ╔════════════════════════════════════════════════════════════╗
-- ║  7. REALTIME PUBLICATION                                  ║
-- ╚════════════════════════════════════════════════════════════╝

-- Enable realtime for messages and profiles (online status)
-- Drop and re-add to avoid duplicates
DO $$
BEGIN
  -- Remove tables from publication if they exist
  BEGIN
    ALTER PUBLICATION supabase_realtime DROP TABLE public.messages;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime DROP TABLE public.profiles;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;

  -- Add them back
  ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
END $$;


-- ╔════════════════════════════════════════════════════════════╗
-- ║  8. AUTO-CREATE PROFILE ON SIGNUP (trigger)               ║
-- ╚════════════════════════════════════════════════════════════╝

-- This trigger automatically creates a profile row when a new
-- user signs up via Supabase Auth, using the metadata passed
-- during signup (full_name, role, company_domain, employee_id).

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, role, full_name, email, company_domain, employee_id, is_online, last_seen, created_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'role', 'personal')::public.user_role,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Unknown'),
    NEW.email,
    NEW.raw_user_meta_data->>'company_domain',
    NEW.raw_user_meta_data->>'employee_id',
    false,
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email     = EXCLUDED.email,
    role      = EXCLUDED.role;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop old trigger if it exists, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


-- ╔════════════════════════════════════════════════════════════╗
-- ║  9. DONE!                                                 ║
-- ╚════════════════════════════════════════════════════════════╝

-- You can now:
--   1. Go to your Supabase Dashboard → Authentication → Settings
--      and make sure "Enable email confirmations" is DISABLED
--      (so test users can sign up without verifying email).
--   2. Run the app and register the test users listed in
--      test_credentials.txt.
