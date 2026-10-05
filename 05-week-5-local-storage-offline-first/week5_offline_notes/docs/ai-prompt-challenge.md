# AI Prompt Challenge — Minggu 5

## 1. Prompt yang digunakan

Prompt berikut diberikan kepada AI coding assistant (ZCode / Claude, October 2026):

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## 2. Ringkasan output AI

AI merekomendasikan **kombinasi SharedPreferences + SQLite (sqflite)**:

- **Preferensi (tema, waktu terakhir dibuka)** → SharedPreferences, karena
  datanya kecil, primitif, key-value, dan didukung langsung platform
  (XML di `/data/data/<package>/shared_prefs/` di Android).
- **Catatan (1000+ item)** → SQLite via sqflite, karena mendukung query
  (`ORDER BY updated_at DESC`), filter, update parsial per baris, transaksi,
  dan skema eksplisit dengan tipe kolom.
- AI juga menyebut Drift unggul dalam reaktivitas (`watch()` berbasis stream)
  dan type-safety, tetapi menambah code generation (build_runner) sehingga
  boilerplate dan waktu build bertambah; Hive sangat cepat namun query/relasi
  kompleks terbatas.

Skema yang diusulkan AI untuk catatan (identik dengan yang dipakai project):

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,   -- ISO-8601, bisa diurutkan sebagai teks
  dirty INTEGER NOT NULL DEFAULT 0  -- 1 = belum tersinkron ke server
);
```

## 3. AI Verification Checklist (hasil verifikasi mandiri)

| # | Pertanyaan verifikasi | Temuan | Status |
|---|----------------------|--------|--------|
| 1 | Apakah AI menempatkan daftar catatan di SharedPreferences? | Tidak. Rekomendasi AI hanya memakai SharedPreferences untuk bool/String primitif. Kalaupun catatan disimpan sebagai satu string JSON di sana, setiap ubah satu catatan berarti baca–urai–tulis ulang seluruh daftar: rapuh dan lambat untuk 1000+ item. | Sesuai — diterima |
| 2 | Apakah skema AI mendukung antrean sync (dirty flag / updated_at) atau hanya CRUD polos? | Skema AI memuat kolom `dirty` dan `updated_at`, yang di project ini benar-benar dipakai: badge antrean (`countDirty`), urutan terbaru (`ORDER BY updated_at DESC`), dan aturan konflik last-write-wins. | Sesuai — diterima |
| 3 | Apakah klaim "real-time" AI didukung stream (Drift watch) atau hanya asumsi? | Klaim reaktif hanya berlaku untuk Drift (`watch()` mengembalikan `Stream`). sqflite **tidak** punya stream; reaktivitas di project ini dicapai dengan invalidasi provider Riverpod secara manual (`ref.invalidate` di `NoteActions`), bukan real-time otomatis. Klaim "real-time dengan sqflite" harus ditolak. | Dikoreksi |
| 4 | Apakah estimasi boilerplate AI masuk akal setelah dicoba (`flutter pub add` + migrasi skema)? | Terbukti saat praktikum: sqflite hanya butuh `toMap`/`fromMap` manual (~30 baris) tanpa codegen. Drift memang butuh `build_runner` + part files; estimasi AI bahwa boilerplate Drift lebih besar masuk akal, tetapi untuk skema 1 tabel + 1 tabel cache selisihnya masih wajar. | Sesuai — diterima |

## 4. Keputusan final dan alasan

**Keputusan: SharedPreferences (preferensi) + SQLite/sqflite (catatan dan cache posts)** — persis kombinasi yang dibangun di project ini.

Alasan teknis:

1. **Pola akses berbeda.** Preferensi dibaca/ditulis per-key sekali sesi; catatan
   butuh query terurut, update parsial, dan agregasi (`COUNT(*) WHERE dirty = 1`).
   Memaksakan keduanya ke satu storage akan salah dua-duanya.
2. **Query & transaksi.** Cache posts ditulis via `db.transaction` + `batch`
   (100 baris atomik). SharedPreferences tidak punya transaksi maupun query.
3. **Testing.** `NoteRepository` menerima `openDb` (dependency injection) sehingga
   test memakai repository palsu tanpa SQLite sungguhan — 7 test lulus di CI
   laptop tanpa emulator. Pola ini juga berlaku bila kelak migrasi ke Drift,
   sehingga keputusan ini tidak mengunci masa depan.
4. **Trade-off yang disadari.** Kehilangan reaktivitas otomatis ala Drift
   `watch()` — dikompensasi invalidasi eksplisit lewat provider, yang justru
   membuat alur data mudah dilacak. Untuk 1 tabel catatan sederhana, codegen
   Drift belum memberi manfaat sepadan.
