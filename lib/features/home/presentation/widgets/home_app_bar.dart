import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/support/presentation/controllers/support_controller.dart';
import 'package:ascesa/features/support/presentation/pages/support_page.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User user;
  final SupportController supportController;

  const HomeAppBar({
    super.key,
    required this.user,
    required this.supportController,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
      actions: [
        ListenableBuilder(
          listenable: supportController,
          builder: (context, child) {
            return IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.textMuted),
                  if (supportController.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '${supportController.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupportPage(
                      controller: supportController,
                      userId: user.id,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
