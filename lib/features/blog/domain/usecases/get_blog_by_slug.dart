import 'package:ascesa/features/blog/domain/entities/blog_post.dart';
import 'package:ascesa/features/blog/domain/repositories/blog_repository.dart';

class GetBlogBySlug {
  final BlogRepository repository;

  GetBlogBySlug(this.repository);

  Future<BlogPost> call(String slug) async {
    return await repository.getBlogBySlug(slug);
  }
}
