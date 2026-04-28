import 'package:ascesa/features/blog/data/datasources/blog_remote_datasource.dart';
import 'package:ascesa/features/blog/domain/entities/blog_post.dart';
import 'package:ascesa/features/blog/domain/repositories/blog_repository.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource remoteDataSource;

  BlogRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<BlogPost>> getBlogs({int page = 1, int limit = 10}) async {
    return await remoteDataSource.getBlogs(page: page, limit: limit);
  }

  @override
  Future<BlogPost> getBlogBySlug(String slug) async {
    return await remoteDataSource.getBlogBySlug(slug);
  }
}
