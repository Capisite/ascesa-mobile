import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/main/presentation/pages/main_page.dart';
import 'package:flutter_project/features/news/presentation/widgets/news_card.dart';

class LatestNewsSection extends StatelessWidget {
  const LatestNewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Últimas Notícias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greenDark,
              ),
            ),
            TextButton(
              onPressed: () {
                final mainState = context
                    .findAncestorStateOfType<MainPageState>();
                mainState?.changeTab(2); // 2 is Noticias tab index
              },
              child: const Text(
                'Ver todas',
                style: TextStyle(
                  color: AppColors.greenPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const NewsCard(
          title: 'Assembleia Geral Ordinária',
          date: '15 Março, 2024',
          description:
              'Convocação para a próxima assembleia geral para discussão de pautas importantes...',
          imageUrl: 'assets/images/news.png',
        ),
        const SizedBox(height: 12),
        const NewsCard(
          title: 'Campanha de Vacinação',
          date: '10 Março, 2024',
          description:
              'Iniciada a nova fase da campanha de vacinação parceira para todos os membros...',
          imageUrl: 'assets/images/news.png',
        ),
        // Add padding at the bottom so the FAB doesn't cover the last content
        const SizedBox(height: 60),
      ],
    );
  }
}
