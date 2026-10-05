# Checklist Verifikasi Mandiri — Bukti dan Hasil

Pemeriksaan dilakukan 5 Oktober 2026 terhadap project `week5_offline_notes`
(di perangkat fisik POCO X3 NFC untuk butir perilaku, dan via tooling untuk
butir kode).

## 1. UI tidak memanggil SQLite/SharedPreferences secara langsung ✅

Hasil `grep -rn "sqflite|shared_preferences|package:dio|SharedPreferences|Database" lib/pages/ lib/widgets/`:
satu-satunya kemunculan adalah **string label** di
`lib/pages/settings_page.dart:37` — `subtitle: const Text('Disimpan di
SharedPreferences')` — bukan import maupun pemanggilan API.

Akses storage terpusat hanya di lapisan data:

```
lib/data/local/db.dart                    — pembuka database SQLite
lib/data/prefs.dart                       — SharedPreferences
lib/data/repositories/note_repository.dart — CRUD catatan
lib/data/repositories/post_repository.dart — cache posts + Dio
```

UI (`lib/pages/`, `lib/widgets/`) hanya memanggil `ref.watch`/`ref.read`
terhadap provider.

## 2. Aplikasi berfungsi penuh dalam mode pesawat ✅

Diuji di perangkat fisik dengan mode pesawat diaktifkan via sistem:
baca, tambah, ubah, dan hapus catatan berjalan tanpa error karena seluruh
operasi catatan menuju SQLite lokal. Bukti: `screenshots/p3-mode-pesawat.png`
(daftar catatan + penambahan catatan baru saat offline), tabel uji di
`docs/uji-offline.md` baris "CRUD mode pesawat (P3)" — Lulus.

## 3. Badge dirty akurat sebelum/sesudah sync; cache posts tampil tanpa internet ✅

- `screenshots/p4-dirty-sebelum.png` — badge = 1 dan chip "belum tersinkron"
  setelah menambah catatan.
- `screenshots/p4-sync-ditolak.png` — sync saat "Paksa mode offline" ditolak,
  snackbar muncul, badge tetap 1 (antrean tidak hilang).
- `screenshots/p4-dirty-sesudah.png` — snackbar "1 catatan berhasil
  disinkronkan", badge hilang, ikon awan hijau.
- `screenshots/p4-posts-offline.png` — halaman Posts menampilkan 100 posts
  dari tabel `cached_posts` saat mode pesawat.

## 4. flutter analyze tanpa issue dan semua test lulus ✅

```
Analyzing week5_offline_notes...
No issues found!

00:00 +9: All tests passed!
```

Sembilan test: 2 unit test model Note, 2 test provider catatan (repository
palsu), 3 test sync/konflik, 2 test cache-first posts (repository palsu).

## 5. Hasil AI diverifikasi dan didokumentasikan di folder docs/ ✅

- `docs/ai-prompt-challenge.md` — prompt, ringkasan output AI, AI Verification
  Checklist (4 temuan), keputusan final berargumen.
- `docs/perbandingan-storage.md` — tabel perbandingan 4 storage × 9 kriteria
  berdasarkan verifikasi mandiri, bukan salinan jawaban AI.
