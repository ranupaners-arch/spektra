# CHANGELOG_FIXES

### Fix #1 — Import path salah di PresentationScreen: error "Target of URI doesn't exist" & "Undefined class 'Project'"

| | |
|---|---|
| Tanggal | 2026-09-22 |
| File | `lib/features/presentation_mode/presentation/presentation_screen.dart` |
| Masalah | `flutter analyze` memunculkan 2 error: URI import tidak ditemukan & class `Project` undefined; app gagal dikompilasi. |
| Akar | Import ke `tracking_screen.dart` memakai path `../tracking/...` padahal dari `presentation_mode/presentation/` harus naik 2 level (`../../`), bukan 1. Satu-satunya baris yang salah, tapi cukup mematikan kompilasi. |
| Fix | Ganti jadi `import '../../tracking/presentation/tracking_screen.dart';` — identik dengan pola yang sudah benar di `quiz_screen.dart`. |
| Verifikasi | Sebelum: 2 error di `flutter analyze`. Sesudah: `flutter analyze` → *No issues found* (0 error, 0 info, 0 warning) dan `flutter build web` sukses. |
| Pelajaran | Path relative import yang "naik level" mudah salah hitung jumlah `../`; bandingkan dengan impor di file saudara (quiz_screen.dart) yang benar. |
| Log Keyword | import path, uri_does_not_exist, undefined_class, Project, PresentationScreen |
| Deploy | BELUM DEPLOY |

### Fix #2 — Menulis ulang detail screen untuk kanban memunculkan undefined_getter 'strikethrough' + unused_import

| | |
|---|---|
| Tanggal | 2026-09-23 |
| File | `lib/features/tracking/presentation/project_detail_screen.dart` |
| Masalah | `flutter analyze` → 1 error `undefined_getter: 'strikethrough'` + 2 warning `unused_import`. Regresi lokal saat sesi P1 (belum sempat di-commit). |
| Akar | Nama properti Material yang benar adalah `TextDecoration.lineThrough`, bukan `strikethrough`. Tombol "Mode Khusus" (Presentasi/Kuiz) sempat ikut terbuang saat body ditulis ulang jadi kanban, sehingga import `presentation_screen.dart` & `quiz_screen.dart` jadi tak terpakai. |
| Fix | Ganti ke `TextDecoration.lineThrough`; kembalikan baris tombol Presentasi & Buat Kuiz (jalan ke `PresentationScreen` & `QuizScreen`) di atas kanban. |
| Verifikasi | Sebelum: 1 error + 2 warning. Sesudah: `flutter analyze` *No issues found*; `flutter build web` sukses (36.6s); smoke headless Chrome pada build/web tanpa error JS runtime (DOM memuat `flutter-view`). |
| Pelajaran | Saat menulis ulang widget besar, jangan buang navigasi/mode yang sudah ada dan cek ulang nama enum/properti terhadap SDK (lineThrough, bukan strikethrough). |
| Log Keyword | strikethrough, lineThrough, undefined_getter, unused_import, kanban, detail screen |
| Deploy | BELUM DEPLOY |