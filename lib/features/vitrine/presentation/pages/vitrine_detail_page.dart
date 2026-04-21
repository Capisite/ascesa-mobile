import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class VitrineDetailPage extends StatefulWidget {
  final VitrineItem item;

  const VitrineDetailPage({super.key, required this.item});

  @override
  State<VitrineDetailPage> createState() => _VitrineDetailPageState();
}

class _VitrineDetailPageState extends State<VitrineDetailPage> {
  int _currentImageIndex = 0;

  String? _getWhatsAppUrl(String contact) {
    final digits = contact.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      // Adiciona o prefixo do país se não houver
      final phone = digits.length == 10 || digits.length == 11 ? '55$digits' : digits;
      return 'https://wa.me/$phone';
    }
    return null;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final waUrl = widget.item.contactInfo != null ? _getWhatsAppUrl(widget.item.contactInfo!) : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with Image Carousel
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.greenDark,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.greenDark),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.item.imageUrls.isNotEmpty ? widget.item.imageUrls.length : 1,
                    onPageChanged: (index) => setState(() => _currentImageIndex = index),
                    itemBuilder: (context, index) {
                      if (widget.item.imageUrls.isEmpty) {
                        return Container(
                          color: AppColors.bgLight,
                          child: const Icon(Icons.storefront, color: AppColors.textLight, size: 80),
                        );
                      }
                      return Image.network(
                        widget.item.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.bgLight,
                          child: const Icon(Icons.error_outline, color: AppColors.textLight, size: 80),
                        ),
                      );
                    },
                  ),
                  if (widget.item.imageUrls.length > 1)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.item.imageUrls.asMap().entries.map((entry) {
                          return Container(
                            width: _currentImageIndex == entry.key ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: _currentImageIndex == entry.key ? 1.0 : 0.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 4),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.item.category != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.greenPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.item.category!.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.greenPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Postado em ${DateFormat('dd/MM/yyyy').format(widget.item.createdAt)}',
                    style: const TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),

                  const SizedBox(height: 24),
                  if (widget.item.price != null)
                    Text(
                      currencyFormatter.format(widget.item.price),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenPrimary,
                      ),
                    )
                  else
                    const Text(
                      'Preço sob consulta',
                      style: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                    ),

                  const SizedBox(height: 32),
                  const Text(
                    'DESCRIÇÃO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),
                  const Text(
                    'INFORMAÇÃO DO VENDEDOR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.person_outline, color: AppColors.greenPrimary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.authorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenDark,
                                ),
                              ),
                              if (widget.item.authorEmail != null)
                                Text(
                                  widget.item.authorEmail!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120), // Espaço para os botões fixos
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: waUrl != null
            ? ElevatedButton.icon(
                onPressed: () => _launchUrl(waUrl),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Conversar no WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            : widget.item.contactInfo != null
                ? ElevatedButton.icon(
                    onPressed: () => _launchUrl('tel:${widget.item.contactInfo}'),
                    icon: const Icon(Icons.phone),
                    label: Text('Ligar para ${widget.item.contactInfo}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
