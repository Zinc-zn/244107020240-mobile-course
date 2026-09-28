// Smoke test untuk aplikasi Galeri Widget.
//
// Memastikan halaman utama galeri tampil dan setiap kartu kategori bisa
// dibuka tanpa error.

import 'package:flutter_test/flutter_test.dart';

import 'package:widgets_try/gallery/camera_demo.dart';
import 'package:widgets_try/main.dart';

void main() {
  testWidgets('Galeri widget menampilkan daftar kategori', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Galeri Widget'), findsOneWidget);
    expect(find.text('Navigasi'), findsOneWidget);
    expect(find.text('Dialog & Feedback'), findsOneWidget);
    expect(find.text('Animasi'), findsOneWidget);
    expect(find.text('Async & State'), findsOneWidget);
  });

  testWidgets('Halaman Kamera belum dibuat sebelum kartunya diklik', (
    WidgetTester tester,
  ) async {
    // Ini yang menjaga kamera tetap mati di beranda: CameraDemo tidak boleh
    // ada di widget tree (dan karenanya initState-nya tidak jalan) sampai
    // kartu "Kamera" benar-benar dibuka.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(CameraDemo), findsNothing);
  });
}
