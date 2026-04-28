import 'package:ascesa/features/blog/domain/entities/blog_post.dart';

abstract class BlogRepository {
  Future<List<BlogPost>> getBlogs({int page = 1, int limit = 10});
  Future<BlogPost> getBlogBySlug(String slug);
}
