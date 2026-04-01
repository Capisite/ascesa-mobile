import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/main/presentation/pages/main_page.dart';
import 'package:ascesa/features/news/data/datasources/news_remote_datasource.dart';
import 'package:ascesa/features/news/data/repositories/news_repository_impl.dart';
import 'package:ascesa/features/news/domain/usecases/get_news.dart';
import 'package:ascesa/features/news/presentation/controllers/news_controller.dart';
import 'package:ascesa/features/news/presentation/widgets/news_card.dart';
import 'package:intl/intl.dart';


class LatestNewsSection extends StatefulWidget {
  const LatestNewsSection({super.key});

  @override
  State<LatestNewsSection> createState() => _LatestNewsSectionState();
}

class _LatestNewsSectionState extends State<LatestNewsSection> {
  late final NewsController _newsController;

  @override
  void initState() {
    super.initState();
    // Since there is no global DI yet, we instantiate it here for now
    // In a real app we'd use GetIt or Provider
    final remoteDataSource = NewsRemoteDataSource();
    final repository = NewsRepositoryImpl(remoteDataSource);
    final getNewsUseCase = GetNews(repository);
    _newsController = NewsController(getNewsUseCase: getNewsUseCase);
    
    _newsController.fetchNews();
  }


  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _newsController,
      builder: (context, _) {
        if (_newsController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_newsController.errorMessage != null) {
          return Center(child: Text(_newsController.errorMessage!));
        }

        final newsList = _newsController.news;

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
        if (newsList.isEmpty)
          const Center(child: Text('Nenhuma notícia encontrada')),
        ...newsList.take(3).map((news) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: NewsCard(
                title: news.title,
                date: DateFormat('dd MMM, yyyy').format(news.createdAt),
                description: news.description,
                imageUrl: news.imageUrl,
              ),
            )),
        // Add padding at the bottom so the FAB doesn't cover the last content
        const SizedBox(height: 60),
      ],
    );
  },
);
}
}



