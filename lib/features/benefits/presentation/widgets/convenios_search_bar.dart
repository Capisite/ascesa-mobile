import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';

class ConveniosSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String initialValue;

  const ConveniosSearchBar({
    super.key,
    this.onChanged,
    this.onClear,
    this.initialValue = '',
  });

  @override
  State<ConveniosSearchBar> createState() => _ConveniosSearchBarState();
}

class _ConveniosSearchBarState extends State<ConveniosSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textLight, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: const InputDecoration(
                hintText: 'Qual loja você procura?',
                hintStyle: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textLight, size: 20),
              onPressed: () {
                _controller.clear();
                if (widget.onClear != null) {
                  widget.onClear!();
                } else if (widget.onChanged != null) {
                  widget.onChanged!('');
                }
                setState(() {});
              },
            ),
          Container(
            height: 30,
            width: 1,
            color: AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }
}
