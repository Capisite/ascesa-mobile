import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.luggage_outlined, 'label': 'viagens e hospedagem'},
      {'icon': Icons.restaurant_outlined, 'label': 'restaurantes'},
      {'icon': Icons.sports_soccer_outlined, 'label': 'esportes e academias'},
      {
        'icon': Icons.content_cut_outlined,
        'label': 'centros de beleza e barbearias',
      },
      {'icon': Icons.school_outlined, 'label': 'graduação e idiomas'},
      {'icon': Icons.local_pharmacy_outlined, 'label': 'farmácias'},
      {'icon': Icons.shopping_cart_outlined, 'label': 'descontos em lojas'},
      {'icon': Icons.add, 'label': 'e muito mais'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acesso Rápido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: AppColors.greenPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    cat['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
