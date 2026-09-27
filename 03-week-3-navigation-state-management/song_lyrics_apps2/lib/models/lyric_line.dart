/// Satu baris lirik yang sudah dipetakan ke penanda waktu lagu.
///
/// [end] dihitung otomatis dari [start] baris berikutnya sehingga pemutaran
/// tidak perlu menyimpan dua nilai waktu untuk setiap baris.
class LyricLine {
  final Duration start;
  final String text;

  const LyricLine(this.start, this.text);

  LyricLine copyWith({Duration? start, String? text}) {
    return LyricLine(start ?? this.start, text ?? this.text);
  }

  @override
  String toString() => '${start.inMilliseconds}ms: $text';
}

/// Kumpulan baris lirik beserta helper untuk memetakan posisi pemutaran lagu
/// ke baris yang sedang aktif (mirip perilaku lirik di aplikasi Spotify).
class LyricTimeline {
  final List<LyricLine> lines;

  const LyricTimeline(this.lines);

  /// Indeks baris yang aktif pada [position]. Mengembalikan -1 sebelum baris
  /// pertama dimulai, sehingga UI bisa menampilkan seluruh lirik dalam keadaan
  /// redup (belum ada yang tersorot).
  int activeIndexAt(Duration position) {
    if (lines.isEmpty || position < lines.first.start) return -1;

    for (int i = lines.length - 1; i >= 0; i--) {
      if (position >= lines[i].start) return i;
    }
    return -1;
  }

  /// Baris yang mengandung emisi kata ("oh", "yeah", tanpa lirik) diredupkan
  /// lebih jauh karena biasanya hanya menjadi pengiring, bukan baris utama.
  static bool isAdLib(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.startsWith('(') && trimmed.endsWith(')')) return true;
    return trimmed == 'Yet' || trimmed == 'Oh' || trimmed == 'Yeah';
  }

  /// Salah satu baris "penanda bagian" (verse, chorus) yang di Spotify
  /// ditampilkan lebih redup dan tidak pernah menjadi baris aktif.
  static bool isHeader(String text) {
    const headers = {'Verse 1', 'Verse 2', 'Pre-Chorus', 'Chorus', 'Bridge'};
    return headers.contains(text.trim());
  }
}