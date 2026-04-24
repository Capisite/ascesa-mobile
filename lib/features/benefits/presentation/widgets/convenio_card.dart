import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';

class ConvenioCard extends StatefulWidget {
  final String brandName;
  final String category;
  final String discount;
  final Color brandColor;
  final String? address;
  final Future<void> Function()? onOpenDiscount;
  final VoidCallback? onSeeOnMap;

  const ConvenioCard({
    super.key,
    required this.brandName,
    required this.category,
    required this.discount,
    required this.brandColor,
    this.address,
    this.onOpenDiscount,
    this.onSeeOnMap,
  });

  @override
  State<ConvenioCard> createState() => _ConvenioCardState();
}

class _ConvenioCardState extends State<ConvenioCard> { 
  @override
  void initState() {
    super.initState();
  }

  bool _isOpeningDiscount = false;

  Future<void> _handleOpenDiscount() async {
    if (widget.onOpenDiscount == null || _isOpeningDiscount) return;
    setState(() => _isOpeningDiscount = true);
    try {
      await widget.onOpenDiscount!();
    } finally {
      if (mounted) {
        setState(() => _isOpeningDiscount = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: widget.brandColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Premium Header Area (Adaptive)
          Expanded(
            flex: 25,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.brandColor.withValues(alpha: 0.8),
                      widget.brandColor
                    ],
                  ),
                ),
                child: _buildHeaderContent(),
              ),
            ),
          ),
          // Clean Content Area
          Expanded(
            flex: 75,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
 
                        child: Text(
                          widget.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.brandName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greenDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.discount,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greenPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      if (widget.address != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.address!,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),

                  // Styled Button(s)
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GestureDetector(
                          onTap: _handleOpenDiscount,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.greenPrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: _isOpeningDiscount
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.greenPrimary,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Ver Desconto',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.greenPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      if (widget.onSeeOnMap != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: widget.onSeeOnMap,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.greenDark.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.map_outlined,
                              size: 16,
                              color: AppColors.greenDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    return _buildBrandFallback();
  }

  Widget _buildBrandFallback() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle icon in background
        Positioned(
          right: -10,
          bottom: -10,
          child: Icon(
            Icons.star_rounded,
            size: 60,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.brandName.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
