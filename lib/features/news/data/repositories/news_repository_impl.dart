import 'package:ascesa/features/news/data/datasources/news_remote_datasource.dart';
import 'package:ascesa/features/news/domain/entities/news.dart';
import 'package:ascesa/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<News>> getNews({int page = 1, int limit = 10}) async {
    return await remoteDataSource.getNews(page: page, limit: limit);
  }
}
