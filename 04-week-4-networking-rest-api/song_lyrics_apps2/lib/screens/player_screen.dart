import 'package:flutter/material.dart';

import '../models/song.dart';
import '../services/player_service.dart';
import '../widgets/song_cover.dart';
import '../widgets/spotify_lyrics.dart';
import 'home_screen.dart'
    show kBg, kGreen, kTextPrimary, kTextSecondary, formatDuration;

/// Layar pemutar lagu dengan lirik yang mengikuti jalannya lagu.
///
/// Lagu yang ditampilkan selalu diambil dari [PlayerService.current], bukan dari
/// parameter di konstruktor. Dengan begitu saat lagu berganti (lewat tombol
/// berikutnya/sebelumnya atau daftar lagu), cover, judul, lirik, dan durasi di
/// layar ini ikut berganti — hanya lagu pertama yang dipakai sebagai cadangan
/// sebelum pemutar siap.
///
/// Di layar lebar (web/desktop) tata letak dipecah dua kolom: cover dan kontrol
/// di kiri, lirik di kanan. Di layar sempit, semuanya ditumpuk vertikal dan
/// lirik mendapat sisa ruang. Susunan ini menghindari overflow pada jendela
/// web yang lebar dan pendek.
class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key, required this.player, required this.song});

  final PlayerService player;

  /// Lagu pembuka; digantikan oleh [PlayerService.current] saat pemutar aktif.
  final Song song;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: player,
      // Dengarkan PlayerService supaya lagu aktif selalu yang terbaru.
      builder: (context, _) {
        final current = player.current ?? song;
        final isWide = MediaQuery.of(context).size.width >= 860;
        return Scaffold(
          backgroundColor: kBg,
          appBar: AppBar(
            backgroundColor: kBg,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, color: kTextPrimary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('MEMUTAR DARI ALBUM',
                    style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(current.album.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: kTextPrimary),
                onPressed: () {},
              ),
            ],
          ),
          body: SafeArea(
            child: isWide
                ? _buildWide(context, current)
                : _buildNarrow(context, current),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------- lebar

  Widget _buildWide(BuildContext context, Song song) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 420,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 20, 12, 28),
            child: Column(
              children: [
                _CoverBlock(song: song),
                const SizedBox(height: 28),
                _TitleRow(player: player, song: song),
                const SizedBox(height: 18),
                _ProgressBar(player: player, song: song),
                const SizedBox(height: 18),
                _Controls(player: player),
              ],
            ),
          ),
        ),
        const VerticalDivider(color: Color(0xFF2A2A2A), width: 1),
        Expanded(child: _LyricsPane(player: player, song: song)),
      ],
    );
  }

  // -------------------------------------------------------------- sempit

  Widget _buildNarrow(BuildContext context, Song song) {
    // Tinggi cover dibatasi agar kontrol dan lirik tetap kebagian ruang pada
    // jendela pendek — mencegah overflow yang muncul di layar web.
    final screenH = MediaQuery.of(context).size.height;
    final coverSize = (screenH * 0.3).clamp(120.0, 300.0);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
          child: SizedBox(
            width: coverSize,
            height: coverSize,
            child: SongCover(song: song, radius: 10),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              _TitleRow(player: player, song: song),
              const SizedBox(height: 12),
              _ProgressBar(player: player, song: song, compact: true),
              const SizedBox(height: 8),
              _Controls(player: player, compact: true),
            ],
          ),
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 16),
        Expanded(child: _LyricsPane(player: player, song: song)),
      ],
    );
  }
}

class _CoverBlock extends StatelessWidget {
  const _CoverBlock({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: song.accent.withValues(alpha: 0.28),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SongCover(song: song, radius: 10, size: double.infinity),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.player, required this.song});

  final PlayerService player;
  final Song song;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                song.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kTextSecondary, fontSize: 15),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: kTextSecondary, size: 26),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.player,
    required this.song,
    this.compact = false,
  });

  final PlayerService player;
  final Song song;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // Durasi asli lagu dipakai selama pemutar belum melaporkan durasinya,
    // supaya panjang trek tidak lagi dipatok 30 detik.
    final fallback = Duration(milliseconds: (song.durationSeconds * 1000).round());
    final total = player.duration.inMilliseconds > 0 ? player.duration : fallback;
    final totalMs = total.inMilliseconds <= 0 ? 1 : total.inMilliseconds;
    final value = player.position.inMilliseconds.clamp(0, totalMs).toDouble();

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: compact ? 2 : 3,
            thumbShape:
                RoundSliderThumbShape(enabledThumbRadius: compact ? 5 : 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: kTextPrimary,
            inactiveTrackColor: const Color(0xFF4D4D4D),
            thumbColor: kTextPrimary,
          ),
          child: Slider(
            value: value,
            max: totalMs.toDouble(),
            onChanged: (v) =>
                player.seek(Duration(milliseconds: v.round())),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatDuration(player.position),
                  style: const TextStyle(color: kTextSecondary, fontSize: 11)),
              Text(formatDuration(total),
                  style: const TextStyle(color: kTextSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.player, this.compact = false});

  final PlayerService player;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final playSize = compact ? 56.0 : 64.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: 'Acak',
          onPressed: player.toggleShuffle,
          icon: Icon(Icons.shuffle,
              color: player.shuffle ? kGreen : kTextSecondary, size: 22),
        ),
        IconButton(
          tooltip: 'Sebelumnya',
          onPressed: player.previous,
          icon: const Icon(Icons.skip_previous_rounded,
              color: kTextPrimary, size: 36),
        ),
        GestureDetector(
          onTap: player.togglePlayPause,
          child: Container(
            width: playSize,
            height: playSize,
            decoration: const BoxDecoration(
              color: kTextPrimary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: playSize * 0.58,
              color: Colors.black,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Berikutnya',
          onPressed: player.next,
          icon: const Icon(Icons.skip_next_rounded,
              color: kTextPrimary, size: 36),
        ),
        IconButton(
          tooltip: 'Ulangi',
          onPressed: player.cycleRepeat,
          icon: Icon(
            player.repeatMode == 2 ? Icons.repeat_one : Icons.repeat,
            color: player.repeatMode > 0 ? kGreen : kTextSecondary,
            size: 22,
          ),
        ),
      ],
    );
  }
}

/// Panel lirik: menampilkan lirik berwaktu, atau pesan bila tidak ada lirik.
class _LyricsPane extends StatelessWidget {
  const _LyricsPane({required this.player, required this.song});

  final PlayerService player;
  final Song song;

  @override
  Widget build(BuildContext context) {
    if (!song.hasTimedLyrics) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_outlined, color: kTextSecondary, size: 44),
            SizedBox(height: 12),
            Text('Lirik belum tersedia untuk trek ini',
                style: TextStyle(color: kTextSecondary, fontSize: 15)),
            SizedBox(height: 4),
            Text('(instrumental)',
                style: TextStyle(color: Color(0xFF6A6A6A), fontSize: 13)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 10),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Lyrics',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '${song.lyrics.length} baris',
                style: const TextStyle(color: kTextSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: SpotifyLyrics(
            timeline: LyricTimeline(song.lyrics),
            position: player.position,
            activeColor: kGreen,
            onSeek: player.seek,
          ),
        ),
      ],
    );
  }
}