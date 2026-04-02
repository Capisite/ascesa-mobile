import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuickAccessSection extends StatefulWidget {
  final HomeController controller;
  final Function(String)? onCategorySelected;
  
  const QuickAccessSection({
    super.key,
    required this.controller,
    this.onCategorySelected,
  });

  @override
  State<QuickAccessSection> createState() => _QuickAccessSectionState();
}

class _QuickAccessSectionState extends State<QuickAccessSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acesso Rápido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
        const SizedBox(height: 16),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, child) {
            if (widget.controller.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(color: AppColors.greenPrimary),
                ),
              );
            }

            if (widget.controller.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        widget.controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      TextButton(
                        onPressed: () => widget.controller.fetchCategories(),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final categories = widget.controller.categories;

            if (categories.isEmpty) {
              return const Center(child: Text('Nenhuma categoria encontrada'));
            }

            // Lógica para limitar itens ou mostrar tudo
            final int maxItemsBeforeExpanding = 8;
            final bool canExpand = categories.length > maxItemsBeforeExpanding;
            
            List<dynamic> itemsToDisplay;
            if (canExpand && !_isExpanded) {
              // Mostra 7 categorias + Botão Ver Mais
              itemsToDisplay = [...categories.take(maxItemsBeforeExpanding - 1), 'VER_MAIS'];
            } else if (canExpand && _isExpanded) {
              // Mostra todas + Botão Ver Menos
              itemsToDisplay = [...categories, 'VER_MENOS'];
            } else {
              itemsToDisplay = categories;
            }

            return GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: itemsToDisplay.length,
              itemBuilder: (context, index) {
                final item = itemsToDisplay[index];

                if (item == 'VER_MAIS' || item == 'VER_MENOS') {
                  final isVerMais = item == 'VER_MAIS';
                  return _buildActionButton(
                    label: isVerMais ? 'VER MAIS' : 'VER MENOS',
                    icon: isVerMais ? Icons.add : Icons.remove,
                    onTap: () => setState(() => _isExpanded = isVerMais),
                  );
                }

                final cat = item;
                return InkWell(
                  onTap: () {
                    if (widget.onCategorySelected != null) {
                      widget.onCategorySelected!(cat.name);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.greenDark,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SvgPicture.network(
                          cat.image,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                          placeholderBuilder: (context) => const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          cat.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.greenDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
