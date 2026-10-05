# Offline Notes — Minggu 5: Local Storage & Offline First

Aplikasi catatan offline-first Flutter untuk Praktikum Pemrograman Mobile
Minggu 5 (Jurusan Teknologi Informasi, Politeknik Negeri Malang, 2026).

## Tujuan

Membangun aplikasi catatan yang **tetap berfungsi penuh tanpa internet**:
preferensi pengguna tersimpan di perangkat, catatan tersimpan di SQLite, dan
perubahan yang belum terkirim disinkronkan otomatis saat koneksi kembali.

## Fitur Utama

- **Preferensi persisten** — tema gelap/terang dan "terakhir dibuka" tersimpan
  di SharedPreferences; tetap ada setelah aplikasi ditutup.
- **CRUD catatan SQLite** — tambah, ubah, hapus, urut terbaru (updated_at
  DESC); empat state UI (loading/error/empty/success) ditangani.
- **Offline-first** —
  - _Cache-first read_ untuk posts: tampilkan cache seketika, refresh di
    background.
  - _Dirty flag_: catatan yang belum terkirim ditandai dan dihitung pada badge
    AppBar.
  - _Antrean sinkronisasi_: tombol Sinkronkan mengirim catatan dirty ke server
    simulasi; gagal saat offline tidak menghilangkan antrean.
- **Aturan konflik eksplisit** — last-write-wins berdasarkan `updated_at`
  (fungsi murni `resolveConflict`, teruji).
- **Saklar "Paksa mode offline"** — simulasi offline yang deterministik untuk
  demo dan testing tanpa bergantung sinyal.
- **Detail catatan via GoRouter** — rute `/note/:id` membaca catatan langsung
  dari repository lokal (deep-link aman).
- **Testing** — 7 test lulus: model, provider dengan repository palsu, sync,
  dan aturan konflik.

## Stack Teknologi

| Paket              | Fungsi                                                 |
| ------------------ | ------------------------------------------------------ |
| flutter_riverpod   | State management (provider, AsyncValue, AsyncNotifier) |
| shared_preferences | Key-value: tema, waktu terakhir dibuka                 |
| sqflite            | SQLite: tabel `notes` dan `cached_posts`               |
| path               | Path database aman lintas platform (`p.join`)          |
| dio                | HTTP client untuk posts (jsonplaceholder)              |
| go_router          | Navigasi deklaratif, rute detail `/note/:id`           |

## Cara Menjalankan

```bash
flutter pub get
flutter run          # di emulator Android atau perangkat fisik
flutter analyze      # No issues found!
flutter test         # 00:00 +7: All tests passed!
```

> sqflite tidak mendukung web — jalankan di Android/iOS, bukan Chrome.

## Hasil yang Dicapai

- `flutter analyze`: **No issues found!**
- `flutter test`: **7/7 lulus** (minimal modul: 2).
- CRUD catatan berjalan penuh dalam mode pesawat (dibuktikan screenshot).
- Badge dirty akurat sebelum/sesudah sync; posts tampil dari cache offline.
- Dokumentasi AI Challenge dan tabel perbandingan storage di `docs/`.

## Aturan Konflik yang Dipilih

**Last-write-wins**: saat konflik, versi dengan `updated_at` terbaru
dipertahankan (`resolveConflict` di `lib/data/sync.dart`). Dipilih karena
sederhana, deterministik, dan mudah diuji; kelemahannya (perubahan lama bisa
hilang, bergantung jam perangkat) didokumentasikan di laporan.

## Temuan Verifikasi AI

Ringkasan: AI merekomendasikan SharedPreferences (preferensi) + SQLite
(catatan) — sesuai hasil verifikasi mandiri. Klaim "real-time" hanya benar
untuk Drift (`watch()`), bukan sqflite; reaktivitas di project ini memakai
invalidasi Riverpod. Detail: `docs/ai-prompt-challenge.md` dan
`docs/perbandingan-storage.md`.

## Struktur

```
week5_offline_notes/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   ├── local/{db.dart, note.dart}
│   │   ├── remote/post.dart
│   │   ├── repositories/{note_repository.dart, post_repository.dart}
│   │   ├── prefs.dart
│   │   └── sync.dart
│   ├── providers/{prefs_providers, note_providers, offline_providers, post_providers}.dart
│   ├── widgets/{note_form_dialog.dart, note_tile.dart}
│   └── pages/{notes_page, note_detail_page, posts_page, settings_page}.dart
├── test/note_test.dart
├── docs/            (AI challenge, perbandingan storage, uji offline, arsitektur)
└── screenshots/     (bukti pengujian di perangkat fisik)
```

## Identitas

- Nama: Mochammad Rijal Dzaki Rifki Afifudin
- NIM: 244107020240
- Kelas: TI-3C
- Repository: https://github.com/Zinc-zn/244107020240-mobile-course
