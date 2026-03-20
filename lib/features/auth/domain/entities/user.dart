class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final bool associate;
  final List<String> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    required this.associate,
    required this.roles,
  });
}
