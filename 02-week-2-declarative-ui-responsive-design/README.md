# Laporan Praktikum Minggu 2: Declarative UI & Responsive Design

**Nama:** Mochammad Rijal Dzaki Rifki Afifudin
**NIM:** 244107020240

Berikut adalah hasil pengerjaan praktikum minggu kedua untuk Declarative UI & Responsive Design pada flutter

## 1. Praktikum: layout sederhana (warm-up)

Sebelum dashboard responsif, latih dulu widget dasar dengan membuat kartu profil sederhana. Buat project baru atau ganti sementara isi lib/main.dart:

```dart
    import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: ProfileCard()),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Nama Mahasiswa',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Mochammad Rijal Dzaki Rifki Afifudin'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: Text('NIM')),
            Text('244107020240'),
          ]),
          const Row(children: [
            Expanded(child: Text('Kelas')),
            Text('TI-3C'),
          ]),
        ],
      ),
    );
  }
}
```

**Hasil Run Aplikasi**  
![Aplikasi Berjalan](screenshots/app_result.png)

### Eksperimen warm-up

1. Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.
2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu.
3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama.

### Hasil Eksperimen warm-up

1. ![experiment-wire-up-1](screenshots/experiment-wire-up-1.png)

Pertama, ada pesan yang mengatakan “Undefined name 'child'". Pesan ini muncul di kolom 17 baris 37. Artinya, kompiler Dart tidak mengenali kata “child” sebagai variabel atau properti yang benar di tempat itu. Dalam konteks Flutter, “child” biasanya digunakan sebagai parameter bernama di dalam widget, seperti Container(child: Text('Halo')). Kesalahan ini sering terjadi jika Anda menulis “child:” di dalam kurung siku, misalnya di dalam properti “children: [ child: Text('Halo') ]". Di dalam list, Anda seharusnya hanya menulis widgetnya saja, tanpa awalan “child:".

Kesalahan lainnya adalah pesan “Expected to find ']'", yang muncul di kolom 22 baris 37. Pesan ini berarti kompiler mengharapkan tanda kurung siku tutup “]” tetapi menemukan sesuatu yang tidak sesuai. Kesalahan ini biasanya terjadi karena kesalahan sintaks sebelumnya. Misalnya, jika Anda menuliskan “child:” di dalam list, kompiler akan bingung dan mengira list sudah selesai sebelumnya. Akibatnya, kompiler mengharapkan tanda tutup list yang hilang.

2. Hasil sebelum diganti menjadi default:
   ![Aplikasi Berjalan](screenshots/app_result.png)

Hasil setelah diganti menjadi default:
![Aplikasi Berjalan](screenshots/default.png)

Analisis:
Jika menghapus baris `mainAxisSize: MainAxisSize.min`, maka `Column` tersebut akan mencoba mengambil ruang vertikal sebanyak mungkin dari induknya. Karena induknya adalah sebuah `Container` yang berada di dalam widget `Center`, kartu profil akan meregang (stretch) secara vertikal dari ujung atas hingga ujung bawah. Konten di dalamnya tetap berada di atas, namun warna latar belakang kartu (Colors.indigo.shade50) akan memenuhi seluruh tinggi layar. 3. Modiffikasi Code:

3. Modifikasi Code:
```
          const Row(
            children: [
              Expanded(child: Text('Email')),
              Text('244107020240@student.polinema.ac.id'),
            ],
          ),
```

Hasil:
![Tambah Data](screenshots/add-email.png)

### Merapikan Tampilan
Code:
```
 import 'package:flutter/material.dart';

void main() => runApp(const ProfileApp());

class ProfileApp extends StatelessWidget {
  const ProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Center(child: ProfileCard())),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                child: Icon(Icons.person, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Nama Mahasiswa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Mochammad Rijal Dzaki Rifki Afifudin',
                      style: TextStyle(height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.black12),
          const SizedBox(height: 12),

          // Menggunakan helper method agar kode lebih rapi
          _buildDataRow('NIM', '244107020240'),
          _buildDataRow('Kelas', 'TI-3C'),
          _buildDataRow('No. Absen', '14'),
          _buildDataRow('Tanggal Lahir', '7'),
          _buildDataRow('Email', '244107020240@student.polinema.ac.id'),
        ],
      ),
    );
  }

  // Fungsi pembantu untuk membuat baris data
  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, // Label mengambil 2 bagian ruang
            child: Text(label, style: const TextStyle(color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5, // Value mengambil 5 bagian ruang (lebih luas)
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 2. Praktikum: dashboard responsif

Buka lib/main.dart. Buat aplikasi profil sederhana berikut, lalu jalankan pada emulator atau perangkat fisik.

Code:
```
import 'package:flutter/material.dart';

void main() => runApp(const DashboardApp());

