import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

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

    // Mendengarkan durasi lagu
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    // Mendengarkan posisi waktu musik
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Format durasi
  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inMinutes.remainder(60)}:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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

              // Progress Bar (Music)
              Row(
                children: [
                  Text(
                    formatTime(_position),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14.0,
                        ),
                        activeTrackColor: Colors.black,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: Colors.black,
                      ),
                      child: Slider(
                        min: 0,
                        max: _duration.inSeconds.toDouble() > 0
                            ? _duration.inSeconds.toDouble()
                            : 1,
                        value: _position.inSeconds.toDouble().clamp(
                          0.0,
                          _duration.inSeconds.toDouble() > 0
                              ? _duration.inSeconds.toDouble()
                              : 1,
                        ),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await _audioPlayer.seek(position);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatTime(_duration),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Bagian Kontrol Navigasi Musik
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _audioPlayer.seek(Duration.zero); // Kembali ke awal
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.skip_previous,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play(AssetSource('LANY - You!.mp3'));
                      }
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 32,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.skip_next,
                        size: 32,
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
