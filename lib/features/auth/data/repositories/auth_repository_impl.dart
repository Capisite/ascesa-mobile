import 'package:ascesa/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ascesa/features/auth/data/models/auth_token_model.dart';
import 'package:ascesa/features/auth/data/models/login_request_model.dart';
import 'package:ascesa/features/auth/domain/entities/auth_token.dart';
import 'package:ascesa/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AuthToken> login(String email, String password) async {
    final loginRequest = LoginRequestModel(email: email, password: password);
    final response = await remoteDataSource.login(loginRequest.toJson());
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthTokenModel.fromJson(response.data);
    } else {
      throw Exception('Falha na autenticação');
    }
  }
}
