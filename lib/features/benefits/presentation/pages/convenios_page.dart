import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenios_header.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenios_search_bar.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenios_filter_list.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenio_card.dart';
import 'package:flutter_project/features/benefits/presentation/controllers/benefits_controller.dart';

import 'package:flutter_project/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_project/features/benefits/presentation/pages/benefits_map_page.dart';

class ConveniosPage extends StatelessWidget {
  final BenefitsController benefitsController;
  final HomeController homeController;
  
  const ConveniosPage({
    super.key,
    required this.benefitsController,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          const ConveniosHeader(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListenableBuilder(
                listenable: benefitsController,
                builder: (context, child) {
                  final partners = benefitsController.partners;
                  final isLoading = benefitsController.isLoading;
                  final errorMessage = benefitsController.errorMessage;

                  return Column(
                    children: [
                      const SizedBox(height: 16),

                      const ConveniosSearchBar(),
                      const SizedBox(height: 24),

                      ListenableBuilder(
                        listenable: homeController,
                        builder: (context, _) {
                          return ConveniosFilterList(
                            categories: homeController.categories,
                            selectedCategoryId: benefitsController.selectedCategoryId,
                            onCategorySelected: (catId) {
                               benefitsController.setFilter(catId);
                            },
                            onClearFilter: () {
                               benefitsController.setFilter(null);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Section Title
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          benefitsController.selectedCategoryId != null 
                              ? 'Parceiros Encontrados'
                              : 'Destaques para você',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.greenDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(color: AppColors.greenPrimary),
                          ),
                        )
                      else if (errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                                const SizedBox(height: 8),
                                Text(
                                  errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                TextButton(
                                  onPressed: () {
                                    benefitsController.fetchAllPartners();
                                  },
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (partners.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('Nenhum parceiro encontrado nesta categoria'),
                          ),
                        )
                      else
                        // Grid View
                        GridView.builder(
                          padding: const EdgeInsets.only(bottom: 32),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: partners.length,
                          itemBuilder: (context, index) {
                            final partner = partners[index];
                            final brandColor = _getBrandColor(partner.name);
                            
                            return ConvenioCard(
                              brandName: partner.name,
                              category: partner.categoryId,
                              discount: partner.title ?? '',
                              brandColor: brandColor,
                              coverUrl: partner.cover,
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'benefits_map_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BenefitsMapPage(
                benefitsController: benefitsController,
              ),
            ),
          );
        },
        backgroundColor: AppColors.greenPrimary,
        icon: const Icon(Icons.map_outlined, color: Colors.white),
        label: const Text(
          'Ver Mapa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  Color _getBrandColor(String name) {
    // Simple helper to provide a consistent color per brand name if not available
    final colors = [
      const Color(0xFFC00000),
      const Color(0xFF5A2D82),
      const Color(0xFF00754A),
      const Color(0xFFF0A500),
      const Color(0xFFE3000F),
      const Color(0xFF0044CC),
    ];
    return colors[name.hashCode % colors.length];
  }
}
