import 'package:flutter/material.dart';

/// Satu baris lirik yang sudah dipetakan ke penanda waktu lagu.
///
/// [start] dihitung dalam detik sejak audio mulai diputar.
class LyricLine {
  final double start;
  final String text;

  const LyricLine(this.start, this.text);

  Duration get startDuration =>
      Duration(milliseconds: (start * 1000).round());

  @override
  String toString() => '${start}s: $text';
}

/// Metadata satu lagu: identitas, aset yang dipakai, dan lirik berwaktu.
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;

  /// Path aset cover album (mis. `assets/covers/lany_you.jpg`).
  final String cover;

  /// Path aset audio (mis. `assets/audio/lany_you.m4a`).
  ///
  /// Berkas berisi lagu utuh, bukan cuplikan, sehingga lirik bisa mengikuti
  /// lagu dari awal sampai akhir.
  final String audio;

  /// Durasi audio dalam detik. Dipakai sebagai panjang trek sebelum pemutar
  /// melaporkan durasi aslinya, supaya progres tidak lagi dipatok 30 detik.
  final double durationSeconds;

  final List<LyricLine> lyrics;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.cover,
    required this.audio,
    this.durationSeconds = 0,
    this.lyrics = const [],
  });

  /// Menandai apakah lagu punya lirik berwaktu yang bisa diikuti.
  bool get hasTimedLyrics => lyrics.isNotEmpty;

  /// Inisial artis untuk avatar bulat di bagian "Artis populer".
  String get initial => artist.trim().isEmpty ? '?' : artist.trim()[0].toUpperCase();

  /// Warna gradien kartu, dipilih stabil dari nama artis supaya tiap artis
  /// punya nuansa yang konsisten tanpa perlu data warna manual.
  Color get accent {
    const palette = [
      Color(0xFF1DB954), Color(0xFF8E44AD), Color(0xFF2980B9),
      Color(0xFFE67E22), Color(0xFFE74C3C), Color(0xFF16A085),
      Color(0xFFD35400), Color(0xFF2C3E50),
    ];
    return palette[artist.hashCode.abs() % palette.length];
  }
}

/// Memetakan posisi pemutaran ke baris lirik yang sedang aktif.
class LyricTimeline {
  final List<LyricLine> lines;

  const LyricTimeline(this.lines);

  /// Indeks baris aktif pada [position]; -1 bila belum masuk baris pertama.
  int activeIndexAt(Duration position) {
    if (lines.isEmpty) return -1;
    final seconds = position.inMilliseconds / 1000.0;
    if (seconds < lines.first.start) return -1;
    for (int i = lines.length - 1; i >= 0; i--) {
      if (seconds >= lines[i].start) return i;
    }
    return -1;
  }
}
