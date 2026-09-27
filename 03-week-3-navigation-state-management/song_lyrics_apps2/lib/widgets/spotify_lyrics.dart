import 'package:flutter/material.dart';

import '../models/lyric_line.dart';

/// Lembar lirik bergaya Spotify:
/// * baris yang sedang diputar diperbesar dan disorot putih,
/// * baris lain diredupkan,
/// * daftar ikut bergulir otomatis agar baris aktif selalu di tengah,
/// * setiap baris bisa disentuh untuk melompat ke bagian lagu tersebut.
class SpotifyLyrics extends StatefulWidget {
  const SpotifyLyrics({
    super.key,
    required this.timeline,
    required this.position,
    required this.onSeek,
    this.activeColor = const Color(0xFF1DB954),
  });

  final LyricTimeline timeline;
  final Duration position;
  final ValueChanged<Duration> onSeek;
  final Color activeColor;

  @override
  State<SpotifyLyrics> createState() => _SpotifyLyricsState();
}

class _SpotifyLyricsState extends State<SpotifyLyrics> {
  static const Color _highlight = Color(0xFFFFFFFF);
  static const Color _dim = Color(0xFFB3B3B3);

  final ScrollController _scroll = ScrollController();
  final List<GlobalKey> _lineKeys = [];

  int _lastActive = -2;
  int _lastAutoScrollAt = 0;
  int _userScrolledAt = 0;

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didUpdateWidget(covariant SpotifyLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timeline.lines.length != widget.timeline.lines.length) {
      _syncKeys();
    }
    _maybeAutoScroll();
  }

  void _syncKeys() {
    _lineKeys
      ..clear()
      ..addAll(List.generate(widget.timeline.lines.length, (_) => GlobalKey()));
  }

  /// Menggulir daftar agar baris aktif berada di tengah layar. Gulir otomatis
  /// ditunda sesaat setelah pengguna menggeser sendiri lirik, supaya daftar
  /// tidak "melawan" jari pengguna.
  void _maybeAutoScroll() {
    final active = widget.timeline.activeIndexAt(widget.position);
    if (active == _lastActive || active < 0) {
      if (active < 0) _lastActive = active;
      return;
    }
    _lastActive = active;

    // Beri jeda 2,5 detik setelah pengguna menggeser manual.
    if (DateTime.now().millisecondsSinceEpoch - _userScrolledAt < 2500) return;

    final key = _lineKeys[active];
    final ctx = key.currentContext;
    if (ctx == null) return;

    _lastAutoScrollAt = DateTime.now().millisecondsSinceEpoch;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctxNow = key.currentContext;
      if (ctxNow == null) return;
      Scrollable.ensureVisible(
        ctxNow,
        alignment: 0.45,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.timeline.activeIndexAt(widget.position);

    return NotificationListener<UserScrollNotification>(
      onNotification: (n) {
        // Abaikan gulir yang berasal dari animasi otomatis.
        if (DateTime.now().millisecondsSinceEpoch - _lastAutoScrollAt > 600) {
          _userScrolledAt = DateTime.now().millisecondsSinceEpoch;
        }
        return false;
      },
      child: Scrollbar(
        controller: _scroll,
        thickness: 2,
        radius: const Radius.circular(2),
        child: SingleChildScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ruang atas/bawah supaya baris aktif bisa benar-benar di tengah.
              SizedBox(height: MediaQuery.of(context).size.height * 0.22),
              for (int i = 0; i < widget.timeline.lines.length; i++)
                _buildLine(i, i == active),
              SizedBox(height: MediaQuery.of(context).size.height * 0.35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLine(int index, bool isActive) {
    final line = widget.timeline.lines[index];

    // Penanda bagian (Verse/Chorus) tampil kecil dan tidak pernah menyala.
    if (LyricTimeline.isHeader(line.text)) {
      return Padding(
        key: _lineKeys[index],
        padding: const EdgeInsets.only(top: 26, bottom: 8),
        child: Text(
          line.text.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF6A6A6A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      );
    }

    final isAdLib = LyricTimeline.isAdLib(line.text);
    final baseColor = isAdLib ? const Color(0xFF7A7A7A) : _dim;

    return GestureDetector(
      key: _lineKeys[index],
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSeek(line.start),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        style: TextStyle(
          fontSize: isActive ? 21.5 : 17.5,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          height: 1.42,
          color: isActive ? _highlight : baseColor,
          letterSpacing: isActive ? 0.1 : 0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Batang kecil sebagai penanda baris yang sedang dinyanyikan.
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                width: 3,
                height: isActive ? 22 : 0,
                margin: EdgeInsets.only(right: isActive ? 10 : 0, top: 3),
                decoration: BoxDecoration(
                  color: widget.activeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(child: Text(line.text)),
            ],
          ),
        ),
      ),
    );
  }
}