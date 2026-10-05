# Dokumentasi Uji Offline-First (Praktikum 4)

Pengujian dilakukan pada **perangkat fisik** POCO X3 NFC (M2007J20CG),
Android, aplikasi debug build. Mode pesawat diaktifkan dari pengaturan
perangkat; saklar "Paksa mode offline" dipakai sebagai simulasi deterministik.

## Skenario uji

| No | Skenario | Langkah | Hasil yang diharapkan | Hasil aktual | Status |
|----|----------|---------|----------------------|--------------|--------|
| 1 | Isi cache | Online, buka halaman Posts | 100 posts tampil; tersimpan di `cached_posts` | 100 posts tampil beberapa detik setelah dibuka; cache ditulis dalam satu transaksi | Lulus |
| 2 | Cache saat offline | Aktifkan mode pesawat, tutup lalu buka aplikasi, buka Posts | Posts tetap tampil dari cache | Daftar posts tetap muncul seketika tanpa jaringan (banner "Mode offline" tampil bila memakai saklar) | Lulus |
| 3 | Antrean dirty | Masih offline, tambah 3 catatan | Badge menunjukkan angka 3 | Badge AppBar = 3; tiap tile punya chip "belum tersinkron" | Lulus |
| 4 | Sync ditolak | Aktifkan "Paksa mode offline", tekan Sinkronkan | Snackbar "Perangkat offline…", badge tetap 3 | Snackbar `OfflineException: Perangkat offline, sinkronisasi ditunda.`; badge tetap 3 (antrean utuh) | Lulus |
| 5 | Sync berhasil | Matikan saklar offline, tekan Sinkronkan | Setelah ±1 detik snackbar "3 catatan…", badge hilang, ikon awan hijau | Snackbar "3 catatan berhasil disinkronkan"; badge hilang; chip hilang; ikon berubah hijau (cloud_done) | Lulus |
| 6 | Refresh background | Online, buka Posts | Daftar tampil seketika dari cache, lalu diperbarui | Daftar muncul seketika dari cache; UI diperbarui diam-diam oleh `_refreshInBackground` | Lulus |
| 7 | CRUD mode pesawat (P3) | Mode pesawat aktif: tambah, ubah, hapus catatan | Semua tetap berfungsi tanpa error | Seluruh operasi CRUD berjalan normal karena seluruh baca/tulis menuju SQLite lokal | Lulus |

## Screenshot bukti

- `screenshots/p1-tema-terang.png` — tema terang + "Terakhir dibuka" (sesi pertama).
- `screenshots/p1-tema-gelap.png` — tema gelap aktif setelah saklar ditekan.
- `screenshots/p1-persistensi.png` — setelah force-stop & buka ulang: tema tetap
  gelap dan "Terakhir dibuka" berisi waktu sesi sebelumnya.
- `screenshots/p3-mode-pesawat.png` — daftar catatan saat mode pesawat
  (ikon pesawat di status bar), badge = 1, chip "belum tersinkron".
- `screenshots/p4-dirty-sebelum.png` — badge angka 1 + chip sebelum sync.
- `screenshots/p4-sync-ditolak.png` — snackbar "Perangkat offline,
  sinkronisasi ditunda." saat "Paksa mode offline"; badge tetap 1.
- `screenshots/p4-dirty-sesudah.png` — snackbar "1 catatan berhasil
  disinkronkan", badge hilang, ikon awan hijau.
- `screenshots/p4-posts-offline.png` — halaman Posts tampil dari cache saat
  mode pesawat aktif.
- `screenshots/r3-detail-gorouter.png` — halaman detail `/note/:id`
  (hasil Refactoring Challenge #3).

## Observasi penting

1. **Cache-first memberi latency 0 ms** untuk kunjungan berikutnya: UI tidak
   pernah menunggu jaringan karena `build()` selalu mengembalikan cache dulu,
   lalu memperbarui di background.
2. **Antrean bertahan saat sync gagal.** `syncNotes` melempar `OfflineException`
   sebelum menyentuh flag, sehingga antrean tetap utuh — sesuai test
   `syncNotes ditolak saat offline dan dirty tetap utuh`.
3. **Kelemahan yang disadari** (diskusi modul): `markAllSynced()` menandai semua
   catatan bersih sekaligus; jika pengguna mengedit saat upload berlangsung,
   editan itu ikut dianggap terkirim. Perbaikan ideal: tandai bersih per
   `id + updated_at` yang benar-benar dikirim, atau pakai tabel outbox.

## Uji tambahan Praktikum 3

| No | Skenario | Langkah | Hasil yang diharapkan | Hasil aktual | Status |
|----|----------|---------|----------------------|--------------|--------|
| 1 | Empty state | Jalankan aplikasi pertama kali | Ikon + teks "Belum ada catatan" | Tampil seperti diharapkan | Lulus |
| 2 | Create | Tekan + Catatan, isi judul, Simpan | Catatan muncul paling atas, ikon awan oranye, badge = 1 | Sesuai | Lulus |
| 3 | Validasi | Simpan dengan judul kosong | "Judul wajib diisi", dialog tidak tertutup | Sesuai | Lulus |
| 4 | Update | Ketuk catatan, ubah isi, Simpan | Isi berubah, catatan naik ke teratas | Sesuai (edit dari halaman detail) | Lulus |
| 5 | Delete | Tekan ikon tempat sampah | Catatan hilang, badge berkurang | Sesuai | Lulus |
| 6 | Persistensi | Tutup aplikasi lalu buka kembali | Seluruh catatan masih ada | Sesuai | Lulus |
