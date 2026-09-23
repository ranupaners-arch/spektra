# Backend: Postgres lokal (DBngin) → Supabase (serah-terima ke AI lain)
Status: BERJALAN (tinggal verifikasi E2E auth; email rate-limit menahan) · Service: backend · Diperbarui: 2026-09-23 15:00
Referensi komplet: PLAN.md · docs/dev-db.md · db/{migrations,supabase}/ · `tool/apply_supabase.mjs` · `tool/verify_cloud.mjs` · `Makefile` · `lib/features/auth/` · `lib/features/tracking/data/supabase_project_repository.dart` · `.env.local` (JANGAN commit)

## Status terakhir (TERBUKTI sesi ini — jangan ulangi dari nol)
- Cloud Supabase project `hidmfqgdjcwhhdmwxgzk` (region ap-northeast-1):
  - Skema `0001` (projects/tasks) + `0002` (profiles/owner_id/RLS; idempotent) + `0003` (realtime publication + replica identity FULL) TERPASANG.
  - Verifikasi via DB: tabel public = `profiles, projects, tasks`; RLS on; policy per tabel 3/4/4; `supabase_realtime` punya 3 tabel; `relreplident = f` (FULL).
  - REST anon (tanpa login) → HTTP 200 `[]` ketiga tabel → RLS benar memblokir.
  - Endpoint auth live: login password-salah → 400 `invalid_credentials`; signup → HTTP 200 membuat user + kirim email konfirmasi.
- Kode Flutter selesai & lulus `flutter analyze` (No issues) + `flutter build web` (dengan dart-define):
  - `AuthController` (Notifier riverpod 3) + `AuthScreen` (masuk/daftar, aware email confirmation) + auth gate di `main.dart`; tombol logout di dashboard (muncul saat auth aktif).
  - `SupabaseProjectRepository` implements `ProjectRepository`: watch via Realtime Channel `spektra-projects` (postgres_changes projects+tasks) + refetch tiap 60s (refresh() meng-`select('*, tasks(*)')` embedded); mutasi atas nama session Bearer + RLS.
  - Repo swap otomatis di `tracking_providers.dart`: Supabase terkoneksi+login → remote; selain itu → Drift/SQLite lokal.
- Koneksi DB cloud: host direct `db.<ref>.supabase.co` = IPv6-only & tak terjangkau → pakai **Session pooler** `aws-0-ap-northeast-1.pooler.supabase.com:5432`, user `postgres.hidmfqgdjcwhhdmwxgzk`. Kredensial DB (password) milik user.
- Sudah di-push ke origin/main (`33c1ff1`; batch terakhir).

## BELUM diverifikasi (PENTING) — E2E auth otomatis
- `tool/verify_cloud.mjs` menjalankan auth→RLS→CRUD→cascade dengan user tes (signup API → `email_confirmed_at=now()` via DB sebagai pengganti klik link → login → insert/select embedded/update/RLS-isolasi/delete-cascade → cleanup wajib). **Sesi ini dicegat status 429 `over_email_send_rate_limit` Supabase** (limit email project) → tool keluar exit=2 dengan pesan jelas.
- Real E2E user juga belum: daftar via `make dev-cloud` dengan email asli → klik link → login → buat proyek/task → cek Table Editor dashboard.

## Keputusan penting
- Email confirmation TETAP ON (jangan dimatikan demi tes).
- Anon key & URL tersimpan `.env.local` (gitignored) — aman; untuk build dipakai `--dart-define`.
- `flutter test` diblokir toolchain Apple di mesin ini (objective_c libSystem.tbd) — bukan masalah kode; verifikasi = `flutter analyze` + `flutter build web` + smoke headless.

## Langkah berikutnya (urutkan — pilih sesuai konteks user)
1. **Backend mateng**: tunggu cooldown email lalu `make validate-db-creds` → `SUPABASE_DB_PASSWORD=... make verify-cloud` sampai semua PASS; atau user jalankan app E2E sekali. Lalu tandai P3(parsial) ✅ di PLAN.md + tutup handoff ini.
2. **Sisa P3** (untuk kolaborasi nanti): anonymous untuk peserta quiz — tunda; tidak urgent.
3. **P2 frontend** (setelah backend mateng): Present/Quiz mode dari data nyata + mode switching. **DESIGN.md WAJIB dibuat dulu** (identitas, palet, tipografi, mood) sebelum gambar UI.

## Jangan lakukan (jebakan yang sudah ditemukan — JANGAN ulangi)
- Jangan commit `.env.local`, jangan tulis SUPABASE_DB_PASSWORD ke file apa pun.
- Jangan insert user langsung ke `auth.users` sendirian — gotrue login-nya 500 (butuh alur signup asli). Kalau E2E otomatis: **signup API → flip `email_confirmed_at`**, bukan injeksi SQL.
- Kolom generated di Supabase TIDAK bisa di-insert: `auth.users.confirmed_at` dan `auth.identities.email` — sisakan default.
- Domain email `.test` ditolak gotrue (`email_address_invalid`); `mailinator.com` di-cap rate-limit; pakai domain normal (`example.com` OK untuk tes karena konfirmasi di-flip manual).
- Host direct `db.<ref>.supabase.co` IPv6-only: ENOTFOUND/EHOSTUNREACH di mesin ini — selalu Session pooler IPv4.
- `.stream(primaryKey:)` Supabase tidak mendukung embedded resource — `watchProjects` harus via Realtime Channel + select penuh (sudah begitu di kode).
- `create policy` tidak idempotent → 0002 sudah pakai `drop policy if exists`.