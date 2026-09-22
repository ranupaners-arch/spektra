Berikut adalah **Product Requirements Document (PRD)** yang telah digabung dan disempurnakan menjadi satu dokumen utuh (versi 1.1). Dokumen ini mencakup semua fitur awal serta penambahan fitur integrasi kalender dan kolaborasi multi-user.

---

# 📄 PRODUCT REQUIREMENTS DOCUMENT (PRD)
**Nama Produk:** Spektra
**Versi:** 1.1 (Master Document)
**Tanggal:** 24 Mei 2024
**Target User:** Mahasiswa yang juga *freelancer* / pekerja lepas (Student-Professional Hybrid).

---

## 1. Product Vision & Objective
**Visi:** 
Menyediakan satu *workspace* kolaboratif terpadu yang tidak hanya berfungsi sebagai alat manajemen tugas dan kalender, tetapi juga dapat bertransformasi secara *real-time* menjadi alat presentasi profesional dan alat interaktif (kuiz) tanpa perlu berpindah-pindah aplikasi.

**Tujuan Utama:**
1. Memantau progress 3 jenis proyek (Kuliah, Klien, Pribadi) dan menyinkronkannya dengan Google Calendar.
2. Memfasilitasi kolaborasi *real-time* untuk kerja kelompok dan tim klien.
3. Memudahkan *tracking* tugas dengan sistem *checklist* visual yang bisa diubah menjadi *slide* presentasi untuk klien.
4. Menyediakan mode interaktif (kuiz) untuk presentasi tugas kampus yang hidup dan *engaging*.

---

## 2. User Personas
* **Nama:** Alex (21 tahun)
* **Role:** Mahasiswa Semester Akhir & *Freelance Web Developer*.
* **Pain Points:** 
  * Lupa *deadline* karena catatan dan jadwal tersebar di berbagai aplikasi.
  * Ribet membuat *slide* presentasi untuk klien hanya untuk menunjukkan *progress*.
  * Sulit mengoordinasikan tugas kelompok karena alat *tracking* tidak *real-time*.
  * Saat presentasi di depan kelas, butuh alat kuiz interaktif tapi setup-nya lama dan ribet.
* **Goals:** Ingin satu aplikasi yang bisa dipakai untuk kerja keras (ngoding/nugas), kerja cantik (presentasi ke klien), kolaborasi tim, dan kerja seru (kuiz di kelas).

---

## 3. Core Features (Fitur Utama)

### A. Project & Task Tracking (Mode Workspace)
Fitur dasar untuk manajemen proyek sehari-hari.
* **Kategorisasi Proyek:** Tag warna/label untuk `Kuliah` (Biru), `Klien` (Hijau), `Pribadi` (Ungu).
* **Board View (Kanban & Checklist):** Kolom *To Do, In Progress, Review, Done*. Setiap *card* tugas memiliki sub-task *checklist*.
* **Progress Bar Visual:** Menampilkan persentase penyelesaian proyek (misal: 75% Done).
* **Deadline & Reminder:** Notifikasi H-1 dan H-3 sebelum *deadline*.

### B. Calendar & Time Management (Integrasi Google Calendar)
Mengubah daftar tugas yang abstrak menjadi visualisasi waktu yang konkret.
* **Two-Way Sync (Sinkronisasi Dua Arah):** 
  * *Push:* Saat membuat *deadline* di Spektra, otomatis masuk ke Google Calendar.
  * *Pull:* Jika *deadline* digeser di Google Calendar, Spektra otomatis memperbarui *deadline* di aplikasi.
* **Color-Coded Calendar:** Setiap kategori proyek memiliki warna spesifik di Google Calendar agar mudah dibedakan.
* **Time Blocking:** Fitur untuk memblokir waktu di kalender khusus untuk mengerjakan *task* tertentu (misal: "Fokus Ngoding Project Klien" selama 2 jam).
* **Daily Briefing:** Notifikasi pagi yang merangkum apa yang harus dikerjakan hari ini berdasarkan jadwal kalender dan *task* yang *overdue*.

### C. Multi-User & Real-Time Collaboration
Mengubah aplikasi dari *single-player* menjadi *multiplayer* untuk kerja kelompok dan klien.
* **Role-Based Access Control (RBAC):**
  * **Owner:** Akses penuh (Kamu).
  * **Editor:** Bisa mengedit *checklist*, menambah *task*, memberi komentar (Anggota Kelompok / Tim Klien).
  * **Viewer/Client:** Hanya bisa melihat *Progress* dan *Slide*, serta memberi komentar (Klien).
