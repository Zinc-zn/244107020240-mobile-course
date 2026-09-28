import 'package:flutter/material.dart';

import '../data/song_catalog.dart';
import '../models/song.dart';
import '../services/player_service.dart';
import '../widgets/song_cover.dart';
import 'player_screen.dart';

const Color kBg = Color(0xFF121212);
const Color kSurface = Color(0xFF181818);
const Color kElevated = Color(0xFF242424);
const Color kGreen = Color(0xFF1DB954);
const Color kTextPrimary = Color(0xFFFFFFFF);
const Color kTextSecondary = Color(0xFFB3B3B3);

/// Format durasi menjadi `m:ss`, dipakai di daftar lagu dan mini player.
String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(1, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Beranda bergaya Spotify: pencarian, lagu trending, dan artis populer.
///
/// Saat sebuah cover ditekan, lagu langsung diputar dan layar pemutar dibuka —
/// lirik di layar itu otomatis mengikuti jalannya lagu.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.player});

  final PlayerService player;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Song> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return kSongCatalog
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.artist.toLowerCase().contains(q) ||
            s.album.toLowerCase().contains(q))
        .toList();
  }

  /// Artis unik beserta satu lagu representatif untuk avatar.
  List<Song> get _artists {
    final seen = <String>{};
    final out = <Song>[];
    for (final s in kSongCatalog) {
      if (seen.add(s.artist)) out.add(s);
    }
    return out;
  }

  Future<void> _openPlayer(Song song) async {
    await widget.player.playSong(song);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerScreen(player: widget.player, song: song),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: AnimatedBuilder(
        animation: widget.player,
        builder: (context, _) => Column(
          children: [
            _TopBar(
              controller: _search,
              focusNode: _searchFocus,
              onChanged: (v) => setState(() => _query = v),
            ),
            Expanded(
              child: _query.trim().isEmpty
                  ? _BrowseView(
                      artists: _artists,
                      onOpen: _openPlayer,
                      player: widget.player,
                    )
                  : _SearchResults(
                      songs: _results,
                      onOpen: _openPlayer,
                      player: widget.player,
                    ),
            ),
            if (widget.player.hasSong)
              _MiniPlayer(
                player: widget.player,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlayerScreen(
                      player: widget.player,
                      song: widget.player.current!,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Bar ala situs web Spotify: logo, kolom pencarian, dan tombol masuk.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.graphic_eq, color: kTextPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                style: const TextStyle(color: kTextPrimary, fontSize: 15),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Apa yang ingin kamu putar?',
                  hintStyle: const TextStyle(color: kTextSecondary),
                  prefixIcon: const Icon(Icons.search, color: kTextSecondary),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close, color: kTextSecondary),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        ),
                  filled: true,
                  fillColor: kElevated,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol "Masuk" hanya tampil di layar lebar, seperti versi web.
          if (MediaQuery.of(context).size.width > 720) ...[
            TextButton(
              onPressed: () {},
              child: const Text('Daftar',
                  style: TextStyle(color: kTextSecondary, fontSize: 15)),
            ),
            const SizedBox(width: 4),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kTextPrimary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              ),
              child: const Text('Masuk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tampilan jelajah: kartu "Buat playlist", lagu trending, dan artis populer.
class _BrowseView extends StatelessWidget {
  const _BrowseView({
    required this.artists,
    required this.onOpen,
    required this.player,
  });

  final List<Song> artists;
  final ValueChanged<Song> onOpen;
  final PlayerService player;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardCols = width > 1100 ? 5 : (width > 820 ? 4 : (width > 560 ? 3 : 2));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const _PromoCard(),
        const SizedBox(height: 28),
        _SectionHeader(
          title: 'Lagu trending',
          action: 'Tampilkan semua',
          onAction: () {},
        ),
        const SizedBox(height: 14),
        _SongCardGrid(
          songs: kSongCatalog.take(10).toList(),
          cols: cardCols,
          onOpen: onOpen,
          player: player,
        ),
        const SizedBox(height: 32),
        _SectionHeader(
          title: 'Artis populer',
          action: 'Tampilkan semua',
          onAction: () {},
        ),
        const SizedBox(height: 14),
        _ArtistRow(artists: artists.take(8).toList(), onOpen: onOpen),
        const SizedBox(height: 32),
        _SectionHeader(title: 'Semua lagu', action: null, onAction: () {}),
        const SizedBox(height: 8),
        _SongTable(songs: kSongCatalog, onOpen: onOpen, player: player),
      ],
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Expanded(
                child: Text(
                  'Koleksi Kamu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline,
                    color: kTextSecondary, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat playlist pertamamu',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Caranya mudah, kami akan membantumu',
            style: TextStyle(color: kTextSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kTextPrimary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            ),
            child: const Text('Buat playlist',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onAction,
    this.action,
  });

  final String title;
  final String? action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: const Text('Tampilkan semua',
                style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

/// Baris kartu lagu yang bisa digulir horizontal, seperti Spotify web.
class _SongCardGrid extends StatelessWidget {
  const _SongCardGrid({
    required this.songs,
    required this.cols,
    required this.onOpen,
    required this.player,
  });

  final List<Song> songs;
  final int cols;
  final ValueChanged<Song> onOpen;
  final PlayerService player;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - (cols - 1) * 16) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 20,
          children: [
            for (final s in songs)
              SizedBox(
                width: cardWidth,
                child: _SongCard(
                  song: s,
                  player: player,
                  onTap: () => onOpen(s),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.song,
    required this.player,
    required this.onTap,
  });

  final Song song;
  final PlayerService player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCurrent = player.current?.id == song.id;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: SongCover(song: song, radius: 6, size: double.infinity),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _PlayBadge(
                    active: isCurrent && player.playing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCurrent ? kGreen : kTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              song.artist,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kTextSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: kGreen,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8),
        ],
      ),
      child: Icon(
        active ? Icons.pause : Icons.play_arrow_rounded,
        color: Colors.black,
        size: 26,
      ),
    );
  }
}

/// Daftar artis populer dengan avatar bulat.
class _ArtistRow extends StatelessWidget {
  const _ArtistRow({required this.artists, required this.onOpen});

  final List<Song> artists;
  final ValueChanged<Song> onOpen;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, i) {
          final a = artists[i];
          return SizedBox(
            width: 150,
            child: InkWell(
              onTap: () => onOpen(a),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    ArtistAvatar(song: a, size: 120),
                    const SizedBox(height: 12),
                    Text(
                      a.artist,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tabel daftar lagu bernomor seperti daftar putar Spotify.
class _SongTable extends StatelessWidget {
  const _SongTable({
    required this.songs,
    required this.onOpen,
    required this.player,
  });

  final List<Song> songs;
  final ValueChanged<Song> onOpen;
  final PlayerService player;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 40, child: Text('#', style: _headStyle)),
              const Expanded(child: Text('Judul', style: _headStyle)),
              if (wide) const Expanded(child: Text('Album', style: _headStyle)),
              const Icon(Icons.schedule, color: kTextSecondary, size: 16),
            ],
          ),
        ),
        const Divider(color: Color(0xFF2A2A2A), height: 1),
        for (int i = 0; i < songs.length; i++)
          _SongRow(
            index: i + 1,
            song: songs[i],
            wide: wide,
            player: player,
            onTap: () => onOpen(songs[i]),
          ),
      ],
    );
  }

  static const _headStyle = TextStyle(
    color: kTextSecondary,
    fontSize: 12,
    letterSpacing: 1,
    fontWeight: FontWeight.w600,
  );
}

