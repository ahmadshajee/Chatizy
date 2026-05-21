-- ============================================================
--  CHATIZY — FIX: Infinite Recursion in RLS Policies
--  Run this in Supabase SQL Editor to fix the room_members
--  and messages policies that cause infinite recursion.
-- ============================================================


-- ╔════════════════════════════════════════════════════════════╗
-- ║  1. HELPER FUNCTION (bypasses RLS to check membership)    ║
-- ╚════════════════════════════════════════════════════════════╝

-- This function runs with elevated privileges (SECURITY DEFINER)
-- so it can query room_members without triggering RLS policies,
-- preventing the infinite recursion loop.

CREATE OR REPLACE FUNCTION public.is_room_member(p_room_id UUID, p_user_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.room_members
    WHERE room_id = p_room_id
      AND user_id = p_user_id
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;


-- ╔════════════════════════════════════════════════════════════╗
-- ║  2. FIX room_members POLICIES                             ║
-- ╚════════════════════════════════════════════════════════════╝

-- Drop the broken recursive policy
DROP POLICY IF EXISTS "room_members_select" ON public.room_members;

-- New policy: users can see members of any room they belong to
-- Uses the SECURITY DEFINER function to avoid recursion
CREATE POLICY "room_members_select"
  ON public.room_members FOR SELECT
  USING (
    public.is_room_member(room_id, auth.uid())
  );


-- ╔════════════════════════════════════════════════════════════╗
-- ║  3. FIX messages POLICIES (same pattern)                  ║
-- ╚════════════════════════════════════════════════════════════╝

-- Drop and recreate messages SELECT policy using helper function
DROP POLICY IF EXISTS "messages_select_member" ON public.messages;
CREATE POLICY "messages_select_member"
  ON public.messages FOR SELECT
  USING (
    public.is_room_member(room_id, auth.uid())
  );

-- Drop and recreate messages INSERT policy using helper function
DROP POLICY IF EXISTS "messages_insert_member" ON public.messages;
CREATE POLICY "messages_insert_member"
  ON public.messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND public.is_room_member(room_id, auth.uid())
  );


-- ╔════════════════════════════════════════════════════════════╗
-- ║  4. FIX chat_rooms SELECT POLICY (same pattern)           ║
-- ╚════════════════════════════════════════════════════════════╝

DROP POLICY IF EXISTS "chat_rooms_select_member" ON public.chat_rooms;
CREATE POLICY "chat_rooms_select_member"
  ON public.chat_rooms FOR SELECT
  USING (
    public.is_room_member(id, auth.uid())
  );


-- ╔════════════════════════════════════════════════════════════╗
-- ║  DONE — All recursion issues are now fixed.               ║
-- ╚════════════════════════════════════════════════════════════╝
