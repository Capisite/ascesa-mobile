import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';

class ConvenioCard extends StatefulWidget {
  final String brandName;
  final String category;
  final String discount;
  final Color brandColor;
  final String? coverUrl;
  final Future<void> Function()? onOpenDiscount;
  final VoidCallback? onSeeOnMap;

  const ConvenioCard({
    super.key,
    required this.brandName,
    required this.category,
    required this.discount,
    required this.brandColor,
    this.coverUrl,
    this.onOpenDiscount,
    this.onSeeOnMap,
  });

  @override
  State<ConvenioCard> createState() => _ConvenioCardState();
}

class _ConvenioCardState extends State<ConvenioCard> { 
  bool _isLandscape = true;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImageInfo();
  }

  @override
  void didUpdateWidget(ConvenioCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coverUrl != oldWidget.coverUrl) {
      _loadImageInfo();
    }
  }

  void _loadImageInfo() {
    if (widget.coverUrl == null || widget.coverUrl!.isEmpty) {
      setState(() {
        _imageLoaded = false;
      });
      return;
    }

    final image = NetworkImage(widget.coverUrl!);
    final stream = image.resolve(const ImageConfiguration());
    
    stream.addListener(
      ImageStreamListener((ImageInfo info, bool synchronousCall) {
        if (mounted) {
          final double aspectRatio = info.image.width / info.image.height;
          setState(() {
            // Se for muito wide (landscape), usamos BoxFit.cover
            // Se for quadrada ou vertical (logo), usamos BoxFit.contain no híbrido
            _isLandscape = aspectRatio > 1.2 && info.image.width > 300;
            _imageLoaded = true;
          });
        }
      }),
    );
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
                  color: widget.coverUrl != null && widget.coverUrl!.isNotEmpty
                      ? AppColors.bgLight
                      : null,
                  gradient:
                      (widget.coverUrl == null || widget.coverUrl!.isEmpty)
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                widget.brandColor.withValues(alpha: 0.8),
                                widget.brandColor
                              ],
                            )
                          : null,
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
    if (widget.coverUrl == null || widget.coverUrl!.isEmpty) {
      return _buildBrandFallback();
    }

    if (!_imageLoaded) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.greenPrimary,
          ),
        ),
      );
    }

    // Se for Landscape e grande, mantemos o preenchimento total
    if (_isLandscape) {
      return Image.network(
        widget.coverUrl!,
        fit: BoxFit.cover,
        color: Colors.black.withValues(alpha: 0.15),
        colorBlendMode: BlendMode.darken,
      );
    }

    // Para imagens pequenas ou verticais: Cabeçalho Híbrido (Blur + Contain)
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fundo desfocado
        Image.network(
          widget.coverUrl!,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ),
        // Imagem centralizada sem cortes
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            widget.coverUrl!,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
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
