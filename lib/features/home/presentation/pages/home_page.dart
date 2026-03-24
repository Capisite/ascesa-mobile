import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/home/presentation/widgets/home_app_bar.dart';
import 'package:flutter_project/features/home/presentation/widgets/quick_access_section.dart';
import 'package:flutter_project/features/home/presentation/widgets/promo_banner.dart';
import 'package:flutter_project/features/home/presentation/widgets/latest_news_section.dart';
import 'package:flutter_project/features/home/presentation/widgets/virtual_id_card_dialog.dart';

import 'package:flutter_project/features/auth/domain/entities/user.dart';
import 'package:flutter_project/features/home/presentation/controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  final User user;
  final HomeController controller;
  final Function(String)? onCategorySelected;
  
  const HomePage({
    super.key,
    required this.user,
    required this.controller,
    this.onCategorySelected,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeAppBar(user: widget.user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickAccessSection(
              controller: widget.controller,
              onCategorySelected: widget.onCategorySelected,
            ),
            const SizedBox(height: 24),
            const PromoBanner(),
            const SizedBox(height: 24),
            const LatestNewsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => VirtualIdCardDialog(user: widget.user),
          );
        },
        backgroundColor: AppColors.greenDark,
        foregroundColor: Colors.white,
        child: const Icon(Icons.badge_outlined),
      ),
    );
  }
}
