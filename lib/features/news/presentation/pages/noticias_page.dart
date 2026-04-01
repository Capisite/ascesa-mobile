import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/news/data/datasources/news_remote_datasource.dart';
import 'package:ascesa/features/news/data/repositories/news_repository_impl.dart';
import 'package:ascesa/features/news/domain/usecases/get_news.dart';
import 'package:ascesa/features/news/presentation/controllers/news_controller.dart';
import 'package:ascesa/features/news/presentation/widgets/news_card.dart';

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  State<NoticiasPage> createState() => _NoticiasPageState();
}

class _NoticiasPageState extends State<NoticiasPage> {
  late final NewsController _newsController;

  @override
  void initState() {
    super.initState();
    // Local DI setup following project pattern
    final remoteDataSource = NewsRemoteDataSource();
    final repository = NewsRepositoryImpl(remoteDataSource);
    final getNewsUseCase = GetNews(repository);
    _newsController = NewsController(getNewsUseCase: getNewsUseCase);

    _newsController.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListenableBuilder(
        listenable: _newsController,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => _newsController.fetchNews(),
            color: AppColors.greenPrimary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
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
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (_newsController.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  )
                else if (_newsController.errorMessage != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red[300], size: 48),
                          const SizedBox(height: 16),
                          Text(
                            _newsController.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _newsController.fetchNews(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenPrimary,
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_newsController.news.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Nenhuma notícia encontrada'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final news = _newsController.news[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: NewsCard(
                              title: news.title,
                              date: DateFormat('dd MMM, yyyy')
                                  .format(news.createdAt),
                              description: news.description,
                              imageUrl: news.imageUrl,
                            ),
                          );
                        },
                        childCount: _newsController.news.length,
                      ),
                    ),
                  ),
                // Safety space at the bottom
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}
