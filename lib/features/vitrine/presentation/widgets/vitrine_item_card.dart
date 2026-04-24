import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/features/vitrine/domain/entities/vitrine_item.dart';
import 'package:ascesa/features/vitrine/presentation/pages/vitrine_detail_page.dart';
import 'package:intl/intl.dart';

class VitrineItemCard extends StatefulWidget {
  final VitrineItem item;
  final VoidCallback? onTap;

  const VitrineItemCard({super.key, required this.item, this.onTap});

  @override
  State<VitrineItemCard> createState() => _VitrineItemCardState();
}

class _VitrineItemCardState extends State<VitrineItemCard> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Carousel
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: widget.item.imageUrls.isNotEmpty
                        ? PageView.builder(
                            itemCount: widget.item.imageUrls.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.item.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: AppColors.bgLight,
                                  child: const Icon(Icons.storefront, color: AppColors.textLight, size: 40),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.bgLight,
                            child: const Icon(Icons.storefront, color: AppColors.textLight, size: 40),
                          ),
                  ),
                ),
                // Category Tag
                if (widget.item.category != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.item.category!,
                        style: const TextStyle(
                          color: AppColors.greenPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Carousel Indicators
                if (widget.item.imageUrls.length > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.item.imageUrls.asMap().entries.map((entry) {
                        return Container(
                          width: _currentImageIndex == entry.key ? 16 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                              alpha: _currentImageIndex == entry.key ? 1.0 : 0.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  if (widget.item.price != null)
                    Text(
                      currencyFormatter.format(widget.item.price),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.border.withValues(alpha: 0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.greenPrimary.withValues(alpha: 0.1),
                        child: Text(
                          widget.item.authorName.isNotEmpty ? widget.item.authorName[0].toUpperCase() : 'A',
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.greenPrimary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Postado por ${widget.item.authorName}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yy').format(widget.item.createdAt),
                        style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
