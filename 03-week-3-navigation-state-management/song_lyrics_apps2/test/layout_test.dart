import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:song_lyrics_apps/data/song_catalog.dart';
import 'package:song_lyrics_apps/screens/home_screen.dart';
import 'package:song_lyrics_apps/screens/player_screen.dart';
import 'package:song_lyrics_apps/services/player_service.dart';

/// Ukuran jendela yang diuji: layar web lebar (seperti tangkapan layar error)
/// dan layar ponsel sempit. Keduanya tidak boleh melaporkan overflow.
const _sizes = <String, Size>{
  'web lebar 1366x713': Size(1366, 713),
  'web sedang 1024x600': Size(1024, 600),
  'web pendek 1280x520': Size(1280, 520),
  'ponsel 390x844': Size(390, 844),
  'ponsel pendek 360x560': Size(360, 560),
};

void _useSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('layar pemutar', () {
    for (final entry in _sizes.entries) {
      testWidgets('tidak overflow di ${entry.key}', (tester) async {
        _useSize(tester, entry.value);

        final service = PlayerService();
        addTearDown(service.dispose);

        final song = kSongCatalog.firstWhere((s) => s.hasTimedLyrics);
        await tester.pumpWidget(
          MaterialApp(home: PlayerScreen(player: service, song: song)),
        );
        await tester.pumpAndSettle();

        // Overflow akan tercatat sebagai exception oleh kerangka uji.
        expect(tester.takeException(), isNull);
        expect(find.text('Lyrics'), findsOneWidget);
      });
    }
  });

  group('beranda', () {
    for (final entry in _sizes.entries) {
      testWidgets('tidak overflow di ${entry.key}', (tester) async {
        _useSize(tester, entry.value);

        final service = PlayerService();
        addTearDown(service.dispose);

        await tester.pumpWidget(MaterialApp(home: HomeScreen(player: service)));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
