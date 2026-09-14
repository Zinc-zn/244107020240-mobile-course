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
