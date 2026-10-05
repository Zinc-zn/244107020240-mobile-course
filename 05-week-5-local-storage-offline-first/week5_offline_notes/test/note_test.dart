import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/remote/post.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/data/repositories/post_repository.dart';
import 'package:week5_offline_notes/data/sync.dart';
import 'package:week5_offline_notes/providers/note_providers.dart';
import 'package:week5_offline_notes/providers/offline_providers.dart';
import 'package:week5_offline_notes/providers/post_providers.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({List<Note> items = const [], this.throwError = false})
      : items = [...items],
        super(openDb: () => throw UnimplementedError());

  final List<Note> items;
  final bool throwError;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return items;
  }

  @override
  Future<int> countDirty() async => items.where((n) => n.dirty).length;

  @override
  Future<void> markAllSynced() async {
    for (var i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(dirty: false);
    }
  }
}

class FakePostRepository extends PostRepository {
  FakePostRepository({List<Post> cached = const [], this.failNetwork = false})
      : _cached = [...cached],
        super(dio: Dio(), openDb: () => throw UnimplementedError());

  final List<Post> _cached;
  final bool failNetwork;

  @override
  Future<List<Post>> readCachedPosts() async => _cached;

  @override
  Future<List<Post>> fetchAndCache() async {
    if (failNetwork) throw Exception('network down (simulasi)');
    return _cached;
  }
}

/// Memaksa keadaan offline secara deterministik tanpa menyentuh jaringan.
class AlwaysOffline extends ForceOfflineNotifier {
  @override
  bool build() => true;
}

Note _note(String title, {bool dirty = false, DateTime? at}) =>
    Note(title: title, updatedAt: at ?? DateTime(2026, 9, 18), dirty: dirty);

void main() {
  group('Model Note', () {
    test('fromMap aman terhadap field yang hilang', () {
      final note = Note.fromMap({'title': 'Belanja'});
      expect(note.title, 'Belanja');
      expect(note.body, '');
      expect(note.dirty, isFalse);
    });

    test('flag dirty bertahan pada serialisasi', () {
      final note = _note('a', dirty: true);
      final restored = Note.fromMap(note.toMap());
      expect(restored.dirty, isTrue);
      expect(restored.updatedAt, note.updatedAt);
    });
  });

  group('Provider dengan repository palsu', () {
    test('notesProvider sukses', () async {
      final container = ProviderContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(items: [_note('Tes')]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notes = await container.read(notesProvider.future);
      expect(notes.length, 1);
      expect(notes.first.title, 'Tes');
    });

    test('notesProvider error', () async {
      final container = ProviderContainer(
        // Riverpod 3 otomatis me-retry provider yang gagal; matikan agar
        // test error tidak menunggu lama.
        retry: (count, error) => null,
        overrides: [
          noteRepositoryProvider.overrideWithValue(
            FakeNoteRepository(throwError: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(notesProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Offline-first', () {
    test('syncNotes membersihkan semua catatan dirty', () async {
      final repo = FakeNoteRepository(items: [
        _note('a', dirty: true),
        _note('b', dirty: true),
        _note('c'),
      ]);
      final synced = await syncNotes(repo, latency: Duration.zero);
      expect(synced, 2);
      expect(await repo.countDirty(), 0);
    });

    test('syncNotes ditolak saat offline dan dirty tetap utuh', () async {
      final repo = FakeNoteRepository(items: [_note('a', dirty: true)]);
      await expectLater(
        syncNotes(repo, offline: true),
        throwsA(isA<OfflineException>()),
      );
      expect(await repo.countDirty(), 1);
    });

    test('resolveConflict memilih updatedAt terbaru', () {
      final local = _note('lokal', at: DateTime(2026, 9, 18, 10));
      final remote = _note('server', at: DateTime(2026, 9, 18, 11));
      expect(resolveConflict(local, remote).title, 'server');
      expect(resolveConflict(remote, local).title, 'server');
    });
  });

  group('Cache-first posts', () {
    test('postsProvider mengembalikan cache saat offline', () async {
      final container = ProviderContainer(
        overrides: [
          forceOfflineProvider.overrideWith(() => AlwaysOffline()),
          postRepositoryProvider.overrideWithValue(
            FakePostRepository(cached: [
              const Post(id: 1, title: 'cache 1', body: 'isi satu'),
              const Post(id: 2, title: 'cache 2', body: 'isi dua'),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final posts = await container.read(postsProvider.future);
      expect(posts.length, 2);
      expect(posts.first.title, 'cache 1');
    });

    test('postsProvider error saat offline tanpa cache', () async {
      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          forceOfflineProvider.overrideWith(() => AlwaysOffline()),
          postRepositoryProvider.overrideWithValue(FakePostRepository()),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(postsProvider.future),
        throwsA(isA<OfflineException>()),
      );
    });
  });
}
