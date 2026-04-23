import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/faq/presentation/controllers/faq_controller.dart';
import 'package:ascesa/features/faq/presentation/widgets/faq_item_widget.dart';

class FaqPage extends StatefulWidget {
  final FaqController controller;
  final String userId;

  const FaqPage({
    super.key,
    required this.controller,
    required this.userId,
  });

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchFaqs();
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cadastro':
      case 'minha conta':
        return Icons.person_outline;
      case 'carteirinha':
      case 'carteirinha digital':
        return Icons.badge_outlined;
      case 'convênios':
      case 'benefícios':
        return Icons.card_membership_outlined;
      case 'vitrine':
      case 'vitrine virtual':
        return Icons.storefront_outlined;
      default:
        return Icons.support_agent_outlined;
    }
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
          'Como podemos ajudar?',
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
          if (widget.controller.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.greenPrimary));
          }

          if (widget.controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(widget.controller.errorMessage!),
                  TextButton(
                    onPressed: () => widget.controller.fetchFaqs(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final groupedFaqs = widget.controller.groupedFaqs;

          if (groupedFaqs.isEmpty) {
            return const Center(child: Text('Nenhuma dúvida encontrada.'));
          }

          return RefreshIndicator(
            onRefresh: () => widget.controller.fetchFaqs(),
            color: AppColors.greenPrimary,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const Text(
                  'Encontre respostas rápidas para as principais dúvidas sobre a ASCESA.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                ...groupedFaqs.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.greenPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(entry.key),
                              color: AppColors.greenPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greenDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...entry.value.map((faq) => FaqItemWidget(item: faq)),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
                _buildSupportCTA(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupportCTA() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.greenDark,
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [AppColors.greenDark, Color(0xFF0F2A16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.headset_mic_outlined, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sua dúvida não está aqui?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nossa equipe de suporte está pronta para atender você e resolver qualquer pendência.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
