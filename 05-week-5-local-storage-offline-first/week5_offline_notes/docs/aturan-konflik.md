# Aturan Konflik Sinkronisasi — Last-Write-Wins

## Masalah

Ketika catatan yang sama diubah di dua perangkat (atau di perangkat dan di
server), sinkronisasi dua arah akan menerima dua versi berbeda. Tanpa aturan
eksplisit, salah satu versi akan tertimpa secara diam-diam dan pengguna
kehilangan data tanpa penjelasan.

## Aturan yang dipilih

**Last-write-wins berdasarkan `updated_at`**: dari dua versi yang berkonflik,
versi dengan waktu perubahan (`updated_at`) paling baru dipertahankan.

Implementasinya adalah **fungsi murni** di `lib/data/sync.dart`:

```dart
/// Aturan konflik: last-write-wins berdasarkan updatedAt.
Note resolveConflict(Note local, Note remote) {
  return remote.updatedAt.isAfter(local.updatedAt) ? remote : local;
}
```

Fungsi ini tidak menyentuh database maupun jaringan sehingga dapat diuji
tanpa perangkat apa pun — dibuktikan oleh test
`resolveConflict memilih updatedAt terbaru` di `test/note_test.dart`
(dicek simetris: dipanggil dengan argumen `(local, remote)` maupun
`(remote, local)` menghasilkan keputusan yang sama).

## Mengapa memilih last-write-wins

| Aturan | Cara kerja | Kelebihan | Kekurangan |
|---|---|---|---|
| **Last-write-wins (dipilih)** | Pilih `updated_at` terbaru | Sederhana, deterministik, mudah diuji | Perubahan lama hilang; bergantung pada jam perangkat |
| Server-wins | Versi server selalu menang | Konsisten dengan server | Perubahan offline bisa terbuang tanpa jejak |
| Merge per field | Gabungkan field yang berbeda | Minim kehilangan data | Implementasi rumit untuk skema kecil |
| Tanya pengguna | Tampilkan dua versi | Pengguna memutuskan | Mengganggu pengalaman pengguna |

Untuk aplikasi catatan satu-pengguna, kehilangan versi lama ketika dua
perangkat mengubah catatan yang sama dalam hitungan detik adalah risiko yang
dapat diterima; kesederhanaan dan determinisme lebih berharga.

## Kelemahan implementasi saat ini (kejujuran teknis)

1. **`markAllSynced()` menandai semua catatan dirty sekaligus.** Jika
   pengguna mengedit catatan lain selama upload berlangsung, editan itu ikut
   ditandai bersih padahal belum terkirim. Perbaikan: kirim daftar
   `id + updated_at` yang benar-benar berhasil diunggah, lalu tandai bersih
   dengan `WHERE id = ? AND updated_at = ?`.
2. **Hapus langsung membuat server tidak pernah tahu.** Aplikasi nyata
   memakai tombstone (kolom `deleted = 1`) atau tabel outbox berisi antrean
   operasi, sehingga penghapusan bisa disinkronkan juga.
3. **Jam perangkat bisa melenceng.** Bila jam perangkat mundur, versi yang
   lebih baru bisa kalah. Solusi tingkat lanjut: gunakan waktu server atau
   logical clock (Lamport/HLC).

Ketiga kelemahan ini disadari dan diterima untuk skala praktikum; keduanya
terdokumentasi pula di `docs/uji-offline.md` (bagian Observasi penting).
