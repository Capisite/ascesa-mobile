import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';
import 'package:ascesa/features/assembly/data/models/available_votings_model.dart';

class AssemblyRemoteDataSource {
  final Dio _dio;
  final String token;

  AssemblyRemoteDataSource({Dio? dio, required this.token}) : _dio = dio ?? Dio(
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

  Future<AvailableVotingsModel> getAvailableVotings() async {
    try {
      final response = await _dio.get('/assembly/votings/available');
      return AvailableVotingsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar votações');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> voteOrdinaryAgendaItem(String assemblyId, String agendaItemId, String decision) async {
    try {
      await _dio.post(
        '/assembly/ordinary/$assemblyId/agenda-items/$agendaItemId/vote',
        data: {'decision': decision},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao votar');
    }
  }

  Future<void> voteExtraordinaryAgendaItem(String assemblyId, String agendaItemId, String decision) async {
    try {
      await _dio.post(
        '/assembly/extraordinary/$assemblyId/agenda-items/$agendaItemId/vote',
        data: {'decision': decision},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao votar');
    }
  }

  Future<void> voteExtraordinarySlate(String assemblyId, String slateId) async {
    try {
      await _dio.post(
        '/assembly/extraordinary/$assemblyId/slates/$slateId/vote',
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao votar');
    }
  }
}
