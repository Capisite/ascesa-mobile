import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/vitrine/data/models/vitrine_item_model.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class VitrineRemoteDataSource {
  final Dio _dio;
  final String token;

  VitrineRemoteDataSource({Dio? dio, required this.token}) : _dio = dio ?? Dio(
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

  Future<List<VitrineItemModel>> getVitrineItems({int page = 1, int limit = 12, String? category}) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
      };
      
      final response = await _dio.get(
        ApiConstants.vitrineEndpoint,
        queryParameters: queryParams,
      );
      
      final List<dynamic> itemsJson = response.data['items'];
      return itemsJson.map((json) => VitrineItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar vitrine');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
