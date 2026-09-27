import 'package:flutter_test/flutter_test.dart';
import 'package:song_lyrics_apps/data/song_catalog.dart';
import 'package:song_lyrics_apps/models/song.dart';

void main() {
  group('LyricTimeline', () {
    const t = LyricTimeline([
      LyricLine(10, 'bait satu'),
      LyricLine(35, 'bait dua'),
      LyricLine(60, 'bait tiga'),
    ]);

    test('tidak ada baris aktif sebelum bait pertama', () {
      expect(t.activeIndexAt(Duration.zero), -1);
      expect(t.activeIndexAt(const Duration(seconds: 9, milliseconds: 900)), -1);
    });

    test('bait pertama aktif tepat pada penanda waktunya', () {
      expect(t.activeIndexAt(const Duration(seconds: 10)), 0);
    });

    test('berpindah bait sesuai penanda waktu berikutnya', () {
      expect(t.activeIndexAt(const Duration(seconds: 34)), 0);
      expect(t.activeIndexAt(const Duration(seconds: 35)), 1);
      expect(t.activeIndexAt(const Duration(seconds: 90)), 2);
    });

    test('lirik kosong tidak menandai baris apa pun', () {
      expect(const LyricTimeline([]).activeIndexAt(const Duration(seconds: 5)), -1);
    });
  });

  group('katalog lagu', () {
    test('berisi sejumlah lagu dan id-nya unik', () {
      expect(kSongCatalog.length, greaterThanOrEqualTo(10));
      final ids = kSongCatalog.map((s) => s.id).toSet();
      expect(ids.length, kSongCatalog.length);
    });

    test('setiap lagu punya aset audio dan cover', () {
      for (final s in kSongCatalog) {
        expect(s.audio, startsWith('assets/audio/'), reason: s.id);
        expect(s.cover, startsWith('assets/covers/'), reason: s.id);
      }
    });

    test('lirik berwaktu tersusun naik dan tidak negatif', () {
      for (final s in kSongCatalog) {
        var last = -1.0;
        for (final l in s.lyrics) {
          expect(l.start, greaterThanOrEqualTo(0), reason: '${s.id}: ${l.text}');
          expect(l.start, greaterThanOrEqualTo(last),
              reason: '${s.id} tidak urut di ${l.text}');
          last = l.start;
        }
      }
    });

    test('lagu dengan lirik punya minimal beberapa baris', () {
      final withLyrics = kSongCatalog.where((s) => s.hasTimedLyrics);
      expect(withLyrics.length, greaterThanOrEqualTo(9));
      for (final s in withLyrics) {
        expect(s.lyrics.length, greaterThan(5), reason: s.id);
      }
    });
  });
}
