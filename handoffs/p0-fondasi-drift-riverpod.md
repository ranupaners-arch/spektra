# P0: Fondasi OmniSpace (Drift + Riverpod + Router)
Status: DITUNDA (inti selesai, verifikasi penuh menunggu toolchain) · Service: omnispace (Flutter) · Diperbarui: 2026-09-22 16:05
Referensi: PLAN.md P0 · commit belum dibuat

## Sedang dikerjakan
Inti P0 sudah selesai. Tersisa: commit + (opsional) tambah test repository
yang berjalan setelah toolchain mesin ini diperbaiki.

## Status terakhir (terbukti)
- flutter analyze: No issues found.
- flutter build web: sukses; sqlite3.wasm + drift_worker.js ikut ter-emit ke build/web.
- Smoke test headless Chrome (server build/web): tidak ada error JS runtime,
  drift wasm init tidak melempar error; screenshot 12.7 KB (bukan blank).
- flutter test GAGAL di mesin ini: native-asset `objective_c` (ditarik
  path_provider_foundation dtk drift_flutter) tidak bisa link libSystem.tbd
  SDK CommandLineTools 27 (tapi error: malformed file / unknown architecture
  arm64e.x1). Ini isu toolchain Apple, BUKAN isu kode.

## Keputusan penting
- Local-first Drift; Supabase menyusul via interface ProjectRepository.
- Tabel drift: ProjectRows/TaskRows + @DataClassName (ProjectRecord/TaskRecord)
  utk hindari bentrok dgn domain Project/Task. check() pakai isBetweenValues
  + ignore_for_file: recursive_getters (pola resmi drift).
- Model immutable + copyWith; TaskStatus enum (0..3) disimpan sejak P0,
  isDone = getter status==done.

## Langkah berikutnya
1. Commit P0 (handoffs/ ikut di-commit).
2. P0 selanjutnya: tambah test repository in-memory drift (bisa jalan setelah
   toolchain mac diperbaiki, atau coba sebelum jika environment berubah).
3. Lanjut P1: kanban board 4 kolom + deadline/reminder.

## Jangan lakukan
- Jangan seed data demo (empty state harus terlihat & teruji).
- Jangan tambah theme toggle dulu (nanti DESIGN.md/P2).
- Jangan claim `flutter test` lulus di mesin ini; dokumentasikan keterbatasan
  toolchain, bukan dianggap nothing.