import 'package:dio/dio.dart';
import 'package:flutter_project/core/constants/api_constants.dart';
import 'package:flutter_project/features/news/data/models/news_model.dart';

class NewsRemoteDataSource {
  final Dio _dio;

  NewsRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<List<NewsModel>> getNews({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.newsEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> newsJson = response.data['news'];
      return newsJson.map((json) => NewsModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar notícias');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
