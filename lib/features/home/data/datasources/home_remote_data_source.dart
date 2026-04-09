import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/home/data/models/category_model.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class HomeRemoteDataSource {
  final Dio _dio;

  final String? token;

  HomeRemoteDataSource({Dio? dio, this.token}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ),
  ) {
    if (dio == null) {
      _dio.interceptors.add(AuthInterceptor());
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categoriesEndpoint);
      if (response.data is List) {
        return (response.data as List)
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      }
      throw Exception('Resposta inesperada do servidor');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar categorias');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
