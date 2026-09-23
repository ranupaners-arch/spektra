# Dev Database Spektra (Postgres lokal → Supabase nanti)

Jejak backend: **DBngin** menjalankan Postgres lokal, **TablePlus** sebagai
admin/query, skema ditulis sebagai **SQL migrasi portabel** yang nanti dipakai
di Supabase cloud tanpa ubah isi.

## Topologi

```
Android (Drift/SQLite, sekarang)
        │  repository pattern (P0)
        ▼
[ProjectRepository]  ← UI hanya bertemu interface ini
        │
        ├─ DriftProjectRepository      (lokal, dipakai sekarang)
        └─ SupabaseProjectRepository   (nanti, swap tanpa ubah UI)
```

- **Sekarang**: data app ada di SQLite perangkat; Postgres lokal di bawah ini
  adalah *backend schema* yang dirancang & dites lebih dulu.
- **Nanti (P3)**: skema yang sama (`db/migrations/0001_init.sql`) di-apply ke
  Supabase + `db/supabase/0002_auth_rls.sql` (profiles, owner_id, RLS). App
  tinggal ganti repository.

## Koneksi lokal (DBngin)

- Engine: PostgreSQL
- Database: `spektra`
- Host/port default DBngin: `127.0.0.1` di port instance (lihat panel DBngin;
  biasanya tertera pada kartu instance Postgres).
- User: `postgres` (trust/без password — sesuaikan bila kamu set password).
- Buka di TablePlus: New Connection → PostgreSQL → isi host/port/db/user.

Untuk *troubleshoot* cepat, pastikan instance Postgres berstatus running di
window DBngin (tombol ▶).

## Alur kerja

1. Jalankan migrasi: TablePlus → buka file `db/migrations/0001_init.sql` →
   Run (⚡). Aman diulang (`create if not exists`, dibungkus transaction).
2. Inspect: dua tabel `projects` & `tasks` + FK cascade + constraint.
3. Saat butuh reset *lokal* saja (data coba-coba): hapus row yang kamu buat,
   jangan drop tabel — skema migrasi adalah sumber kebenaran.

## Verifikasi constraint (sanity check)

```sql
-- valid: harus jalan
insert into public.projects (title, category) values ('Belajar Dart', 0);
insert into public.tasks (project_id, name, status, position)
select id, 'Buat UI', 1, 0 from public.projects where title = 'Belajar Dart';

-- invalid: harus ditolak (category di luar 0..2)
insert into public.projects (title, category) values ('x', 7);

-- cascade: hapus proyek → task ikut hilang
delete from public.projects where title = 'Belajar Dart';
select count(*) from public.tasks; -- kembali 0
```

## Migrasi ke Supabase (P3)

1. Buat project Supabase cloud.
2. Apply `db/migrations/0001_init.sql` (core, tanpa RLS) di SQL editor.
3. Apply `db/supabase/0002_auth_rls.sql` (profiles, owner_id, policies).
4. Catat `Project URL` + `anon key` → inject ke app saat run/build:

   ```
   flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
   ```

   Contoh & catatan: `.env.example`. Tanpa kedua define, app tetap 100% lokal
   (Drift) — `lib/core/config/supabase_config.dart` mengunci bootstrap.
5. Nota: skema `auth.users` & `gen_random_uuid()` tersedia otomatis di Supabase.

## Tidak dilakukan

- Tidak ada seed data demo.
- RLS/auth TIDAK disimulasikan di DBngin (butuh `auth.users` Supabase).