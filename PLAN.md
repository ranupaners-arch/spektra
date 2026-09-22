# SPEKTRA: Rencana Implementasi

**Tanggal disusun:** 2026-09-22
**Dasar:** PRD.md v1.1
**Versi plan:** 1.0

---

## 1. Keputusan Arsitektur

| Aspek | Keputusan | Alasan |
|---|---|---|
| Platform | Flutter untuk semua (Android, iOS, Web, Desktop) | Satu codebase untuk "app" + "web app". Web platform sudah aktif di repo. UI yang ada langsung dipakai. |
| State management | Riverpod | Modern, ringan, cocok untuk realtime sync saat kolaborasi tiba. |
| Persistence (awal) | Local-first pakai Drift (SQLite) | Tanpa perlu akun layanan apa pun di awal. Tabel relasionalnya dicocokkan ke Postgres Supabase nanti. |
| Persistence (akhir) | Supabase, lewat repository pattern | Ganti implementasi repository tanpa menulis ulang UI. |
| UI/UX | Perlu DESIGN.md sebelum kerja UI | Menghindari desain template AI yang generik. |

### Prinsip repository pattern

```
UI (Riverpod providers)
       |
       v
[ProjectRepository]  <-- interface
       |                    |
       +-- DriftProjectRepository      (local, dipakai P0-P2)
       +-- SupabaseProjectRepository   (remote, dipakai P3+, swap tanpa ubah UI)
```

---

## 2. Daftar Prioritas

### P0: Fondasi (minggu 1)

~~1. Pisahkan model `Project` & `Task` dari `tracking_screen.dart` ke folder `domain/`.~~
~~2. Jadikan model **immutable** (pakai `copyWith`) supaya siap untuk Riverpod & realtime.~~
~~3. Setup **Drift**: tabel `projects` (judul, kategori, warna, status kanban, deadline) dan `tasks` (nama, isDone, posisi kolom, projectId).~~
~~4. Repository layer: interface `ProjectRepository` + `DriftProjectRepository`.~~
~~5. Riverpod setup: `StreamProvider` yang live-update dari DB.~~
~~6. Pindahkan `go_router` & `google_fonts` dari `dev_dependencies` ke `dependencies` (posisi sekarang salah), lalu susun `GoRouter` per screen.~~
~~7. Lengkapi UI states dashboard (empty, loading, error). Sekarang belum ada.~~

### P1: Personal MVP (minggu 1-2)

8. **Kanban board**: 4 kolom (To Do, In Progress, Review, Done), geser task antar kolom.
9. **Deadline & reminder**: field deadline + notifikasi H-1 & H-3 + banner overdue.
10. Ganti semua data in-memory ke persisten Drift (tambah, hapus, toggle project & task).
11. Progress bar & warna kategori dipertahankan dari data asli DB.

### P2: Modes dari data nyata (minggu 2-3)

12. **Present Mode**: slide auto-generate dari checklist & milestone + presenter notes. Shell sudah ada.
13. **Quiz Mode single user**: flashcard ke kuiz dari task/notes, simpan skor. Shell sudah ada.
14. **Mode switching**: FAB (Work / Present / Quiz) + keyboard shortcut (Spasi next slide, Esc keluar, Ctrl+K quick search).

### P3: Supabase & Auth (minggu 3-4)

15. Buat project Supabase + schema SQL (profiles, projects, tasks) + Row Level Security.
16. `supabase_flutter` + `SupabaseProjectRepository`, swap tanpa ubah UI.
17. **Auth**: register/login untuk host, anonymous untuk peserta quiz.

### P4: Kolaborasi & Calendar (minggu 4-6)

18. Realtime sync checklist & board lewat Supabase Realtime.
19. Invite member + **RBAC** (Owner, Editor, Viewer).
20. **Presence indicator** + avatar stack.
21. **@mentions** & komentar kontekstual di task.
22. Google Calendar **one-way push** (deadline ke GCal).
23. Notifikasi push + daily briefing.

### P5: Klien & lanjutan (minggu 6+)

24. Client review link (read-only) + sticky notes + resolve komentar.
25. Quiz live: QR code, leaderboard, co-host, multi-pemain.
26. Google Calendar **two-way sync**.
27. Dashboard analitik: tugas on-time, kontribusi anggota tim.
28. Dark/light mode, offline-first penuh, polish performa.

---

## 3. Peta Fase ke Roadmap PRD

| Phase PRD | Isi | Posisi di plan ini |
|---|---|---|
| Phase 1 (Personal MVP & Calendar) | Tracking, Present & Quiz single user, Calendar one-way | P0, P1, P2, dan item 22 di P4 |
| Phase 2 (Collaboration & Two-Way Sync) | Multi-user, RBAC, realtime, @mentions, presence, GCal two-way | P3 (fondasi), P4 (sebagian), item 26 di P5 |
| Phase 3 (Client & Advanced) | Client review, co-host quiz, dashboard analitik | P5 |

Catatan: Supabase & Auth sengaja digeser ke **setelah** personal MVP (P3), bukan di awal, supaya P0-P2 berjalan 100% offline tanpa perlu akun layanan apa pun. Urutan ini selaras dengan prinsip "Offline First" di PRD: data lokal sebagai sumber utama, Supabase sebagai remote sync.

---

## 4. Catatan Penting

- **Immutability**: model `Task` & `Project` saat ini mutable tanpa `copyWith`. Itu merepotkan untuk Riverpod & realtime nanti, jadi diperbaiki di P0 item 1-2.
- **Manfaat repository pattern**: migration local ke Supabase tidak menyentuh satu baris pun di UI; cukup tambah satu implementasi baru.
- **DESIGN.md**: wajib ada sebelum kerja UI dimulai. Berisi identitas, palet, tipografi, dan mood. Ini menentukan kualitas visual akhir, bukan sekadar "rapi".
- **Kanban status** disimpan sebagai enum (todo, in_progress, review, done) sejak P0 supaya tidak butuh migrasi data di P1.