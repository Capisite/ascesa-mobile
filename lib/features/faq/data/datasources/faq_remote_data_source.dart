import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/faq/data/models/faq_model.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class FaqRemoteDataSource {
  final Dio _dio;

  FaqRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio(
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

  Future<List<FaqModel>> getFaqs() async {
    try {
      final response = await _dio.get(ApiConstants.faqEndpoint);
      final List<dynamic> faqsJson = response.data;
      return faqsJson.map((json) => FaqModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar FAQs');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
