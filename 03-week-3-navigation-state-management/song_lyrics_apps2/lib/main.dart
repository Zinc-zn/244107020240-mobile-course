import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'gallery/gallery_home.dart';
import 'models/lyric_line.dart';
import 'widgets/spotify_lyrics.dart';

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
  bool _isLiked = false;
  bool _isShuffle = false;
  int _repeatMode = 0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  static const Color _spotifyGreen = Color(0xFF1DB954);
  static const Color _bgDark = Color(0xFF121212);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFFB3B3B3);

  /// Penanda waktu lirik "YOU!" — LANY.
  ///
  /// Setiap `Duration` adalah detik saat bait tersebut mulai dinyanyikan.
  /// Nilai ini bisa digeser sedikit tanpa mengubah struktur daftar, dan dipakai
  /// untuk menyorot bait aktif saat lagu diputar.
  static const List<Duration> _verseStart = [
    Duration(seconds: 10),
    Duration(seconds: 35),
    Duration(seconds: 60),
    Duration(seconds: 85),
    Duration(seconds: 105),
    Duration(seconds: 120),
  ];

  /// Baris-baris lirik yang tampil di layar, sudah dipetakan ke [_lyricStart].
  static const List<String> _lyricText = [
    'You gave me hope when I was empty\n'
        'Walked me through the fire, you were there\n'
        "You're the sun to the moon\n"
        "You're my ocean, painted blue\n"
        "You, I'm nothing without you\n"
        '(Without you, without you)',
    'Like an angel in a nightmare\n'
        'You opened up my eyes\n'
        'Looking in all the wrong places\n'
        "You're the one I needed this whole time\n"
        "You're the sun to the moon\n"
        "You're my ocean, painted blue\n"
        "You, I'm nothing without you\n"
        '(Without you, without you)',
    "You're the light in the dark\n"
        "You're the arrow through my heart\n"
        "You, I'm nothing without you (oh, oh)\n"
        "I'm nothing without you (oh, oh)\n"
        "I'm nothing without you (oh, oh)\n"
        "I'm nothing without you",
    "You, I'm nothing without you\n"
        "I'm nothing without you\n"
        "I'm nothing without you\n"
        "I'm nothing without you",
    "You're the air in my lungs\n"
        "You're the veins to my blood\n"
        "Yeah, you, I'm nothing without you",
    "You're the sun to the moon\n"
        "You're my ocean, painted blue\n"
        "You, I'm nothing without you\n"
        '(Without you, without you)\n'
        "You're the light in the dark\n"
        "You're the arrow through my heart\n"
        "You, I'm nothing without you (oh, oh)\n"
        "I'm nothing without you (oh, oh)\n"
        "I'm nothing without you (oh, oh)\n"
        "I'm nothing without you",
  ];

  LyricTimeline get _timeline => LyricTimeline([
        for (int i = 0; i < _lyricText.length; i++)
          LyricLine(
            i < _verseStart.length ? _verseStart[i] : _verseStart.last,
            _lyricText[i],
          ),
      ]);

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: _textPrimary),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          children: const [
            Text(
              'PLAYING FROM ALBUM',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 11,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'LANY',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _spotifyGreen.withOpacity(0.22),
                        blurRadius: 40,
                        offset: const Offset(0, 18),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('image/cover.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'YOU!',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'LANY',
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isLiked = !_isLiked),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(_isLiked),
                        color: _isLiked ? _spotifyGreen : _textSecondary,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: _textPrimary,
                      inactiveTrackColor: const Color(0xFF4D4D4D),
                      thumbColor: _textPrimary,
                      overlayColor: _textPrimary.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: _duration.inSeconds > 0
                          ? _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble())
                          : 0,
                      max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1,
                      onChanged: (v) async {
                        await _audioPlayer.seek(Duration(seconds: v.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(_position),
                            style: const TextStyle(color: _textSecondary, fontSize: 11)),
                        Text(_fmt(_duration),
                            style: const TextStyle(color: _textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.shuffle,
                        color: _isShuffle ? _spotifyGreen : _textSecondary, size: 22),
                    onPressed: () => setState(() => _isShuffle = !_isShuffle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, color: _textPrimary, size: 38),
                    onPressed: () async => await _audioPlayer.seek(Duration.zero),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (_isPlaying) {
                        await _audioPlayer.pause();
                      } else {
                        await _audioPlayer.play(AssetSource('LANY - You!.mp3'));
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _textPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.white.withOpacity(0.12), blurRadius: 14),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 38,
                        color: _bgDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, color: _textPrimary, size: 38),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(
                      _repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
                      color: _repeatMode > 0 ? _spotifyGreen : _textSecondary,
                      size: 22,
                    ),
                    onPressed: () => setState(() => _repeatMode = (_repeatMode + 1) % 3),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            Expanded(
              child: SpotifyLyrics(
                timeline: _timeline,
                position: _position,
                activeColor: _spotifyGreen,
                onSeek: (target) async {
                  await _audioPlayer.seek(target);
                  if (mounted) setState(() => _position = target);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1DB954), Color(0xFF158C3E)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.music_note_rounded, color: Colors.white, size: 36),
                SizedBox(height: 8),
                Text(
                  'Menu Navigasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.music_note_rounded, color: Color(0xFF1DB954)),
            title: const Text('Lirik Lagu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(color: Color(0xFF2A2A2A)),
          ListTile(
            leading: const Icon(Icons.dashboard_customize, color: Color(0xFFB3B3B3)),
            title: const Text('Eksperimen Galeri Widget',
                style: TextStyle(color: Color(0xFFB3B3B3))),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const GalleryHome(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                        .chain(CurveTween(curve: Curves.ease));
                    return SlideTransition(position: animation.drive(tween), child: child);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
