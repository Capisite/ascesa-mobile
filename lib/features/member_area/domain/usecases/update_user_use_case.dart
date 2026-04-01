import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/member_area/data/datasources/user_remote_data_source.dart';

class UpdateUserUseCase {
  final UserRemoteDataSource dataSource;

  UpdateUserUseCase({required this.dataSource});

  Future<User> execute(User user) async {
    final response = await dataSource.updateProfile(user.toJson());
    
    // The API should return the updated user. We update our local entity.
    // Assuming the response body contains the updated user data.
    return user.copyWith(
      name: response['name'],
      email: response['email'],
      phone: response['phone'],
      fatherName: response['fatherName'],
      motherName: response['motherName'],
    );
  }
}
