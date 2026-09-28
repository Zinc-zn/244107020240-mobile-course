import 'package:flutter/material.dart';

import 'navigasi_demo.dart';
import 'dialog_demo.dart';
import 'animasi_demo.dart';
import 'async_demo.dart';
import 'scroll_demo.dart';
import 'media_demo.dart';
import 'input_demo.dart';
import 'button_demo.dart';
import 'text_icon_demo.dart';
import 'struktur_demo.dart';
import 'layout_demo.dart';
import 'camera_demo.dart';
import 'gps_demo.dart';

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Halaman dibuat lewat builder, bukan widget yang sudah jadi, supaya
    // halaman hanya di-construct saat kartunya diklik. Ini penting untuk
    // Kamera & GPS: keduanya tidak boleh menyentuh hardware sebelum dibuka.
    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Navigasi',
        'icon': Icons.navigation,
        'builder': () => const NavigasiDemo(),
      },
      {
        'title': 'Dialog & Feedback',
        'icon': Icons.chat_bubble,
        'builder': () => const DialogDemo(),
      },
      {
        'title': 'Animasi',
        'icon': Icons.animation,
        'builder': () => const AnimasiDemo(),
      },
      {
        'title': 'Async & State',
        'icon': Icons.sync,
        'builder': () => const AsyncDemo(),
      },
      {
        'title': 'List & Scrolling',
        'icon': Icons.list,
        'builder': () => const ScrollDemo(),
      },
      {
        'title': 'Gambar & Media',
        'icon': Icons.image,
        'builder': () => const MediaDemo(),
      },
      {
        'title': 'Input & Form',
        'icon': Icons.input,
        'builder': () => const InputDemo(),
      },
      {
        'title': 'Tombol',
        'icon': Icons.smart_button,
        'builder': () => const ButtonDemo(),
      },
      {
        'title': 'Teks & Ikon',
        'icon': Icons.text_fields,
        'builder': () => const TextIconDemo(),
      },
      {
        'title': 'Struktural & App',
        'icon': Icons.architecture,
        'builder': () => const StrukturDemo(),
      },
      {
        'title': 'Layout',
        'icon': Icons.dashboard,
        'builder': () => const LayoutDemo(),
      },
      {
        'title': 'Kamera',
        'icon': Icons.camera_alt,
        'builder': () => const CameraDemo(),
      },
      {
        'title': 'GPS',
        'icon': Icons.location_on,
        'builder': () => const GeolocatorWidget(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Galeri Widget'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[100],
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // builder hanya dipanggil saat kartu diklik.
                    builder: (context) =>
                        (cat['builder'] as Widget Function())(),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(cat['icon'], size: 36, color: Colors.blue),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
