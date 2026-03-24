import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';

import 'package:flutter_project/features/home/domain/entities/category.dart';

class ConveniosFilterList extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String) onCategorySelected;
  final VoidCallback onClearFilter;

  const ConveniosFilterList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: categories.length + 1, // +1 for "Todas"
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return GestureDetector(
              onTap: onClearFilter,
              child: _buildPillFilter('Todas', isSelected),
            );
          }
          
          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;
          
          return GestureDetector(
            onTap: () {
              onCategorySelected(category.id);
            },
            child: _buildPillFilter(category.name, isSelected),
          );
        },
      ),
    );
  }

  Widget _buildPillFilter(String label, bool isSelected, [IconData? icon]) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.greenDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected ? [
           BoxShadow(
             color: AppColors.greenDark.withValues(alpha: 0.3),
             blurRadius: 8,
             offset: const Offset(0, 4),
           )
        ] : null,
        border: Border.all(
          color: isSelected ? AppColors.greenDark : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
