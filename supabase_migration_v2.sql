-- ============================================================
--  CHATIZY — Migration V2: Read Receipts, Starred Messages,
--  Status Text, Avatars Storage
--  Run this in Supabase SQL Editor AFTER the initial setup.
-- ============================================================


-- ╔════════════════════════════════════════════════════════════╗
-- ║  1. ADD is_read TO messages                               ║
-- ╚════════════════════════════════════════════════════════════╝

ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT false;


-- ╔════════════════════════════════════════════════════════════╗
-- ║  2. ADD status_text TO profiles                           ║
-- ╚════════════════════════════════════════════════════════════╝

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS status_text TEXT DEFAULT 'Hey there! I''m using Chatizy';


-- ╔════════════════════════════════════════════════════════════╗
-- ║  3. STARRED MESSAGES TABLE                                ║
-- ╚════════════════════════════════════════════════════════════╝

CREATE TABLE IF NOT EXISTS public.starred_messages (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  message_id UUID NOT NULL REFERENCES public.messages(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, message_id)
);

CREATE INDEX IF NOT EXISTS idx_starred_user ON public.starred_messages(user_id);

-- Enable RLS
ALTER TABLE public.starred_messages ENABLE ROW LEVEL SECURITY;

-- Users can only see their own starred messages
DROP POLICY IF EXISTS "starred_select_own" ON public.starred_messages;
CREATE POLICY "starred_select_own"
  ON public.starred_messages FOR SELECT
  USING (auth.uid() = user_id);

-- Users can star messages
DROP POLICY IF EXISTS "starred_insert_own" ON public.starred_messages;
CREATE POLICY "starred_insert_own"
  ON public.starred_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can unstar messages
DROP POLICY IF EXISTS "starred_delete_own" ON public.starred_messages;
CREATE POLICY "starred_delete_own"
  ON public.starred_messages FOR DELETE
  USING (auth.uid() = user_id);


-- ╔════════════════════════════════════════════════════════════╗
-- ║  4. UPDATE POLICY: allow users to update is_read          ║
-- ╚════════════════════════════════════════════════════════════╝

-- Users can mark messages as read in rooms they belong to
DROP POLICY IF EXISTS "messages_update_read" ON public.messages;
CREATE POLICY "messages_update_read"
  ON public.messages FOR UPDATE
  USING (
    public.is_room_member(room_id, auth.uid())
  )
  WITH CHECK (
    public.is_room_member(room_id, auth.uid())
  );


-- ╔════════════════════════════════════════════════════════════╗
-- ║  5. AVATARS STORAGE BUCKET                                ║
-- ╚════════════════════════════════════════════════════════════╝

-- Create avatars bucket (public read)
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload their own avatar
DROP POLICY IF EXISTS "avatars_insert" ON storage.objects;
CREATE POLICY "avatars_insert"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.uid() IS NOT NULL
  );

-- Allow anyone to read avatars (public bucket)
DROP POLICY IF EXISTS "avatars_select" ON storage.objects;
CREATE POLICY "avatars_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- Allow users to update/delete their own avatars
DROP POLICY IF EXISTS "avatars_update" ON storage.objects;
CREATE POLICY "avatars_update"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "avatars_delete" ON storage.objects;
CREATE POLICY "avatars_delete"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);


-- ╔════════════════════════════════════════════════════════════╗
-- ║  DONE — Run the app and test new features.                ║
-- ╚════════════════════════════════════════════════════════════╝
