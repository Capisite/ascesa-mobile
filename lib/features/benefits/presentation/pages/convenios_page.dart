import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenios_header.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenios_search_bar.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenios_filter_list.dart';
import 'package:flutter_project/features/benefits/presentation/widgets/convenio_card.dart';

class ConveniosPage extends StatelessWidget {
  const ConveniosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data matching the web mock
    final conveniosList = [
      {
        'brand': 'Cinemark',
        'category': 'Cultura & Lazer',
        'discount': 'Até 50% off',
        'color': const Color(0xFFC00000), // Richer Red
      },
      {
        'brand': 'Netshoes',
        'category': 'Lojas Esportivas',
        'discount': '15% off no app',
        'color': const Color(0xFF5A2D82), // Beautiful Indigo
      },
      {
        'brand': 'Droga Raia',
        'category': 'Saúde & Farmácia',
        'discount': 'Até 30% em genéricos',
        'color': const Color(0xFF00754A), // Deep vibrant Green
      },
      {
        'brand': 'Smart Fit',
        'category': 'Academias',
        'discount': 'Zero adesão',
        'color': const Color(0xFFF0A500), // Vibrant Amber
      },
      {
        'brand': 'Centauro',
        'category': 'Lojas',
        'discount': '20% em tênis',
        'color': const Color(0xFFE3000F), // Bright Red
      },
      {
        'brand': 'Cobasi',
        'category': 'Pet Shop',
        'discount': '10% no banho',
        'color': const Color(0xFF0044CC), // Rich Blue
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          const ConveniosHeader(),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  const ConveniosSearchBar(),
                  const SizedBox(height: 24),

                  const ConveniosFilterList(),
                  const SizedBox(height: 32),

                  // Section Title
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Destaques para você',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                    itemCount: conveniosList.length,
                    itemBuilder: (context, index) {
                      final item = conveniosList[index];
                      return ConvenioCard(
                        brandName: item['brand'] as String,
                        category: item['category'] as String,
                        discount: item['discount'] as String,
                        brandColor: item['color'] as Color,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