* **Real-Time Sync (Live Collaboration):** Perubahan *checklist* atau perpindahan status terlihat secara *live* oleh anggota tim. Ada *Presence Indicator* (melihat siapa yang sedang online di proyek tersebut).
* **Contextual Comments & @Mentions:** Memberi komentar spesifik pada satu *task* atau *slide*, dan men-tag anggota tim (`@nama`) untuk notifikasi.

### D. Presentation Mode (Mode Klien & Review)
Mengubah data *tracker* menjadi *slide* presentasi yang bersih dan profesional.
* **Auto-Generate Slides:** Sistem mengubah *checklist* dan *progress bar* menjadi tampilan *slide* yang rapi (fokus pada *milestone* dan *timeline*).
* **Client Review Mode (Read-Only Link):** Klien bisa membuka *link* presentasi, melihat progress, dan **meninggalkan komentar/sticky notes** langsung di slide. Kamu bisa me-*resolve* komentar tersebut nanti.
* **Presenter Notes:** Catatan tersembunyi di setiap "slide" yang hanya terlihat oleh kamu (berisi *talking points*).
* **Mode Gelap/Terang:** Tampilan otomatis menyesuaikan ruangan (penting untuk presentasi di proyektor).

### E. Interactive Quiz Mode (Mode Kampus)
Mengubah catatan/materi proyek menjadi sesi kuiz interaktif.
* **Flashcard to Quiz:** Mengubah *task* atau *notes* menjadi pertanyaan (Pilihan Ganda / Essay Singkat).
* **Live Session (QR Code):** Memunculkan QR Code di layar. Teman sekelas bisa *scan* dan menjawab kuiz dari HP mereka secara *real-time*.
* **Leaderboard & Scoring:** Menampilkan papan skor langsung setelah kuiz selesai.
* **Co-Host Mode:** Jika presentasi dilakukan berdua (kelompok), kedua orang bisa menjadi *Host* kuiz. Satu orang memegang kendali *slide*, orang lain memantau jawaban dari HP/Laptop mereka.

---

## 4. User Flow (Alur Pengguna)

**Skenario 1: Meeting Progress dengan Klien**
1. Alex membuka proyek "Website Klien A" dan menekan **"Enter Presentation Mode"**.
2. Layar berubah menjadi *slide* bersih, menampilkan *progress bar* 60%.
3. Alex mempresentasikan. Klien mengangguk-angguk. Meeting selesai.

**Skenario 2: Presentasi Tugas Kelompok di Kelas**
1. Alex membuka proyek "Tugas Akhir Kelompok".
2. Alex menekan **"Enter Quiz Mode"**. Muncul QR Code di layar proyektor.
3. Teman sekelas *scan* dan menjawab. Alex menjadi *Host*, temannya menjadi *Co-Host* memantau skor.
4. Skor muncul, kelas jadi interaktif, dosen memberi nilai A.

**Skenario 3: Kerja Kelompok Tugas Kuliah**
1. Alex membuat proyek dan mengundang 3 teman sekelompok sebagai **Editor**.
2. Mereka membagi tugas via *checklist*. Alex melihat *presence indicator* teman sedang mengedit "Bab 2".
3. *Deadline* pengumpulan otomatis *sync* ke Google Calendar mereka berempat.

**Skenario 4: Review Progress Asinkron dengan Klien**
1. Alex mengirim *link Client View* ke klien.
2. Klien membuka *link*, melihat *Progress Bar*, lalu memberi komentar di *slide* "Desain Homepage": *"Tolong ubah warna tombol"*.
3. Alex mendapat notifikasi `@klien mentioned you`, langsung memperbaiki di **Work Mode**, dan menandai komentar sebagai *Resolved*.

---

## 5. UI/UX Guidelines
* **Konsep "Mode Switching":** Gunakan *floating action button* di pojok kanan atas untuk berpindah mode:
  * 🛠️ **Work Mode** (Tampilan padat, data *checklist*, kanban).
  * 📊 **Present Mode** (Tampilan minimalis, *full screen*, fokus ke *progress*).
  * 🎮 **Quiz Mode** (Tampilan *gamified*, warna cerah, ada timer & QR code).
