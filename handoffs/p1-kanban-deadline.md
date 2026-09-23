# P1: Kanban board + Deadline & Reminder
Status: BERJALAN (inti selesai, belum commit) · Service: spektra (Flutter) · Diperbarui: 2026-09-23 11:00
Referensi: PLAN.md P1 item 8-11 · Memory: Fix #2 (CHANGELOG_FIXES.md)

## Sedang dikerjakan
P1 inti sudah implement & lulus analisis+build web. Belum di-commit. P0 (f6b115b, 419911b, aec5af2) sudah push.

## Status terakhir (terbukti di mesin ini)
- `flutter analyze`: No issues found.
- `flutter build web`: sukses (36.6s); sqlite3.wasm + drift_worker.js ter-emit.
- Smoke headless Chrome build/web: tidak ada error JS runtime; DOM memuat flutter-view.
- `flutter test` MASIH GAGAL di mesin ini: native-asset objective_c (path_provider_foundation) tak bisa
  link libSystem.tbd SDK CommandLineTools 27. Isu toolchain Apple, bukan kode.

## Yang dikerjakan di P1
- Kanban 4 kolom (To Do/In Progress/Review/Done) di detail screen: horizontal scroll, LongPressDraggable +
  DragTarget antar kolom, reorder naik/turun dalam kolom, tombol tandai selesai, hapus task, edit nama, edit tenggat.
- Deadline: field di dialog tambah project & tambah task (date picker); edit tenggat project/task via bottom sheet
  (pilih tanggal / hapus tenggat); ditampilkan di kartu task & kartu proyek.
- Reminder in-app (keputusan user): banner overdue, "jatuh tempo besok", "jatuh tempo ≤ 3 hari" di detail screen;
  chip overdue/tenggat di kartu dashboard. Utility: `deadline_utils.dart` (DeadlineState, format, count).
- Repository baru: `moveTask` (status+posisi, transaction, re-shift posisi kolom) — drift_project_repository.dart;
  `renameTask`, `setTaskDeadline`, `addTask` kini terima `status` & `position`.
- Hapus proyek via menu di AppBar detail (confirm dialog).

## Keputusan penting
- Notifikasi push H-1/H-3 DITUNDA (user pilih "In-app dulu"): belum pakai flutter_local_notifications.
- Reorder dalam kolom pakai tombol ↑/↓, bukan drag (drag hanya antar kolom; posisi = append).
- Deadline dihitung per hari kalender (bukan jam) via deadline_utils.

## Langkah berikutnya
1. Commit P1 (belum di-commit). Setelah push, tutup handoff ini + tandai Fix #2 `✅ LIVE`.
2. Test repository in-memory drift (moveTask/addTask/position) — masih menunggu toolchain mac diperbaiki, atau
   coba `flutter test` lagi bila environment berubah.
3. P2 lanjut: Present/Quiz Mode dari data nyata + mode switching FAB. DESIGN.md wajib sebelum polish UI.

## Jangan lakukan
- Jangan klaim `flutter test` lulus di mesin ini (toolchain, bukan kode).
- Jangan seed data demo (empty state harus tampil & teruji).
- Jangan tambah push notification tanpa keputusan ulang user.
- Jangan hapus tombol Presentasi/Kuiz saat mengubah detail screen (pernah tertinggal, lihat Fix #2).