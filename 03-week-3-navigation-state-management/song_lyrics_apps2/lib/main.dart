import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'gallery/gallery_home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Song',
      debugShowCheckedModeBanner: false,
      home: const LayarLirik(),
    );
  }
}

class LayarLirik extends StatefulWidget {
  const LayarLirik({super.key});

  @override
  State<LayarLirik> createState() => _LayarLirikState();
}

class _LayarLirikState extends State<LayarLirik> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    // Mendengarkan perubahan status play/pause
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lirik Lagu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Center(
                child: Text(
                  'Menu Navigasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Lirik Lagu'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_customize),
              title: const Text('Eksperimen Galeri Widget'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Menggunakan PageRouteBuilder untuk mendemonstrasikan custom transition (Widget ke-6)
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const GalleryHome(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Header (Cover Album, Judul Lagu, dan Nama Artis)
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      image: const DecorationImage(
                        image: AssetImage('image/cover.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'YOU!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'LANY',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Bagian Lirik Lagu
              Expanded(
                child: ListView(
                  children: const [
                    Text(
                      "Like water in the desert\nImpossible to find\nYou found me when I was broken\nPut me back together, gave me life\nLike a flower in the concrete\nSo beautiful and rare",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "You gave me hope when I was empty\nWalked me through the fire, you were there\nYou're the sun to the moon\nYou're my ocean, painted blue\nYou, I'm nothing without you\n(Without you, without you)\nLike an angel in a nightmare\nYou opened up my eyes\nLooking in all the wrong places\nYou're the one I needed this whole time\nYou're the sun to the moon\nYou're my ocean, painted blue\nYou, I'm nothing without you\n(Without you, without you)\nYou're the light in the dark\nYou're the arrow through my heart\nYou, I'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you\nYou, I'm nothing without you\nI'm nothing without you\nI'm nothing without you\nI'm nothing without you\nYou're the air in my lungs\nYou're the veins to my blood\nYeah, you, I'm nothing without you\nYou're the sun to the moon\nYou're my ocean, painted blue\nYou, I'm nothing without you\n(Without you, without you)\nYou're the light in the dark\nYou're the arrow through my heart\nYou, I'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bagian Kontrol Navigasi Musik
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play(AssetSource('LANY - You!.mp3'));
                      }
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
