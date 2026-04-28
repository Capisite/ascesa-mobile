import 'package:ascesa/features/blog/domain/entities/blog_post.dart';
import 'package:ascesa/features/blog/domain/repositories/blog_repository.dart';

class GetBlogs {
  final BlogRepository repository;

  GetBlogs(this.repository);

  Future<List<BlogPost>> call({int page = 1, int limit = 10}) async {
    return await repository.getBlogs(page: page, limit: limit);
  }
}
