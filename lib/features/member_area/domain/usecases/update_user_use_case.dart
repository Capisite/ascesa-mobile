import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/member_area/data/datasources/user_remote_data_source.dart';

class UpdateUserUseCase {
  final UserRemoteDataSource dataSource;

  UpdateUserUseCase({required this.dataSource});

  Future<User> execute(User user, {String? profilePhotoPath}) async {
    final response = await dataSource.updateProfile(
      user.toJson(),
      profilePhotoPath: profilePhotoPath,
    );
    
    final userData = response['user'] ?? response;
    return User.fromJson(userData);
  }
}
