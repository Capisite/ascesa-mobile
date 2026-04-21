import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';

class VitrineItemModel extends VitrineItem {
  const VitrineItemModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrls,
    super.contactInfo,
    super.price,
    super.category,
    required super.status,
    required super.createdAt,
    required super.authorName,
    super.authorEmail,
  });

  factory VitrineItemModel.fromJson(Map<String, dynamic> json) {
    return VitrineItemModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      contactInfo: json['contactInfo'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
      category: json['category'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      authorName: json['author'] != null ? json['author']['name'] : 'ASCESA',
      authorEmail: json['author'] != null ? json['author']['email'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'contactInfo': contactInfo,
      'price': price,
      'category': category,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'authorEmail': authorEmail,
    };
  }
}
