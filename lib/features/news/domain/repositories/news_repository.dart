import 'package:flutter_project/features/news/domain/entities/news.dart';

abstract class NewsRepository {
  Future<List<News>> getNews({int page = 1, int limit = 10});
}
