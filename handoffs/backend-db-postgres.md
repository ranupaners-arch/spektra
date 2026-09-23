# Backend: Postgres lokal (DBngin) → Supabase
Status: BERJALAN (basis schema lokal ✅; integrasi Supabase siap menunggu project cloud) · Service: backend · Diperbarui: 2026-09-23 12:00
Referensi: docs/dev-db.md · db/migrations/0001_init.sql · db/supabase/0002_auth_rls.sql · .env.example · lib/core/config/supabase_config.dart · keputusan user "fokus backend dulu, frontend menyusul"

## Sedang dikerjakan
Menunggu SATU aksi user: buat project Supabase cloud + kirim URL & anon key. Setelah itu: apply 0001+0002, auth, repository swap, verifikasi.

## Status terakhir (terbukti di mesin ini)
- Instance DBngin: `spektra` (PostgreSQL 18.4_arm, port 5432, user postgres tanpa password, host 127.0.0.1) RUNNING. TablePlus terkoneksi.
- `tool/apply_migrations.mjs` → DB `spektra` + `0001_init.sql` applied. `tool/db_check.mjs` → 4/4 lolos.
- Supabase integration prep: `supabase_flutter ^2.17.2` dipasang; `lib/core/config/supabase_config.dart`
  membaca `--dart-define SUPABASE_URL/SUPABASE_ANON_KEY`; `main()` hanya init Supabase bila terkonfigurasi.
  `flutter analyze` No issues; `flutter build web` sukses. App tetap 100% lokal tanpa define.
- `flutter test` MASIH gagal di mesin ini (toolchain Apple objective_c) — bukan kode.

## Keputusan penting
- Skema portabel (enum=smallint+CHECK+komentar; RLS/auth dipisah di db/supabase/, tidak jalan di lokal).
- Anon key dipakai via `publishableKey:` (API baru supabase_flutter 2.17.2; `anonKey` deprecated).
- Tanpa URL+key → app sliding ke local-first; tidak ada branch Supabase yang "setengah nyala".

## Langkah berikutnya (BUTUH AKSI USER dulu)
1. User: buat project di https://supabase.com/dashboard → pilih region & password DB →
   kirim `Project URL` + `anon key` (Settings → API).
2. Di SQL editor project: apply `db/migrations/0001_init.sql` lalu `db/supabase/0002_auth_rls.sql`.
3. Jalankan app dengan `--dart-define` tersebut → verifikasi koneksi.
4. Implementasi: `auth` (register/login email+password), `SupabaseProjectRepository` swap
   (interface ProjectRepository, UI tak tersentuh).
5. Verifikasi end-to-end → tandai "backend mateng" → balik fokus frontend (P2; DESIGN.md wajib dulu).