# Pemisahan Tanggung Jawab Lapisan Data (Refactoring Challenge #2)

Hasil audit tanggung jawab setiap modul data setelah Praktikum 4:

| Modul | Tanggung jawab | Yang TIDAK boleh ada di sini |
|---|---|---|
| `lib/data/repositories/note_repository.dart` | CRUD catatan SQLite: fetch, getById, add, update, delete, countDirty, markAllSynced | Logika sinkronisasi, akses jaringan, cache posts |
| `lib/data/repositories/post_repository.dart` | Cache posts: baca `cached_posts`, fetch jaringan + tulis cache dalam transaksi | Operasi catatan, aturan konflik, saklar offline |
| `lib/data/sync.dart` | `syncNotes` (antrean dirty → server simulasi) dan aturan konflik `resolveConflict` | Query SQL langsung, Dio, provider Riverpod |
| `lib/data/prefs.dart` | Key-value preferensi (tema, waktu terakhir dibuka) | Apa pun yang berbentuk koleksi |

Hasil audit: tidak ada logika yang salah tempat — `NoteRepository` tidak
menyentuh cache posts, `PostRepository` tidak memanggil `markAllSynced`, dan
`syncNotes` hanya berbicara dengan `NoteRepository` melalui antarmuka method
(countDirty/markAllSynced), bukan SQL langsung. File ini dibuat sebagai bukti
pemeriksaan butir 2 Refactoring Challenge.
