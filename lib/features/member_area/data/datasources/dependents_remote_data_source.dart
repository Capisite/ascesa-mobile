import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class DependentsRemoteDataSource {
  final Dio _dio;

  DependentsRemoteDataSource({required String token}) : _dio = Dio(
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
    _dio.interceptors.add(AuthInterceptor());
  }

  Future<List<dynamic>> getDependents() async {
    try {
      final response = await _dio.get(ApiConstants.dependentsEndpoint);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar dependentes');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> createDependent(Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiConstants.dependentsEndpoint, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao criar dependente');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> updateDependent(String id, Map<String, dynamic> data) async {
    try {
      await _dio.patch('${ApiConstants.dependentsEndpoint}/$id', data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao atualizar dependente');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> deleteDependent(String id) async {
    try {
      await _dio.delete('${ApiConstants.dependentsEndpoint}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao remover dependente');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}
