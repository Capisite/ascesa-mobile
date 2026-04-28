import 'package:dio/dio.dart';
import 'package:ascesa/core/constants/api_constants.dart';
import 'package:ascesa/features/benefits/data/models/partner_model.dart';
import 'package:ascesa/features/benefits/data/models/partner_catalog_page_model.dart';
import 'package:ascesa/core/network/auth_interceptor.dart';

class BenefitsRemoteDataSource {
  final Dio _dio;
  final String? token;

  BenefitsRemoteDataSource({Dio? dio, this.token}) : _dio = dio ?? Dio(
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

  Future<PartnerCatalogPageModel> getPartnersCatalog({
    String? name,
    String? categoryId,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;

      final response = await _dio.get(
        ApiConstants.publicInfoEndpoint,
        queryParameters: queryParams,
      );

      return PartnerCatalogPageModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar parceiros');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<List<PartnerModel>> getMapPartners({
    String? name,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;

      final response = await _dio.get(
        ApiConstants.publicInfoMapEndpoint,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map<PartnerModel>((json) => PartnerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Resposta inesperada do servidor para mapa');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erro ao buscar parceiros no mapa');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Obtém a URL de acesso autenticado para um parceiro.
  /// Equivalente ao accessAllyaPartner do front-end web.
  Future<Map<String, dynamic>> getPartnerAccess(
    String partnerId, {
    required bool hasPortalSessionHint,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.partnerAccessEndpoint(partnerId),
        data: {'hasPortalSessionHint': hasPortalSessionHint},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Não foi possível abrir o convênio agora.',
      );
    } catch (e) {
      throw Exception('Não foi possível abrir o convênio agora.');
    }
  }
}
