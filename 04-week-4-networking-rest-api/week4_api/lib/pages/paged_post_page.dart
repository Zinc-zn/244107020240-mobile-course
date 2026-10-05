import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/paged_posts.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.position.pixels >= _controller.position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
    // load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pagedPostsProvider.notifier).loadNextPage();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pagedPostsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paged Posts')),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1, // +1 untuk footer
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: state.hasMore
                    ? const CircularProgressIndicator()
                    : const Text('Semua data termuat.'),
              ),
            );
          }
          final post = state.items[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.body),
          );
        },
      ),
    );
  }
}
