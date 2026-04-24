import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/vitrine/presentation/controllers/vitrine_controller.dart';
import 'package:ascesa/features/vitrine/presentation/widgets/vitrine_item_card.dart';
import 'package:ascesa/features/vitrine/presentation/pages/vitrine_detail_page.dart';

class VitrinePage extends StatefulWidget {
  final VitrineController controller;

  const VitrinePage({
    super.key,
    required this.controller,
  });

  @override
  State<VitrinePage> createState() => _VitrinePageState();
}

class _VitrinePageState extends State<VitrinePage> {
  final ScrollController _scrollController = ScrollController();
  
  final Map<String, String> _categories = {
    'ELETRONICOS': 'Eletrônicos',
    'SERVICOS': 'Serviços',
    'VESTUARIO': 'Vestuário',
    'VEICULOS': 'Veículos',
    'IMOVEIS': 'Imóveis',
    'OUTROS': 'Outros',
  };

  @override
  void initState() {
    super.initState();
    widget.controller.fetchItems(refresh: true);
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        widget.controller.fetchItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          'Vitrine Virtual',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greenDark,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          return Column(
            children: [
              const SizedBox(height: 8),
              _buildCategoryFilter(),
              Expanded(
                child: _buildContent(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (widget.controller.isLoading && widget.controller.items.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary));
    }

    if (widget.controller.errorMessage != null && widget.controller.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(widget.controller.errorMessage!),
            TextButton(
              onPressed: () => widget.controller.fetchItems(refresh: true),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (widget.controller.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => widget.controller.fetchItems(refresh: true),
        color: AppColors.greenPrimary,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(
              child: Text(
                'Nenhuma oferta postada ainda.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.controller.fetchItems(refresh: true),
      color: AppColors.greenPrimary,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: widget.controller.items.length + (widget.controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < widget.controller.items.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: VitrineItemCard(
                item: widget.controller.items[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VitrineDetailPage(
                        item: widget.controller.items[index],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: widget.controller.isLoadingMore
                    ? const CircularProgressIndicator(color: AppColors.greenPrimary, strokeWidth: 2)
                    : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildCategoryChip(null, 'Todos'),
          ..._categories.entries.map((e) => _buildCategoryChip(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = widget.controller.selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.greenDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            widget.controller.setCategory(category);
          }
        },
        selectedColor: AppColors.greenPrimary,
        backgroundColor: AppColors.bgLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.greenPrimary : AppColors.border,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
