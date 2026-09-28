import 'package:flutter/material.dart';

import '../models/song.dart';

/// Cover album dengan sudut membulat dan cadangan bila aset gagal dimuat.
class SongCover extends StatelessWidget {
  const SongCover({
    super.key,
    required this.song,
    this.radius = 8,
    this.size,
    this.showShadow = true,
  });

  final Song song;
  final double radius;
  final double? size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        song.cover,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: size,
          height: size,
          color: song.accent.withValues(alpha: 0.35),
          child: const Icon(Icons.music_note, color: Colors.white70, size: 36),
        ),
      ),
    );

    if (!showShadow) return image;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: image,
    );
  }
}

/// Avatar bulat artis berisi inisial, dipakai di bagian "Artis populer".
class ArtistAvatar extends StatelessWidget {
  const ArtistAvatar({super.key, required this.song, this.size = 120});

  final Song song;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [song.accent, song.accent.withValues(alpha: 0.45)],
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        song.initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}