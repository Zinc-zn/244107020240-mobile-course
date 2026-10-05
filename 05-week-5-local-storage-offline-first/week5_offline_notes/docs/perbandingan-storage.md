# Tabel Perbandingan Storage — Lembar Kerja Minggu 5

Diisi berdasarkan hasil verifikasi mandiri (mencoba `flutter pub add`, membangun
skema, menjalankan test), bukan sekadar menyalin jawaban AI. Sumber verifikasi:
implementasi di `lib/data/` dan `test/note_test.dart` pada repo ini.

| Kriteria | SharedPreferences | Hive | sqflite | Drift |
|---|---|---|---|---|
| Kompleksitas query | Tidak ada query — hanya get/set per key | Filter manual lewat `box.values.where(...)`; tidak ada SQL | SQL penuh: WHERE, ORDER BY, JOIN, COUNT, transaksi | SQL penuh lewat API Dart yang type-safe (select, join, group by) |
| Dukungan relasi | Tidak ada | Tidak ada (harus disimpan/embed manual) | Ada — FOREIGN KEY, JOIN antar tabel | Ada, dan relasi dipetakan ke objek Dart |
| Reaktivitas (stream) | Tidak ada (bisa simulasi manual) | `box.listenable()` (package terpisah) | Tidak ada stream; refresh manual (di project: invalidate Riverpod) | Ya — `watch()` mengembalikan Stream otomatis |
| Type-safety | Terbatas pada bool/int/double/String/List<String> | Adapter per tipe; kurang aman tanpa codegen | Peta String→Object?, konversi manual `toMap`/`fromMap` | Sangat baik — class + codegen, error tertangkap saat kompilasi |
| Ukuran boilerplate | Paling kecil (4 method di PrefsRepository) | Kecil, tapi butuh adapter untuk tipe kompleks | Sedang — skema SQL + mapping manual (±60 baris di project ini) | Besar — tabel class + build_runner + part files |
| Kemudahan testing | Mudah (repo bisa di-fake, perlu SharedPreferences.setMockInitialValues) | Mudah (in-memory path) | Mudah lewat DI `openDb` — terbukti di `test/note_test.dart` | Mudah (NativeDatabase.memory) tapi butuh codegen dulu |
| Cocok untuk preferensi? | **Ya — pilihan final project ini** | Bisa, tapi overkill untuk beberapa bool/String | Bisa, tapi berlebihan (buka DB hanya untuk 2 key) | Sangat berlebihan |
| Cocok untuk 1000+ catatan? | **Tidak** — satu perubahan = tulis ulang seluruh JSON | Bisa untuk cache sederhana tanpa query kompleks | **Ya — pilihan final project ini** | Ya, apalagi kalau butuh reaktivitas |
| Keputusan & alasan | Dipakai untuk tema gelap/terang & waktu terakhir dibuka: data primitif kecil, baca sekali saat startup | Ditolak: kebutuhan utama catatan adalah query terurut + update parsial + agregasi antrean sync yang tidak nyaman di Hive | Dipakai untuk notes + cached_posts: ORDER BY updated_at DESC, transaksi/batch cache, COUNT dirty untuk badge | Ditolak untuk skala ini: 1 tabel sederhana tidak mengjustifikasi codegen build_runner; reaktivitas cukup lewat invalidasi Riverpod |

## Catatan keputusan

Aturan praktis yang terbukti selama praktikum: **koleksi masuk database, primitif
kecil masuk key-value store**. Menyimpan daftar catatan sebagai JSON string di
SharedPreferences membuat query, update parsial, dan sinkronisasi menjadi rapuh:
setiap edit satu catatan berarti menulis ulang seluruh daftar, dan tidak ada cara
efisien menghitung "berapa yang belum tersinkron" tanpa mengurai semuanya.

Trade-off yang diterima: tanpa stream otomatis (Drift), UI di-refresh lewat
`ref.invalidate()` di `NoteActions` — eksplisit, mudah dilacak, dan cukup untuk
aplikasi ini.
