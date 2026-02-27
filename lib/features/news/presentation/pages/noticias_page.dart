import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/news/presentation/widgets/news_card.dart';

class NoticiasPage extends StatelessWidget {
  const NoticiasPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data matching the web mock
    final newsList = [
      {
        'title': 'ASCESA promove evento de integração para associados',
        'date': '25 fev 2026',
        'description':
            'Convocação para a próxima assembleia geral para discussão de pautas...',
        'image': 'assets/images/news.png',
      },
      {
        'title': 'Novos convênios disponíveis para farmácias',
        'date': '24 fev 2026',
        'description':
            'Aproveite até 30% de desconto em dezenas de redes de farmácias cadastradas...',
        'image': 'assets/images/news.png',
      },
      {
        'title': 'Campanha de desconto em viagens nacionais',
        'date': '23 fev 2026',
        'description':
            'Programação de férias para 2026 com descontos incríveis em passagens e hotéis...',
        'image': 'assets/images/news.png',
      },
      {
        'title': 'Reunião do conselho deliberativo: Pautas aprovadas',
        'date': '20 fev 2026',
        'description':
            'Confira a ata completa da última reunião do conselho e as próximas ações...',
        'image': 'assets/images/news.png',
      },
      {
        'title': 'Atualização no sistema de carteirinhas virtuais',
        'date': '18 fev 2026',
        'description':
            'O novo aplicativo traz funcionalidades melhoradas de segurança...',
        'image': 'assets/images/news.png',
      },
      {
        'title': 'Parceria renovada com a rede de academias SmartFit',
        'date': '15 fev 2026',
        'description':
            'Renovamos o nosso compromisso para fornecer saúde com isenção de adesão...',
        'image': 'assets/images/news.png',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Últimas Notícias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Acompanhe as novidades, comunicados e atualizações importantes sobre a ASCESA e nossa rede de parceiros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: newsList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final news = newsList[index];
                return NewsCard(
                  title: news['title']!,
                  date: news['date']!,
                  description: news['description']!,
                  imageUrl: news['image']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
