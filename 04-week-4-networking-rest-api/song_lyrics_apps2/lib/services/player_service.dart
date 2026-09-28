import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/song_catalog.dart';
import '../models/song.dart';

/// Status pemutaran yang dipakai bersama oleh beranda dan layar pemutar.
///
/// Dibuat sebagai [ChangeNotifier] supaya kartu lagu di beranda, mini player,
/// dan lembar lirik selalu menampilkan lagu serta posisi yang sama.
class PlayerService extends ChangeNotifier {
  PlayerService() {
    _player.onPlayerStateChanged.listen((state) {
      _playing = state == PlayerState.playing;
      notifyListeners();
    });
    _player.onPositionChanged.listen((p) {
      _position = p;
      notifyListeners();
    });
    _player.onDurationChanged.listen((d) {
      _duration = d;
      notifyListeners();
    });
    _player.onPlayerComplete.listen((_) => _handleComplete());
  }

  final AudioPlayer _player = AudioPlayer();

  Song? _current;
  bool _playing = false;
  bool _shuffle = false;
  int _repeatMode = 0; // 0 = mati, 1 = ulangi semua, 2 = ulangi satu
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  Song? get current => _current;
  bool get playing => _playing;
  bool get shuffle => _shuffle;
  int get repeatMode => _repeatMode;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get hasSong => _current != null;

  /// Ubah `assets/audio/x.m4a` menjadi `audio/x.m4a`, karena [AssetSource]
  /// sudah menambahkan prefiks `assets/` sendiri.
  static String _assetKey(String path) =>
      path.startsWith('assets/') ? path.substring('assets/'.length) : path;

  /// Memutar [song] dari awal dan menjadikannya lagu aktif.
  Future<void> playSong(Song song) async {
    _current = song;
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
    await _player.stop();
    await _player.play(AssetSource(_assetKey(song.audio)));
  }

  Future<void> togglePlayPause() async {
    if (_current == null) return;
    if (_playing) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> seek(Duration target) async {
    await _player.seek(target);
    _position = target;
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void cycleRepeat() {
    _repeatMode = (_repeatMode + 1) % 3;
    notifyListeners();
  }

  int get _currentIndex {
    final song = _current;
    if (song == null) return -1;
    return kSongCatalog.indexWhere((s) => s.id == song.id);
  }

  /// Lagu berikutnya, menghormati mode shuffle dan repeat.
  Future<void> next() async {
    if (kSongCatalog.isEmpty) return;
    if (_repeatMode == 2) {
      await _player.seek(Duration.zero);
      await _player.resume();
      return;
    }
    final i = _currentIndex;
    if (i < 0) return;
    final nextIndex = _shuffle
        ? (i + 1 + DateTime.now().microsecond % (kSongCatalog.length - 1)) %
            kSongCatalog.length
        : (i + 1) % kSongCatalog.length;
    await playSong(kSongCatalog[nextIndex]);
  }

  /// Lagu sebelumnya.
  Future<void> previous() async {
    if (kSongCatalog.isEmpty) return;
    final i = _currentIndex;
    if (i < 0) return;
    final prevIndex = (i - 1 + kSongCatalog.length) % kSongCatalog.length;
    await playSong(kSongCatalog[prevIndex]);
  }

  Future<void> _handleComplete() async {
    if (_repeatMode == 2) {
      await _player.seek(Duration.zero);
      await _player.resume();
      return;
    }
    if (_repeatMode == 1 || _currentIndex < kSongCatalog.length - 1) {
      await next();
    } else {
      _playing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}