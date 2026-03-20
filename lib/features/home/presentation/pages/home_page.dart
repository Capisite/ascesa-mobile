import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/home/presentation/widgets/home_app_bar.dart';
import 'package:flutter_project/features/home/presentation/widgets/quick_access_section.dart';
import 'package:flutter_project/features/home/presentation/widgets/promo_banner.dart';
import 'package:flutter_project/features/home/presentation/widgets/latest_news_section.dart';
import 'package:flutter_project/features/home/presentation/widgets/virtual_id_card_dialog.dart';

import 'package:flutter_project/features/auth/domain/entities/user.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: HomeAppBar(user: user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            QuickAccessSection(),
            SizedBox(height: 24),
            PromoBanner(),
            SizedBox(height: 24),
            LatestNewsSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => VirtualIdCardDialog(user: user),
          );
        },
        backgroundColor: AppColors.greenDark,
        foregroundColor: Colors.white,
        child: const Icon(Icons.badge_outlined),
      ),
    );
  }
}
