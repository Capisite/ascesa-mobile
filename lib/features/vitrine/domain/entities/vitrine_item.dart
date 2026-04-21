import 'package:equatable/equatable.dart';

class VitrineItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String? contactInfo;
  final double? price;
  final String? category;
  final String status;
  final DateTime createdAt;
  final String authorName;
  final String? authorEmail;

  const VitrineItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    this.contactInfo,
    this.price,
    this.category,
    required this.status,
    required this.createdAt,
    required this.authorName,
    this.authorEmail,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrls,
        contactInfo,
        price,
        category,
        status,
        createdAt,
        authorName,
        authorEmail,
      ];
}
