# P1: Kanban board + Deadline & Reminder
Status: SELESAI (commit c1c8e6f, belum push) · Service: spektra (Flutter) · Diperbarui: 2026-09-23 11:40
Referensi: PLAN.md P1 · commit c1c8e6f · Fix #2 (CHANGELOG_FIXES.md)

## Status terakhir (terbukti di mesin ini)
- `flutter analyze`: No issues found. · `flutter build web`: sukses.
- Smoke headless Chrome build/web: tanpa error JS runtime.
- `flutter test` MASIH GAGAL di mesin ini: native-asset objective_c (path_provider_foundation) tak bisa
  link libSystem.tbd SDK CommandLineTools 27. Isu toolchain Apple, bukan kode.
- P1 sudah commit (c1c8e6f) tapi BELUM di-push.

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
1. Push commit c1c8e6f bila sudah mantap; setelah dipush tutup handoff ini.
2. Test repository in-memory drift (moveTask/addTask/position) — menunggu toolchain mac diperbaiki.
3. Fokus sekarang: fase backend (lihat handoffs/backend-db-postgres.md); lalu P2 saat balik ke frontend.

## Jangan lakukan
- Jangan klaim `flutter test` lulus di mesin ini (toolchain, bukan kode).
- Jangan seed data demo (empty state harus tampil & teruji).
- Jangan tambah push notification tanpa keputusan ulang user.
- Jangan hapus tombol Presentasi/Kuiz saat mengubah detail screen (pernah tertinggal, lihat Fix #2).