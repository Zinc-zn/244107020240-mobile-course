import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/data/repositories/post_repository.dart';
import 'package:week4_api/data/providers.dart';
import 'package:week4_api/models/post.dart';

class FakePostRepository extends PostRepository {
  FakePostRepository({this.items, this.throwError = false}) : super(Dio());
  final List<Post>? items;
  final bool throwError;

  @override
  Future<List<Post>> fetchPosts() async {
    if (throwError) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts'),
        type: DioExceptionType.connectionError,
      );
    }
    return items ?? const [];
  }
}

void main() {
  test('FakePostRepository test', () async {
    final container = ProviderContainer(
      overrides: [
        postRepositoryProvider.overrideWithValue(FakePostRepository(throwError: true))
      ],
    );
    
    // Add some test logic to clear out warnings
    expect(container.read(postRepositoryProvider), isA<FakePostRepository>());
  });
}
