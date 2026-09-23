# Backend: Postgres lokal (DBngin) → Supabase
Status: BERJALAN (basis schema lokal selesai & terverifikasi; Supabase cloud menyusul) · Service: backend · Diperbarui: 2026-09-23 11:40
Referensi: docs/dev-db.md · db/migrations/0001_init.sql · db/supabase/0002_auth_rls.sql · keputusan user "fokus backend dulu, frontend menyusul"

## Sedang dikerjakan
Bagian pertama fase backend (basis schema lokal) SELESAI & terverifikasi di Postgres DBngin.

## Status terakhir (terbukti di mesin ini)
- Instance DBngin: `spektra` (PostgreSQL 18.4_arm, port 5432, user postgres tanpa password, host 127.0.0.1).
- `tool/apply_migrations.mjs` → database `spektra` dibuat + `0001_init.sql` applied.
- `tool/db_check.mjs` → 4/4 lolos: tabel projects+tasks ada, insert valid, CHECK category=7 ditolak, cascade bersih.
- Flutter lib TIDAK disentuh (murni backend schema/tooling). `flutter analyze` tetap clean.
- Data uji sanity sudah di-rollback (DB bersih, tanpa seed).

## Keputusan penting
- Skema ditulis portabel (Postgres biasa & Supabase): enum = smallint + CHECK + komentar (bukan pg_enum);
  bagian Supabase-only (`profiles`, `owner_id`, RLS) dipisah di `db/supabase/0002_auth_rls.sql` yang TIDAK jalan di lokal.
- Migrasi di-apply via node `pg` (`tool/`), psql tidak terpasang di mesin. TablePlus dipakai untuk inspect manual.
- Kamu pilih rute **Supabase** (lanjut PLAN.md P3). DBngin/TablePlus = dev ground schema, bukan jalur produksi.

## Langkah berikutnya (fase backend, oleh kamu atau sesi berikutnya)
1. Buat project Supabase cloud → apply `0001_init.sql` + `0002_auth_rls.sql` di SQL editor.
2. Catat Project URL + anon key → simpan di env (contoh `.env.example`).
3. (`supabase_flutter` di pubspec + `SupabaseProjectRepository` swap via repository pattern — UI tak tersentuh.)
4. Setelah backend "mateng" → balik fokus frontend: P2 (Present/Quiz mode dari data nyata, mode switching; DESIGN.md wajib).

## Jangan lakukan
- Jangan jalankan `db/supabase/0002_auth_rls.sql` di Postgres lokal DBngin (refer `auth.users` Supabase) — putus tanpanya.
- Jangan menaruh password/credential asli di file repo; pakai env.
- Jangan drop-drop tabel `projects`/`tasks` di DBngin sembarangan; migrasi = sumber kebenaran.