class _SongRow extends StatelessWidget {
  const _SongRow({
    required this.index,
    required this.song,
    required this.wide,
    required this.player,
    required this.onTap,
  });

  final int index;
  final Song song;
  final bool wide;
  final PlayerService player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCurrent = player.current?.id == song.id;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: isCurrent
                  ? const Icon(Icons.volume_up, color: kGreen, size: 18)
                  : Text('$index',
                      style: const TextStyle(
                          color: kTextSecondary, fontSize: 14)),
            ),
            SongCover(song: song, radius: 4, size: 40, showShadow: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? kGreen : kTextPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: kTextSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (wide)
              Expanded(
                child: Text(
                  song.album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTextSecondary, fontSize: 13),
                ),
              ),
            const SizedBox(width: 12),
            Text(formatDuration(Duration(milliseconds: (song.durationSeconds * 1000).round())),
                style: const TextStyle(color: kTextSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

/// Hasil pencarian lagu.
class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.songs,
    required this.onOpen,
    required this.player,
  });

  final List<Song> songs;
  final ValueChanged<Song> onOpen;
  final PlayerService player;

  @override
  Widget build(BuildContext context) {
    if (songs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: kTextSecondary, size: 48),
            SizedBox(height: 12),
            Text('Lagu tidak ditemukan',
                style: TextStyle(color: kTextSecondary, fontSize: 16)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Hasil untuk pencarianmu (${songs.length})',
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: _SongTable(songs: songs, onOpen: onOpen, player: player),
        ),
      ],
    );
  }
}

/// Mini player menempel di bawah, seperti Spotify.
class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({required this.player, required this.onTap});

  final PlayerService player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final song = player.current!;
    final wide = MediaQuery.of(context).size.width > 480;
    // Panjang trek memakai durasi asli lagu; pemutar mengisinya begitu audio
    // siap. Ini menggantikan nilai tetap 30 detik sebelumnya.
    final total = player.duration.inMilliseconds > 0
        ? player.duration
        : Duration(milliseconds: (song.durationSeconds * 1000).round());
    final totalMs = total.inMilliseconds <= 0 ? 1 : total.inMilliseconds;
    final progress =
        (player.position.inMilliseconds / totalMs).clamp(0.0, 1.0);

    return Material(
      color: kSurface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  SongCover(song: song, radius: 4, size: 46, showShadow: false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: kTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: kTextSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: player.togglePlayPause,
                    icon: Icon(
                      player.playing
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: kTextPrimary,
                      size: 38,
                    ),
                  ),
                  // Tombol lagu berikutnya dan waktu hanya muat di layar lebar;
                  // di layar sempit disembunyikan supaya baris tidak meluber.
                  if (wide) ...[
                    IconButton(
                      onPressed: player.next,
                      icon: const Icon(Icons.skip_next,
                          color: kTextPrimary, size: 26),
                    ),
                    Text('${formatDuration(player.position)} / ${formatDuration(total)}',
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 12)),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: const Color(0xFF3E3E3E),
                  valueColor: const AlwaysStoppedAnimation(kGreen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}