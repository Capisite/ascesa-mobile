import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/blog/presentation/controllers/blog_controller.dart';

class BlogDetailPage extends StatefulWidget {
  final String slug;
  final BlogController controller;

  const BlogDetailPage({
    super.key,
    required this.slug,
    required this.controller,
  });

  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    widget.controller.fetchBlogDetail(widget.slug);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.bgLight,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.greenDark,
            size: 20,
          ),
          label: const Text(
            'voltar',
            style: TextStyle(color: AppColors.greenDark, fontSize: 14),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        leadingWidth: 100,
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          if (widget.controller.isDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.greenPrimary,
              ),
            );
          }

          if (widget.controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                  const SizedBox(height: 16),
                  Text(
                    widget.controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        widget.controller.fetchBlogDetail(widget.slug),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                    ),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final blog = widget.controller.selectedBlog;
          if (blog == null) {
            return const Center(
              child: Text('Blog não encontrado'),
            );
          }

          final hasImages = blog.images.isNotEmpty;
          final hasMultipleImages = blog.images.length > 1;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.greenPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    blog.category.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenPrimary,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  blog.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDark,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                if (blog.subtitle != null && blog.subtitle!.isNotEmpty) ...[
                  Text(
                    blog.subtitle!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Author and Date
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                          AppColors.greenPrimary.withValues(alpha: 0.1),
                      backgroundImage: blog.authorPhotoUrl != null &&
                              blog.authorPhotoUrl!.isNotEmpty
                          ? NetworkImage(blog.authorPhotoUrl!)
                          : null,
                      child: blog.authorPhotoUrl == null ||
                              blog.authorPhotoUrl!.isEmpty
                          ? Text(
                              blog.authorName.isNotEmpty
                                  ? blog.authorName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                  color: AppColors.greenPrimary,
                                  fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Por ${blog.authorName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greenDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            blog.publishedAt != null
                                ? DateFormat('dd/MM/yyyy HH:mm')
                                    .format(blog.publishedAt!)
                                : DateFormat('dd/MM/yyyy HH:mm')
                                    .format(blog.createdAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Images Carousel
                if (hasImages) ...[
                  SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemCount: blog.images.length,
                            itemBuilder: (context, index) {
                              final img = blog.images[index];
                              return Image.network(
                                img.imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildErrorPlaceholder(),
                              );
                            },
                          ),
                        ),
                        if (hasMultipleImages) ...[
                          // Left Arrow
                          Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_left,
                                      color: Colors.white),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Right Arrow
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                                child: IconButton(
                                  icon: const Icon(Icons.chevron_right,
                                      color: Colors.white),
                                  onPressed: () {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Indicators
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                blog.images.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  width: _currentImageIndex == index ? 12 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? AppColors.greenPrimary
                                        : Colors.white.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Content
                Text(
                  blog.content ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.greenDark,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.greenPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.greenPrimary,
          size: 48,
        ),
      ),
    );
  }
}
