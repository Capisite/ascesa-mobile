import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';

class ConveniosFilterList extends StatelessWidget {
  const ConveniosFilterList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildPillFilter('Todas', true),
          const SizedBox(width: 8),
          _buildPillFilter('Comer & Beber', false),
          const SizedBox(width: 8),
          _buildPillFilter('Cultura & Lazer', false),
          const SizedBox(width: 8),
          _buildPillFilter('Turismo', false),
          const SizedBox(width: 8),
          _buildPillFilter('Cursos', false),
          const SizedBox(width: 8),
          _buildPillFilter('Saúde e Esportes', false),
          const SizedBox(width: 8),
          _buildPillFilter('Lojas', false),
          const SizedBox(width: 8),
          _buildPillFilter('Profissionais', false),
          const SizedBox(width: 8),
          _buildPillFilter('Farmácias', false),
          const SizedBox(width: 8),
          _buildPillFilter('Beleza & Bem-estar', false),
          const SizedBox(width: 8),
          _buildPillFilter('Serviços', false),
        ],
      ),
    );
  }

  Widget _buildPillFilter(String label, bool isSelected, [IconData? icon]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.greenDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
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
