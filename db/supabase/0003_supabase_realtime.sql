-- ============================================================================
-- Spektra — Realtime & stream (HANYA Supabase)
-- ============================================================================
-- Diperlukan agar `watchProjects()` di app bisa live-update:
--   * tambahkan tabel ke publication supabase_realtime (postgres_changes)
--   * replica identity FULL supaya event UPDATE/DELETE punya payload lengkap
--     (default hanya primary key → baris yang dihapus tak ikut ter-stream).
-- Aman dijalan ulang.
-- ============================================================================

do $$
begin
  -- publication default Supabase; tambah hanya bila belum ada
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table public.projects, public.tasks, public.profiles;
  end if;
end $$;

alter table public.projects replica identity full;
alter table public.tasks    replica identity full;
alter table public.profiles replica identity full;