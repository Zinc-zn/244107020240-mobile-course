import 'package:flutter/material.dart';

import 'gallery/gallery_home.dart';
import 'screens/home_screen.dart';
import 'services/player_service.dart';

void main() {
  runApp(const MyApp());
}

/// Aplikasi lirik lagu dengan beranda bergaya Spotify.
///
/// [PlayerService] dibuat sekali di sini agar status pemutaran tetap sama saat
/// berpindah antara beranda dan layar pemutar.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PlayerService _player = PlayerService();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Song',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kGreen),
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
      ),
      home: HomeScreen(player: _player),
      routes: {
        '/gallery': (_) => const GalleryHome(),
      },
    );
  }
}