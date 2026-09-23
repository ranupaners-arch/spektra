# Backend: Postgres lokal (DBngin) → Supabase
Status: BERJALAN (skema + realtime + auth + repository DI-IMPLEMENTASI; menunggu verifikasi E2E user) · Service: backend · Diperbarui: 2026-09-23 14:30
Referensi: docs/dev-db.md · db/migrations/0001_init.sql · db/supabase/0002_auth_rls.sql · db/supabase/0003_supabase_realtime.sql · tool/apply_supabase.mjs · lib/features/auth/ · lib/features/tracking/data/supabase_project_repository.dart · .env.local (SEKRET — jangan commit)

## Sedang dikerjakan
Verifikasi E2E oleh user (register→confirm email→login→try kanban biar data nyangkut di cloud) — ini satu-satunya bloker tersisa sebelum "backend mateng".

## Status terakhir (terbukti sesi ini)
- Skema cloud TERPASANG di project `hidmfqgdjcwhhdmwxgzk` (region ap-northeast-1) via `tool/apply_supabase.mjs`:
  0001 (projects/tasks) + 0002 (profiles/owner_id/RLS, idempotent) + 0003 (realtime publication + replica identity FULL).
  Verifikasi: tabel public = profiles/projects/tasks; RLS aktif; policy 3/4/4; realtime publication ada; replident=f (FULL).
- REST anon (tanpa login) → 200 `[]` untuk ketiga tabel → RLS benar memblokir. Auth endpoint live (login salah → 400 invalid_credentials).
- Kode Flutter DI-IMPLEMENTASI & lulus `flutter analyze` (No issues) + `flutter build web` (dengan dart-define Supabase):
  - `AuthController` (notifier riverpod 3) + `AuthScreen` (masuk/daftar, email-confirmation-aware) + auth gate di main.dart.
  - `SupabaseProjectRepository` (implements ProjectRepository): watch via Realtime Channel + refetch 60s (embedded select `tasks(*)`, karena `.stream()` bawaan tak dukung embedded); mutasi pakai session Bearer + RLS.
  - Repo swap otomatis: Supabase+login → remote; selain itu → Drift lokal. `projectRepositoryProvider` berubah.
  - Logout button di dashboard (hanya muncul saat auth aktif).
- Koneksi DB: host direct `db.<ref>` itu IPv6-only & tak terjangkau mesin → pakai **Session pooler** `aws-0-ap-northeast-1.pooler.supabase.com:5432`, user `postgres.hidmfqgdjcwhhdmwxgzk`.
- `flutter test` MASIH gagal di mesin ini (toolchain Apple objective_c) — bukan kode.
- Commit lokal: `ccd20af`, lalu batch sesi ini BELUM di-commit/push.

## Keputusan penting
- Email confirmation tetap ON di project → user daftar via app, klik link di email.
- Anon key disimpan di `.env.local` (gitignored) untuk sesi dev ini; untuk build: `--dart-define`.
- Bila realtime channel error di web, fallback polling 60s tetap menjaga UI up-to-date.

## Langkah berikutnya
1. (User) Jalankan `flutter run -d chrome --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
   → daftar dengan email sendiri → konfirmasi email → masuk → buat proyek/task → cek muncul di dashboard Supabase (Table Editor) & di instance lain/logout saat disimulasikan.
2. Setelah terverifikasi → tandai "backend mateng" di PLAN.md → balik fokus frontend (P2; DESIGN.md wajib dulu).
3. Commit batch sesi ini + push (bila user setuju; jangan commit `.env.local`).

## Jangan lakukan
- Jangan commit `.env.local` / SUPABASE_DB_PASSWORD.
- Jangan matikan email confirmation demi kemudahan tes.
- Jangan host `db.<ref>.supabase.co` di tool migrasi — selalu pooler/session-pooler (IPv4).