import 'package:ascesa/features/auth/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.mobilePhone,
    super.businessPhone,
    required super.status,
    required super.associate,
    required super.roles,
    super.fatherName,
    super.motherName,
    super.zipCode,
    super.street,
    super.addressNumber,
    super.addressComplement,
    super.district,
    super.city,
    super.state,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      mobilePhone: json['mobilePhone'] as String?,
      businessPhone: json['businessPhone'] as String?,
      status: json['status'] as String? ?? '',
      associate: json['associate'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      zipCode: json['zipCode'] as String?,
      street: json['street'] as String?,
      addressNumber: json['addressNumber'] as String?,
      addressComplement: json['addressComplement'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'mobilePhone': mobilePhone,
      'businessPhone': businessPhone,
      'status': status,
      'associate': associate,
      'roles': roles,
      'fatherName': fatherName,
      'motherName': motherName,
      'zipCode': zipCode,
      'street': street,
      'addressNumber': addressNumber,
      'addressComplement': addressComplement,
      'district': district,
      'city': city,
      'state': state,
    };
  }
}
