-- ============================================================================
-- Spektra — Auth & RLS (HANYA untuk Supabase — mengacu schema `auth.users`)
-- ============================================================================
-- Dijalankan SETELAH 0001_init.sql di project Supabase cloud.
-- RLS: setiap baris proyek/task hanya terlihat & termodifikasi oleh pemiliknya
-- (auth.uid()). Tabel public.profiles menyimpan profil per user.
-- ============================================================================

-- profil per user autentikasi
create table if not exists public.profiles (
    id         uuid primary key references auth.users (id) on delete cascade,
    full_name  text,
    avatar_url text,
    created_at timestamptz not null default now()
);

-- kepemilikan proyek (uuid dari auth.users)
alter table public.projects
    add column if not exists owner_id uuid references auth.users (id);

-- index untuk lookup proyek milik user
create index if not exists projects_owner_idx
    on public.projects (owner_id);

-- ============================================================================
-- RLS
-- ============================================================================
alter table public.projects enable row level security;
alter table public.tasks    enable row level security;
alter table public.profiles enable row level security;

-- profiles: user hanya mengelola profilnya sendiri
create policy "profiles: select own"
    on public.profiles for select using (id = auth.uid());
create policy "profiles: insert own"
    on public.profiles for insert with check (id = auth.uid());
create policy "profiles: update own"
    on public.profiles for update using (id = auth.uid());

-- projects: sepenuhnya milik owner
create policy "projects: select own" on public.projects
    for select using (owner_id = auth.uid());
create policy "projects: insert own" on public.projects
    for insert with check (owner_id = auth.uid());
create policy "projects: update own" on public.projects
    for update using (owner_id = auth.uid());
create policy "projects: delete own" on public.projects
    for delete using (owner_id = auth.uid());

-- tasks: menurun dari proyek pemiliknya
create policy "tasks: select via project owner" on public.tasks
    for select using (
        project_id in (select id from public.projects where owner_id = auth.uid())
    );
create policy "tasks: insert via project owner" on public.tasks
    for insert with check (
        project_id in (select id from public.projects where owner_id = auth.uid())
    );
create policy "tasks: update via project owner" on public.tasks
    for update using (
        project_id in (select id from public.projects where owner_id = auth.uid())
    );
create policy "tasks: delete via project owner" on public.tasks
    for delete using (
        project_id in (select id from public.projects where owner_id = auth.uid())
    );