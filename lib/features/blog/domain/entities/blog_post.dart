class BlogPost {
  final String id;
  final String slug;
  final String title;
  final String? subtitle;
  final String? content;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime? publishedAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final BlogCategory category;
  final List<BlogPostImage> images;

  const BlogPost({
    required this.id,
    required this.slug,
    required this.title,
    this.subtitle,
    this.content,
    required this.authorName,
    this.authorPhotoUrl,
    this.publishedAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.images,
  });
}

class BlogCategory {
  final String id;
  final String name;
  final String slug;

  const BlogCategory({
    required this.id,
    required this.name,
    required this.slug,
  });
}

class BlogPostImage {
  final String id;
  final String imageUrl;
  final String? altText;
  final int displayOrder;

  const BlogPostImage({
    required this.id,
    required this.imageUrl,
    this.altText,
    required this.displayOrder,
  });
}
