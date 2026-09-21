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

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {'title': 'Navigasi', 'icon': Icons.navigation, 'page': const NavigasiDemo()},
      {'title': 'Dialog & Feedback', 'icon': Icons.chat_bubble, 'page': const DialogDemo()},
      {'title': 'Animasi', 'icon': Icons.animation, 'page': const AnimasiDemo()},
      {'title': 'Async & State', 'icon': Icons.sync, 'page': const AsyncDemo()},
      {'title': 'List & Scrolling', 'icon': Icons.list, 'page': const ScrollDemo()},
      {'title': 'Gambar & Media', 'icon': Icons.image, 'page': const MediaDemo()},
      {'title': 'Input & Form', 'icon': Icons.input, 'page': const InputDemo()},
      {'title': 'Tombol', 'icon': Icons.smart_button, 'page': const ButtonDemo()},
      {'title': 'Teks & Ikon', 'icon': Icons.text_fields, 'page': const TextIconDemo()},
      {'title': 'Struktural & App', 'icon': Icons.architecture, 'page': const StrukturDemo()},
      {'title': 'Layout', 'icon': Icons.dashboard, 'page': const LayoutDemo()},
      {'title': 'Kamera', 'icon': Icons.camera_alt, 'page': const CameraDemo()},
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
                  MaterialPageRoute(builder: (context) => cat['page']),
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
