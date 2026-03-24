class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final bool associate;
  final List<String> roles;
  final String? fatherName;
  final String? motherName;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.associate,
    required this.roles,
    this.fatherName,
    this.motherName,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? status,
    bool? associate,
    List<String>? roles,
    String? fatherName,
    String? motherName,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      associate: associate ?? this.associate,
      roles: roles ?? this.roles,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      status: json['status'] ?? '',
      associate: json['associate'] ?? false,
      roles: List<String>.from(json['roles'] ?? []),
      fatherName: json['fatherName'],
      motherName: json['motherName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'associate': associate,
      'roles': roles,
      'fatherName': fatherName,
      'motherName': motherName,
    };
  }
}
