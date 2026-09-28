// Verifikasi setiap halaman demo di galeri bisa dibangun tanpa exception.
//
// Ini menangkap error runtime (mis. kegagalan plugin kamera/GPS di
// lingkungan tanpa hardware) yang tidak terlihat dari sekadar build.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:widgets_try/gallery/animasi_demo.dart';
import 'package:widgets_try/gallery/async_demo.dart';
import 'package:widgets_try/gallery/button_demo.dart';
import 'package:widgets_try/gallery/camera_demo.dart';
import 'package:widgets_try/gallery/dialog_demo.dart';
import 'package:widgets_try/gallery/gps_demo.dart';
import 'package:widgets_try/gallery/input_demo.dart';
import 'package:widgets_try/gallery/layout_demo.dart';
import 'package:widgets_try/gallery/media_demo.dart';
import 'package:widgets_try/gallery/navigasi_demo.dart';
import 'package:widgets_try/gallery/scroll_demo.dart';
import 'package:widgets_try/gallery/struktur_demo.dart';
import 'package:widgets_try/gallery/text_icon_demo.dart';

void main() {
  final pages = <String, Widget Function()>{
    'Navigasi': () => const NavigasiDemo(),
    'Dialog & Feedback': () => const DialogDemo(),
    'Animasi': () => const AnimasiDemo(),
    'Async & State': () => const AsyncDemo(),
    'List & Scrolling': () => const ScrollDemo(),
    'Gambar & Media': () => const MediaDemo(),
    'Input & Form': () => const InputDemo(),
    'Tombol': () => const ButtonDemo(),
    'Teks & Ikon': () => const TextIconDemo(),
    'Struktural & App': () => const StrukturDemo(),
    'Layout': () => const LayoutDemo(),
    'Kamera': () => const CameraDemo(),
    'GPS': () => const GeolocatorWidget(),
  };

  pages.forEach((name, builder) {
    testWidgets('Halaman "$name" tampil tanpa exception', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: builder()));
      // Biarkan future/stream async (kamera, GPS, demo async) selesai.
      // Demo "Async & State" memakai Future 2 detik dan stream 10 detik,
      // jadi waktu palsu dimajukan agar tidak ada timer yang menggantung.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(seconds: 12));
      expect(tester.takeException(), isNull);

      // Setiap halaman harus menampilkan AppBar.
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