class DashboardApp extends StatelessWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
      themeMode: ThemeMode.system,
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700 ? 2 : 1;
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.6,
            children: const [
              DashboardCard(title: 'Assignments', value: '8'),
              DashboardCard(title: 'Attendance', value: '92%'),
              DashboardCard(title: 'Portfolio', value: 'Ready'),
              DashboardCard(title: 'Current week', value: '02'),
            ],
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  const DashboardCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Expanded(child: Text(title)),
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
        ]),
      ),
    );
  }
}
```
Hasil:


### Menambahkan interaksi: StatefulWidget dan Cupertino
Code:
```
class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: Colors.indigo),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}
```
Hasil:


## 3. Latihan Mandiri: Dart Refresh

Pada latihan ini, sebuah fungsi `hitungLuasPersegiPanjang` dan class `Profil` telah diimplementasikan di dalam file `test/widget_test.dart` untuk menguji pemahaman dasar sintaks Dart beserta penanganan nilai _null_ secara aman (_null-safety_). Berikut adalah dokumentasinya:

**Kode Implementasi:**

```dart
void main() {
  double luas = hitungLuasPersegiPanjang(10, 10);
  print('luas persegi panjang : $luas');

  Profil profil1 = Profil(nama: 'Rijal Dzaki', nim: '244107020240');
  String emailDitampilkan = profil1.email ?? 'Belum ada email';
  print('Nama ${profil1.nama}, Nim ${profil1.nim}, Email : $emailDitampilkan');
}

double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

class Profil {
  Profil({required this.nama, required this.nim, this.email});
  final String nama;
  final String nim;
  final String? email;
}
```

**Hasil Eksekusi (`dart run test/widget_test.dart`)**  
![Hasil Dart Refresh](screenshots/dart_refresh.png)

## 4. Hot Reload vs Hot Restart

Dari hasil percobaan mengubah kode UI di `main.dart`, berikut adalah perbedaan dari kedua fitur tersebut:

- **Hot Reload (`r`):** Prosesnya sangat cepat dan instan. Fitur ini memperbarui tampilan UI tanpa mereset data atau state yang sedang berjalan. Sangat efisien digunakan ketika sedang menyesuaikan desain atau layout aplikasi.
- **Hot Restart (`R`):** Memakan waktu sedikit lebih lama karena aplikasi dimatikan dan dinyalakan ulang dari awal. Semua data dan state akan ter-reset kembali ke titik awal. Fitur ini digunakan ketika terdapat perubahan pada logika program atau penambahan variabel baru yang membutuhkan inisialisasi ulang.

## 5. Mini Assignment

Pada tugas mini ini, informasi NIM dan juga kelas telah ditambahkan pada tampilan utama aplikasi Profil Mahasiswa. Berikut adalah potongan kode yang disematkan pada bagian `Column` di dalam file `main.dart`:

```dart
              Text(
                'Mochammad Rijal Dzaki Rifki Afifudin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('NIM: 244107020240', style: TextStyle(fontSize: 18)),
              SizedBox(height: 4),
              Text(
                '244107020240@student.polinema.ac.id',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text('Pemrograman Mobile — Minggu 1'),
```

**Hasil Run Aplikasi**  
![Aplikasi Berjalan](screenshots/app_final_result.jpeg)

## 6. Jawaban Tugas Refleksi

**a. Kapan native lebih tepat dipilih daripada cross-platform?**  
Pendekatan native lebih tepat dipilih ketika aplikasi membutuhkan performa maksimal (seperti game 3D) atau membutuhkan integrasi langsung ke hardware perangkat secara mendalam (misalnya sensor khusus atau bluetooth tingkat lanjut). Sedangkan cross-platform lebih cocok digunakan untuk menghemat biaya dan mempercepat waktu rilis karena satu basis kode bisa digunakan untuk Android dan iOS sekaligus.

**b. Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**  
Di Flutter, UI bersifat deklaratif, yang berarti tampilan layar adalah cerminan langsung dari state (data) saat ini. Ketika state berubah, instruksi perubahan elemen UI tidak perlu ditulis secara manual. Flutter secara cerdas akan otomatis membangun ulang (_rebuild_) bagian widget tree yang terdampak oleh perubahan data tersebut.

**c. Mengapa commit kecil dengan pesan jelas bermanfaat bagi pekerjaan tim dan portfolio?**  
Dalam lingkup kerja tim, commit yang kecil dengan pesan yang jelas sangat membantu proses pelacakan ketika terjadi _bug_. Hal ini memudahkan pencarian bagian kode yang bermasalah dan lebih aman apabila harus dilakukan _revert_ (dikembalikan ke versi sebelumnya). Untuk keperluan portofolio, hal ini menunjukkan pola kerja yang terstruktur dan rapi, dibandingkan menumpuk banyak perubahan kode sekaligus yang sulit dibaca.
