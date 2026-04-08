class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? mobilePhone;
  final String? businessPhone;
  final String status;
  final bool associate;
  final List<String> roles;
  final String? fatherName;
  final String? motherName;
  // Address fields
  final String? zipCode;
  final String? street;
  final String? addressNumber;
  final String? addressComplement;
  final String? district;
  final String? city;
  final String? state;
  final String? maritalStatus;
  final String? gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.mobilePhone,
    this.businessPhone,
    required this.status,
    required this.associate,
    required this.roles,
    this.fatherName,
    this.motherName,
    this.zipCode,
    this.street,
    this.addressNumber,
    this.addressComplement,
    this.district,
    this.city,
    this.state,
    this.maritalStatus,
    this.gender,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? mobilePhone,
    String? businessPhone,
    String? status,
    bool? associate,
    List<String>? roles,
    Object? fatherName = _sentinel,
    Object? motherName = _sentinel,
    Object? zipCode = _sentinel,
    Object? street = _sentinel,
    Object? addressNumber = _sentinel,
    Object? addressComplement = _sentinel,
    Object? district = _sentinel,
    Object? city = _sentinel,
    Object? state = _sentinel,
    Object? maritalStatus = _sentinel,
    Object? gender = _sentinel,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      businessPhone: businessPhone ?? this.businessPhone,
      status: status ?? this.status,
      associate: associate ?? this.associate,
      roles: roles ?? this.roles,
      fatherName: fatherName == _sentinel ? this.fatherName : fatherName as String?,
      motherName: motherName == _sentinel ? this.motherName : motherName as String?,
      zipCode: zipCode == _sentinel ? this.zipCode : zipCode as String?,
      street: street == _sentinel ? this.street : street as String?,
      addressNumber: addressNumber == _sentinel ? this.addressNumber : addressNumber as String?,
      addressComplement: addressComplement == _sentinel ? this.addressComplement : addressComplement as String?,
      district: district == _sentinel ? this.district : district as String?,
      city: city == _sentinel ? this.city : city as String?,
      state: state == _sentinel ? this.state : state as String?,
      maritalStatus: maritalStatus == _sentinel ? this.maritalStatus : maritalStatus as String?,
      gender: gender == _sentinel ? this.gender : gender as String?,
    );
  }

  static const _sentinel = Object();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone'],
      mobilePhone: json['mobilePhone'] ?? json['mobile_phone'],
      businessPhone: json['businessPhone'] ?? json['business_phone'],
      status: json['status'] ?? '',
      associate: json['associate'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      fatherName: json['fatherName'] ?? json['father_name'],
      motherName: json['motherName'] ?? json['mother_name'],
      zipCode: json['zipCode'] ?? json['zip_code'],
      street: json['street'],
      addressNumber: json['addressNumber'] ?? json['address_number'],
      addressComplement: json['addressComplement'] ?? json['address_complement'],
      district: json['district'],
      city: json['city'],
      state: json['state'],
      maritalStatus: json['maritalStatus'] ?? json['marital_status'],
      gender: json['gender'],
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
      'maritalStatus': maritalStatus,
      'gender': gender,
    };
  }
}
