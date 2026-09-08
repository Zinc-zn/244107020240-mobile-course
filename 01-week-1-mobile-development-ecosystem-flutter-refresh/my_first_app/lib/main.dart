import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // 1. Konfigurasi Tema & Dark Mode otomatis
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        // 2. LayoutBuilder untuk UI Responsif (1 Kolom vs 2 Kolom)
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Mode Ponsel (Lebar < 600px): 1 Kolom Vertikal
            if (constraints.maxWidth < 600) {
              return const Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school, size: 72),
                      SizedBox(height: 16),
                      ProfileDetails(isTablet: false),
                    ],
                  ),
                ),
              );
            } 
            // Mode Tablet (Lebar >= 600px): 2 Kolom Horizontal
            else {
              return const Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school, size: 120),
                      const SizedBox(width: 48),
                      const ProfileDetails(isTablet: true),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

// Widget terpisah untuk detail profil
class ProfileDetails extends StatelessWidget {
  final bool isTablet;
  const ProfileDetails({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      // Teks rata kiri di tablet, rata tengah di ponsel
      crossAxisAlignment: isTablet ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        const Text(
          'Mochammad Rijal Dzaki Rifki Afifudin',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('NIM: 244107020240', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        const Text(
          '244107020240@student.polinema.ac.id',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Pemrograman Mobile — Minggu 1',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
