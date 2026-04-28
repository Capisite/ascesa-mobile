import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/blog/data/models/blog_post_model.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class BlogRemoteDataSource {
  final Dio _dio;
  final String token;

  BlogRemoteDataSource({Dio? dio, required this.token}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ),
  ) {
    if (dio == null) {
      _dio.interceptors.add(AuthInterceptor());
    }
  }

  Future<List<BlogPostModel>> getBlogs({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiConstants.blogEndpoint,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> blogsJson = response.data['blogs'];
      return blogsJson.map((json) => BlogPostModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar blogs');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<BlogPostModel> getBlogBySlug(String slug) async {
    try {
      final response = await _dio.get('${ApiConstants.blogEndpoint}/$slug');
      return BlogPostModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar detalhe do blog');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
