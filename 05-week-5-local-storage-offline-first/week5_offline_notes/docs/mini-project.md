# Tugas Mini Project: Aplikasi Offline Notes — Matriks Kesesuaian

Matriks ketentuan Tugas Mini Project (Modul Minggu 5) terhadap implementasi
di repository ini. Semua ketentuan dipenuhi pada project praktikum yang
dikembangkan (`week5_offline_notes`), bukan project baru, sehingga seluruh
sejarah commit bisa dilacak.

| # | Ketentuan | Status | Implementasi / Bukti |
|---|-----------|--------|----------------------|
| 1 | Preferensi: toggle tema gelap/terang + waktu terakhir dibuka melalui SharedPreferences | ✅ | `lib/data/prefs.dart` (4 method), `lib/providers/prefs_providers.dart` (`darkModeProvider` optimistic update + rollback, `lastOpenedProvider` membaca sesi sebelumnya). Terbukti persisten setelah force-stop: `screenshots/p1-persistensi.png` |
| 2 | CRUD catatan persisten via SQLite + repository lokal + Riverpod; daftar urut `updated_at` terbaru | ✅ | `lib/data/repositories/note_repository.dart` (`fetchNotes` dengan `ORDER BY updated_at DESC`, add/getById/update/delete/countDirty/markAllSynced), `lib/providers/note_providers.dart`, UI di `lib/pages/notes_page.dart` + `note_detail_page.dart`. CRUD tervalidasi di perangkat (tabel uji P3 di `docs/uji-offline.md`) |
| 3 | Offline-first: cache-first untuk data bacaan, dirty flag + syncNotes untuk tulisan, aturan konflik eksplisit terdokumentasi | ✅ | Cache-first: `lib/providers/post_providers.dart` (baca cache → refresh background) + `lib/data/repositories/post_repository.dart` (transaksi + batch). Tulisan: `lib/data/sync.dart` (`syncNotes`, dirty flag). Aturan konflik: **last-write-wins** terdokumentasi di `docs/aturan-konflik.md` dan teruji |
| 4 | Bukti mode pesawat: screenshot daftar catatan offline + badge dirty sebelum/sesudah sync | ✅ | `screenshots/p3-mode-pesawat.png`, `p4-dirty-sebelum.png`, `p4-sync-ditolak.png`, `p4-dirty-sesudah.png`, `p4-posts-offline.png` — semua diambil di perangkat fisik POCO X3 NFC |
| 5 | Testing: minimal 2 test lulus (1 unit test model + 1 test provider repository palsu) | ✅ | **9 test lulus**: 2 model Note, 2 provider catatan (FakeNoteRepository), 3 sync + konflik, 2 cache-first posts (FakePostRepository + saklar offline). `flutter analyze` tanpa issue |
| 6 | AI Challenge: prompt, tabel perbandingan storage, keputusan final, alasan teknis di docs/ | ✅ | `docs/ai-prompt-challenge.md` (prompt + checklist verifikasi 4 butir + keputusan berargumen), `docs/perbandingan-storage.md` (tabel 4 storage × 9 kriteria) |
| 7 | Push ke repository portfolio folder `05-week-5-local-storage-offline-first/` dengan struktur `lib/`, `test/`, `docs/`, `README.md`, `screenshots/` | ✅ | Ter-push ke `github.com/Zinc-zn/PemMob_Ganjil_2026` (branch `main`), folder `05-week-5-local-storage-offline-first/week5_offline_notes/`, struktur lengkap |

## README

`README.md` memuat seluruh bagian wajib: tujuan, fitur utama, stack teknologi,
cara menjalankan, hasil yang dicapai, aturan konflik yang dipilih, dan temuan
verifikasi AI (tautan ke docs).

## Commit per tahap (bukti proses)

```
eaef099 feat(db): model Note, skema SQLite, dan NoteRepository
68de387 feat(notes): halaman catatan offline dengan Riverpod
39611fc feat(sync): cache-first posts, dirty flag, dan sinkronisasi
054615c test: model, provider, dan sync dengan repository palsu
a24a5bc refactor(ui): ekstrak NoteTile dengan badge belum tersinkron
b57a0c0 docs(challenge): verifikasi AI, tabel perbandingan storage, audit pemisahan lapisan data
685ea6a refactor(navigation): halaman detail catatan dengan GoRouter (/note/:id)
597257f docs: README, uji offline, dan screenshot pengujian di perangkat fisik
```

(Praktikum 1 berada pada commit awal project sebelum daftar di atas.)

## Nilai tambah di luar ketentuan minimum

- Halaman detail dengan GoRouter (`/note/:id`) — Refactoring Challenge
  selesai, bukan hanya draf.
- Saklar "Paksa mode offline" untuk demo deterministik + uji penolakan sync.
- Widget `NoteTile` terpisah dengan chip status sinkronisasi.
- 9 test (rubrik memberi nilai penuh mulai ≥5).
