-- ============================================================================
-- Spektra — skema inti (portabel: jalan di Postgres biasa & Supabase)
-- ============================================================================
-- Aturan portabel:
--  * Hanya gunakan fitur Postgres standar (tanpa schema `auth.`)
--  * Bagian spesifik Supabase (profiles, owner_id, RLS) ada di db/supabase/
--  * Kolom kecil (< 32767 bytes) memakai bigint/bi tipe ringan agar cepat tanpa
--    index; enum disimpan sebagai *smallint* + CHECK + komentar (bukan pg_enum)
--    supaya migrasi ke tumpukan Supabase tidak bermasalah.
--
-- Pemetaan nilai enum (harus sinkron dengan model Dart):
--   projects.category : 0=Kuliah  1=Klien  2=Pribadi
--   tasks.status      : 0=To Do   1=In Progress  2=Review  3=Done
-- ============================================================================

begin;

create extension if not exists pgcrypto;

create table if not exists public.projects (
    id         bigint generated always as identity primary key,
    title      text  not null check (char_length(title) between 1 and 200),
    category   smallint not null check (category between 0 and 2),
    deadline   timestamptz,
    created_at timestamptz not null default now()
);

comment on column public.projects.category is
    '0=Kuliah, 1=Klien, 2=Pribadi — cocok dengan ProjectCategory enum di Flutter';

create table if not exists public.tasks (
    id         bigint generated always as identity primary key,
    project_id bigint not null references public.projects (id) on delete cascade,
    name       text  not null check (char_length(name) between 1 and 500),
    status     smallint not null default 0 check (status between 0 and 3),
    position   integer not null default 0,
    deadline   timestamptz,
    created_at timestamptz not null default now()
);

comment on column public.tasks.status is
    '0=To Do, 1=In Progress, 2=Review, 3=Done — cocok dengan TaskStatus enum di Flutter';

create index if not exists tasks_project_status_idx
    on public.tasks (project_id, status, position);

commit;