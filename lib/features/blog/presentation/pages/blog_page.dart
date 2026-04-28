import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/blog/data/datasources/blog_remote_datasource.dart';
import 'package:ascesa/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:ascesa/features/blog/domain/usecases/get_blogs.dart';
import 'package:ascesa/features/blog/domain/usecases/get_blog_by_slug.dart';
import 'package:ascesa/features/blog/presentation/controllers/blog_controller.dart';
import 'package:ascesa/features/blog/presentation/widgets/blog_card.dart';

class BlogPage extends StatefulWidget {
  final String token;

  const BlogPage({super.key, required this.token});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late final BlogController _blogController;

  @override
  void initState() {
    super.initState();
    // Local DI setup following project pattern
    final remoteDataSource = BlogRemoteDataSource(token: widget.token);
    final repository = BlogRepositoryImpl(remoteDataSource);
    final getBlogsUseCase = GetBlogs(repository);
    final getBlogBySlugUseCase = GetBlogBySlug(repository);
    
    _blogController = BlogController(
      getBlogsUseCase: getBlogsUseCase,
      getBlogBySlugUseCase: getBlogBySlugUseCase,
    );

    _blogController.fetchBlogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Blog ASCESA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: _blogController,
        builder: (context, _) {
          return RefreshIndicator(
            onRefresh: () => _blogController.fetchBlogs(),
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
                      'Fique por dentro de artigos, dicas e conteúdos exclusivos preparados especialmente para você.',
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
                if (_blogController.isLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  )
                else if (_blogController.errorMessage != null)
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
                            _blogController.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _blogController.fetchBlogs(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.greenPrimary,
                            ),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_blogController.blogs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Nenhum artigo encontrado'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final blog = _blogController.blogs[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: BlogCard(
                              blog: blog,
                              controller: _blogController,
                            ),
                          );
                        },
                        childCount: _blogController.blogs.length,
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
