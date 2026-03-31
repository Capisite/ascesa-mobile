class News {
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String status;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const News({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });
}
