import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/domain/entities/user.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;

  const HomeAppBar({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Olá, ${user.name} 👋',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greenDark,
            ),
          ),
          Text(
            user.associate ? 'Associado Ativo' : 'Não Associado',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.greenPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
