import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/vitrine/data/models/vitrine_item_model.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class VitrineRemoteDataSource {
  final Dio _dio;

  VitrineRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ) {
    if (dio == null) {
      _dio.interceptors.add(AuthInterceptor());
    }
  }

  Future<List<VitrineItemModel>> getVitrineItems({int page = 1, int limit = 12}) async {
    try {
      final response = await _dio.get(
        ApiConstants.vitrineEndpoint,
        queryParameters: {'page': page, 'limit': limit},
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