* **Keyboard Shortcuts:** Spasi untuk *next slide*, Esc untuk keluar mode, `Ctrl+K` untuk *quick search*.
* **Offline First:** Aplikasi harus bisa berjalan tanpa internet (terutama untuk presentasi). Data akan *sync* saat online kembali.
* **Collaboration UI:** Gunakan *avatar stack* di pojok kiri atas untuk menampilkan siapa saja yang sedang melihat/mengedit proyek saat ini.

---

## 6. Non-Functional Requirements
* **Performa:** Transisi antar mode dan *real-time sync* harus di bawah 1 detik.
* **Keamanan:** Data proyek `Klien` harus di-*encrypt*, memiliki *Watermark* saat masuk *Present Mode*, dan *role-based access* yang ketat.
* **Responsivitas:** Optimal di Laptop/PC (untuk presentasi/host) dan Mobile (untuk teman kelas yang menjawab kuiz / klien yang memberi komentar).
* **Scalability:** Database harus mampu menangani *concurrent connections* saat mode kuiz digunakan oleh banyak pengguna secara bersamaan.

---

## 7. Tech Stack Recommendation
* **Frontend (Web App):** Next.js (React) + Tailwind CSS + Framer Motion (untuk animasi transisi *slide* dan *quiz* yang mulus).
* **Backend, Database & Real-time:** **Supabase**. 
  * *Alasan:* Memiliki fitur *Realtime* bawaan yang sangat kuat untuk kolaborasi multi-user, sistem *Auth* (Login/Invite) yang mudah, dan PostgreSQL untuk database yang *relational*.
* **Google Calendar API:** Menggunakan Google OAuth 2.0 dan Google Calendar API v3 untuk *two-way sync*.
* **Notification System:** Firebase Cloud Messaging (FCM) atau OneSignal untuk notifikasi *push* (terutama untuk @mentions dan deadline).

---

## 8. Roadmap (Fase Pengembangan)

* **Phase 1: Personal MVP & Calendar (Bulan 1)**
  * Fitur Tracking (Checklist, Kanban, Kategori).
  * Present Mode & Quiz Mode (Single user).
  * *Google Calendar One-Way Sync* (Hanya push dari App ke G-Cal).
* **Phase 2: Collaboration & Two-Way Sync (Bulan 2)**
  * **Multi-user:** Invite member, Role-based (Editor/Viewer), @mentions, *Presence indicator*.
  * **Real-time sync** untuk checklist dan board.
  * **Google Calendar Two-Way Sync** (Push & Pull).
* **Phase 3: Client & Advanced Features (Bulan 3)**
  * Client Review Mode (Klien bisa komen di slide & *resolve* komentar).
  * Co-host untuk Quiz Mode.
  * Dashboard analitik (Berapa banyak tugas yang selesai tepat waktu, kontribusi anggota tim).

---

## 9. Implementation Notes & Tips
1. **Real-time Collaboration di MVP:** Jangan langsung buat sistem *real-time cursor* (seperti Figma) karena sangat rumit dan memakan *resource*. Cukup buat *real-time data sync* (jika A mencentang kotak, kotak di layar B ikut tercentang dalam 1-2 detik). Itu sudah lebih dari cukup untuk awal.
2. **Google Calendar Sync:** Di tahap awal (Phase 1), buatlah fitur *One-way push*. *Two-way sync* membutuhkan *webhook* atau *cron job* yang lumayan memakan biaya server dan kompleks di awal. Pindahkan ke Phase 2.
3. **Undangan Tim:** Gunakan sistem "Share Link" atau "Invite via Email" yang sederhana. Pastikan ada sistem verifikasi agar tidak salah kirim akses ke klien.
4. **Quiz Mode Offline:** Pastikan QR Code kuiz tetap bisa di-*scan* dan jawaban tersimpan di *local storage* jika internet di ruang kelas tiba-tiba mati, lalu di-*sync* saat koneksi kembali.

---
*Dokumen ini dirancang agar Spektra tidak hanya menjadi alat catatan, tetapi menjadi Platform Manajemen Proyek Mini yang lengkap, menggantikan kebutuhan akan Trello/Notion (tracking), Canva/PPT (presentasi), dan Quizizz (kuiz) dalam satu ekosistem yang mulus.*