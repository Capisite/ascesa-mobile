import 'package:ascesa/features/blog/domain/entities/blog_post.dart';

class BlogPostModel extends BlogPost {
  const BlogPostModel({
    required super.id,
    required super.slug,
    required super.title,
    super.subtitle,
    super.content,
    required super.authorName,
    super.authorPhotoUrl,
    super.publishedAt,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.category,
    required super.images,
  });

  factory BlogPostModel.fromJson(Map<String, dynamic> json) {
    return BlogPostModel(
      id: json['id'],
      slug: json['slug'],
      title: json['title'],
      subtitle: json['subtitle'],
      content: json['content'],
      authorName: json['authorName'],
      authorPhotoUrl: json['authorPhotoUrl'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.parse(json['publishedAt'])
          : null,
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: BlogCategoryModel.fromJson(json['category']),
      images: (json['images'] as List<dynamic>?)
              ?.map((image) => BlogPostImageModel.fromJson(image))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'publishedAt': publishedAt?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'category': (category as BlogCategoryModel).toJson(),
      'images': images
          .map((image) => (image as BlogPostImageModel).toJson())
          .toList(),
    };
  }
}

class BlogCategoryModel extends BlogCategory {
  const BlogCategoryModel({
    required super.id,
    required super.name,
    required super.slug,
  });

  factory BlogCategoryModel.fromJson(Map<String, dynamic> json) {
    return BlogCategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
    };
  }
}

class BlogPostImageModel extends BlogPostImage {
  const BlogPostImageModel({
    required super.id,
    required super.imageUrl,
    super.altText,
    required super.displayOrder,
  });

  factory BlogPostImageModel.fromJson(Map<String, dynamic> json) {
    return BlogPostImageModel(
      id: json['id'],
      imageUrl: json['imageUrl'] ?? '',
      altText: json['altText'],
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'altText': altText,
      'displayOrder': displayOrder,
    };
  }
}
