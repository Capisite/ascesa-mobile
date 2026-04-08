import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/member_area/data/datasources/user_remote_data_source.dart';

class GetUserProfileUseCase {
  final UserRemoteDataSource dataSource;

  GetUserProfileUseCase({required this.dataSource});

  Future<User> execute() async {
    final data = await dataSource.getProfile();
    return User.fromJson(data);
  }
}
