# CHANGELOG_FIXES

## Fix #1 — Import path salah di PresentationScreen: error "Target of URI doesn't exist" & "Undefined class 'Project'"

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