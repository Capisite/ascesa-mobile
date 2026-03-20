import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import 'package:flutter_project/features/home/presentation/pages/home_page.dart';
import 'package:flutter_project/features/benefits/presentation/pages/convenios_page.dart';
import 'package:flutter_project/features/news/presentation/pages/noticias_page.dart';
import 'package:flutter_project/features/member_area/presentation/pages/configuracoes_page.dart';

import 'package:flutter_project/features/auth/domain/entities/user.dart';

class MainPage extends StatefulWidget {
  final User user;
  const MainPage({super.key, required this.user});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      const ConveniosPage(),
      const NoticiasPage(),
      const ConfiguracoesPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // ensures all 4 items show
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.greenPrimary,
            unselectedItemColor: AppColors.textLight,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.handshake_outlined),
                activeIcon: Icon(Icons.handshake),
                label: 'Convênios',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Notícias',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings),
                label: 'Configurações',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
