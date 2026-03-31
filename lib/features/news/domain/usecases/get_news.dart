import 'package:flutter_project/features/news/domain/entities/news.dart';
import 'package:flutter_project/features/news/domain/repositories/news_repository.dart';

class GetNews {
  final NewsRepository repository;

  GetNews(this.repository);

  Future<List<News>> call({int page = 1, int limit = 10}) async {
    return await repository.getNews(page: page, limit: limit);
  }
}
