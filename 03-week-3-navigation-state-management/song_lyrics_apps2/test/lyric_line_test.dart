import 'package:flutter_test/flutter_test.dart';
import 'package:song_lyrics_apps/models/lyric_line.dart';

void main() {
  const t = LyricTimeline([
    LyricLine(Duration(seconds: 10), 'bait satu'),
    LyricLine(Duration(seconds: 35), 'bait dua'),
    LyricLine(Duration(seconds: 60), 'bait tiga'),
  ]);

  test('tidak ada baris aktif sebelum bait pertama', () {
    expect(t.activeIndexAt(Duration.zero), -1);
    expect(t.activeIndexAt(const Duration(seconds: 9, milliseconds: 999)), -1);
  });

  test('bait pertama aktif tepat saat penanda waktunya', () {
    expect(t.activeIndexAt(const Duration(seconds: 10)), 0);
  });

  test('berpindah ke bait berikutnya sesuai penanda waktu', () {
    expect(t.activeIndexAt(const Duration(seconds: 34)), 0);
    expect(t.activeIndexAt(const Duration(seconds: 35)), 1);
    expect(t.activeIndexAt(const Duration(seconds: 90)), 2);
  });

  test('deteksi baris pengiring dan penanda bagian', () {
    expect(LyricTimeline.isAdLib('(Without you, without you)'), isTrue);
    expect(LyricTimeline.isAdLib("You're the sun to the moon"), isFalse);
    expect(LyricTimeline.isHeader('Chorus'), isTrue);
    expect(LyricTimeline.isHeader("You're my ocean"), isFalse);
  });
}
