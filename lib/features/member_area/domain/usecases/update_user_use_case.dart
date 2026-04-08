import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/member_area/data/datasources/user_remote_data_source.dart';

class UpdateUserUseCase {
  final UserRemoteDataSource dataSource;

  UpdateUserUseCase({required this.dataSource});

  Future<User> execute(User user) async {
    final response = await dataSource.updateProfile(user.toJson());

    // The backend wraps the updated user in a 'user' key
    final userData = response['user'] ?? response;

    return user.copyWith(
      name: userData['name'],
      email: userData['email'],
      phone: userData['phone'],
      mobilePhone: userData['mobilePhone'],
      businessPhone: userData['businessPhone'],
      fatherName: userData['fatherName'],
      motherName: userData['motherName'],
      zipCode: userData['zipCode'],
      street: userData['street'],
      addressNumber: userData['addressNumber'],
      addressComplement: userData['addressComplement'],
      district: userData['district'],
      city: userData['city'],
      state: userData['state'],
    );
  }
}
