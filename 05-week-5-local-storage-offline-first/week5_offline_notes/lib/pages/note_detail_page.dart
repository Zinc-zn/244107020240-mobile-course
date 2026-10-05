import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/note.dart';
import '../providers/note_providers.dart';
import '../widgets/note_form_dialog.dart';
import 'notes_page.dart';

/// Provider keluarga (family) yang membaca catatan langsung dari
/// repository lokal berdasarkan id — bukan dari state halaman list.
final noteByIdProvider = FutureProvider.family<Note?, int>(
  (ref, id) => ref.watch(noteRepositoryProvider).getNoteById(id),
);

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'notes',
      builder: (context, state) => const NotesPage(),
      routes: [
        GoRoute(
          path: 'note/:id',
          name: 'note-detail',
          builder: (context, state) => NoteDetailPage(
            id: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    ),
  ],
);

/// Halaman detail: membaca catatan via [noteByIdProvider] sehingga
/// selalu valid meski rute dibuka langsung (deep link) tanpa lewat list.
class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteAsync = ref.watch(noteByIdProvider(id));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail catatan')),
      body: noteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Gagal membaca catatan: $e',
                textAlign: TextAlign.center),
          ),
        ),
        data: (note) {
          if (note == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 48),
                  const SizedBox(height: 12),
                  const Text('Catatan tidak ditemukan.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Kembali ke daftar'),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                note.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Terakhir diubah: ${_formatDate(note.updatedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Chip(
                avatar: Icon(
                  note.dirty ? Icons.cloud_off : Icons.cloud_done,
                  size: 16,
                  color: note.dirty ? Colors.orange : Colors.green,
                ),
                label: Text(note.dirty
                    ? 'Belum tersinkron ke server'
                    : 'Tersinkron'),
                visualDensity: VisualDensity.compact,
              ),
              const Divider(height: 24),
              Text(
                note.body.isEmpty ? '(tanpa isi)' : note.body,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Ubah catatan'),
                onPressed: () async {
                  final result = await showDialog<NoteFormResult>(
                    context: context,
                    builder: (_) => NoteFormDialog(initial: note),
                  );
                  if (result == null) return;
                  await ref.read(noteActionsProvider).update(
                        note.copyWith(title: result.title, body: result.body),
                      );
                  ref.invalidate(noteByIdProvider);
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus catatan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                ),
                onPressed: () async {
                  final navigator = GoRouter.of(context);
                  await ref.read(noteActionsProvider).delete(note.id!);
                  navigator.go('/');
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}
