import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_lyrics_apps/data/song_catalog.dart';
import 'package:song_lyrics_apps/main.dart';
import 'package:song_lyrics_apps/screens/player_screen.dart';
import 'package:song_lyrics_apps/services/player_service.dart';

void main() {
  testWidgets('beranda menampilkan pencarian, trending, dan artis populer',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Apa yang ingin kamu putar?'), findsOneWidget);
    expect(find.text('Lagu trending'), findsOneWidget);
    expect(find.text('you!'), findsWidgets);

    // Bagian artis populer berada di bawah layar uji, jadi digulir dulu.
    await tester.dragUntilVisible(
      find.text('Artis populer'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Artis populer'), findsOneWidget);
  });

  testWidgets('mencari lagu menyaring daftar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'malibu');
    await tester.pumpAndSettle();

    expect(find.textContaining('Hasil untuk pencarianmu'), findsOneWidget);
    expect(find.text('Malibu Nights'), findsWidgets);
    // Lagu yang tidak cocok tidak ikut tampil.
    expect(find.text('Dinda'), findsNothing);
  });

  testWidgets('layar pemutar menampilkan panel lirik untuk lagu berlirik',
      (WidgetTester tester) async {
    final service = PlayerService();
    addTearDown(service.dispose);

    final song = kSongCatalog.firstWhere((s) => s.hasTimedLyrics);
    await tester.pumpWidget(
      MaterialApp(home: PlayerScreen(player: service, song: song)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lyrics'), findsOneWidget);
    expect(find.text(song.title), findsWidgets);
  });

  testWidgets('layar pemutar menampilkan pesan instrumental tanpa lirik',
      (WidgetTester tester) async {
    final service = PlayerService();
    addTearDown(service.dispose);

    final song = kSongCatalog.firstWhere((s) => !s.hasTimedLyrics);
    await tester.pumpWidget(
      MaterialApp(home: PlayerScreen(player: service, song: song)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Lirik belum tersedia'), findsOneWidget);
  });
}
