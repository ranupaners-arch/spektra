# Spektra

Aplikasi manajemen proyek & tugas untuk mahasiswa yang juga bekerja sebagai freelancer — menggabungkan kanban tracker, mode presentasi, dan kuis interaktif dalam satu aplikasi Flutter lintas platform.

## Fitur Utama

- **Tracking proyek**: buat/hapus proyek dengan kategori (Kuliah, Klien, Pribadi) dan progress bar otomatis dari checklist tugas.
- **Kanban board**: 4 kolom (To Do, In Progress, Review, Done) dengan drag & drop, naik/turun urutan, dan tombol tandai selesai.
- **Deadline & reminder**: atur tenggat per proyek/tugas, banner peringatan untuk tugas terlambat, jatuh tempo hari ini/besok, dan dalam 3 hari.
- **Mode Presentasi**: ubah data proyek jadi slide (judul + progress besar, lalu daftar checklist) untuk ditunjukkan ke klien/dosen.
- **Mode Kuiz**: hasilkan kuis pilihan ganda otomatis dari data proyek (progress, kategori, jumlah tugas selesai) lengkap dengan skor.
- **Autentikasi & sinkronisasi cloud (opsional)**: login/daftar email-password via Supabase; saat aktif data proyek & tugas disinkronkan real-time ke cloud (dengan Row Level Security). Tanpa konfigurasi Supabase, aplikasi tetap berjalan 100% lokal memakai database SQLite di perangkat.

## Tech Stack

- **Flutter** (Dart SDK ^3.13.4) — Android, iOS, Web, Linux, macOS, Windows
- **State management**: flutter_riverpod
- **Routing**: go_router
- **Database lokal**: drift + drift_flutter (SQLite)
- **Backend cloud (opsional)**: supabase_flutter (Auth, Postgres, Realtime, RLS)
- **UI**: Material 3 + google_fonts
- **Tooling backend**: skrip Node.js (`tool/*.mjs`) untuk apply migrasi & verifikasi E2E ke Supabase

## Cara Menjalankan Lokal

### 1. Install dependency

```bash
flutter pub get
```

### 2. (Opsional) Konfigurasi environment untuk mode cloud

Salin `.env.example` ke `.env.local`, lalu isi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dari project Supabase kamu. Nilai ini **tidak dibaca saat runtime** — di-inject lewat `--dart-define` saat `flutter run`/`flutter build`. Tanpa kedua nilai ini, aplikasi tetap berjalan penuh secara lokal (Drift/SQLite).

### 3. Jalankan aplikasi

```bash
# Mode lokal (tanpa backend cloud)
flutter run -d chrome

# Mode cloud (butuh SUPABASE_URL & SUPABASE_ANON_KEY)
flutter run -d chrome --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

Atau pakai target Makefile yang sudah dibungkus (`make dev`, `make dev-cloud`, dsb — baca `.env.local` otomatis).

### 4. Build

```bash
flutter build web                # build web lokal
make build-web-cloud             # build web mode cloud (baca .env.local)
```

Build untuk Android/iOS/desktop mengikuti perintah Flutter standar (`flutter build apk`, `flutter build ios`, dst), menyesuaikan dart-define jika memakai mode cloud.

## Struktur Folder

```
lib/
  app/                    # Router (go_router)
  core/
    config/               # Konfigurasi Supabase (baca dart-define)
    database/             # Drift (tabel & database lokal)
  features/
    auth/                 # Login/daftar + controller sesi Supabase
    tracking/             # Domain, repository (Drift & Supabase), UI dashboard & kanban
    presentation_mode/    # Mode slide presentasi
    quiz_mode/            # Mode kuis interaktif
db/
  migrations/             # Skema SQL Postgres (lokal/portabel)
  supabase/                # Migrasi tambahan khusus Supabase (RLS, realtime)
tool/                     # Skrip Node.js: apply migrasi & verifikasi cloud
```

## Deploy / Rilis

Belum ada pipeline CI/CD atau GitHub Actions di repo ini. Rilis web/desktop dilakukan manual lewat `flutter build`, dan skema database diterapkan ke Supabase lewat `make apply-cloud` (baca `handoffs/backend-db-postgres.md` untuk status terbaru).

## Kredit

Dibuat oleh **Ranupane Rimba Argana**, founder [Kukerjain](https://kukerjain.dev).

- Website: [kukerjain.dev](https://kukerjain.dev)
- Profil: [ranupane.kukerjain.dev](https://ranupane.kukerjain.dev)
