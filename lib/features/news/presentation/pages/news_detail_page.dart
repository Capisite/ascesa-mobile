import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String date;
  final String imageUrl;
  final String description;

  const NewsDetailPage({
    super.key,
    required this.title,
    required this.date,
    required this.imageUrl,
    required this.description,
  });

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
            'voltar para notícias',
            style: TextStyle(color: AppColors.greenDark, fontSize: 14),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
        leadingWidth: 200,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'COMUNICADO OFICIAL',
                style: TextStyle(
                  color: AppColors.greenPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),

            // Date and Author
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.circle, size: 4, color: AppColors.border),
                ),
                const Text(
                  'Por ASCESA',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.greenDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: imageUrl.startsWith('http')
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(),
                    )
                  : Image.asset(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(),
                    ),
            ),
            const SizedBox(height: 32),

            // Content
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.greenDark,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.greenPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Icon(
          Icons.article_outlined,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }
}
