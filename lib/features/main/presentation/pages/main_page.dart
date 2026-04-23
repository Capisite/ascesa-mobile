import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/main.dart' show navigatorKey;
import 'package:ascesa/features/home/presentation/pages/home_page.dart';
import 'package:ascesa/features/benefits/presentation/pages/convenios_page.dart';
import 'package:ascesa/features/benefits/presentation/pages/benefits_map_page.dart';
import 'package:ascesa/features/news/presentation/pages/noticias_page.dart';
import 'package:ascesa/features/member_area/presentation/pages/more_options_page.dart';
import 'package:ascesa/features/faq/presentation/controllers/faq_controller.dart';
import 'package:ascesa/features/faq/domain/usecases/get_faqs.dart';
import 'package:ascesa/features/faq/data/repositories/faq_repository_impl.dart';
import 'package:ascesa/features/faq/data/datasources/faq_remote_data_source.dart';
import 'package:ascesa/features/vitrine/presentation/pages/vitrine_page.dart';
import 'package:ascesa/features/vitrine/presentation/controllers/vitrine_controller.dart';
import 'package:ascesa/features/vitrine/domain/usecases/get_vitrine_items.dart';
import 'package:ascesa/features/vitrine/data/repositories/vitrine_repository_impl.dart';
import 'package:ascesa/features/vitrine/data/datasources/vitrine_remote_data_source.dart';

import 'package:ascesa/features/auth/domain/entities/user.dart';
import 'package:ascesa/features/benefits/presentation/controllers/benefits_controller.dart';
import 'package:ascesa/features/benefits/domain/usecases/get_partners_by_category_use_case.dart';
import 'package:ascesa/features/benefits/data/repositories/benefits_repository_impl.dart';
import 'package:ascesa/features/benefits/data/datasources/benefits_remote_data_source.dart';
import 'package:ascesa/features/benefits/data/datasources/benefits_local_data_source.dart';
import 'package:ascesa/features/benefits/domain/entities/partner.dart';

import 'package:ascesa/features/home/presentation/controllers/home_controller.dart';
import 'package:ascesa/features/home/domain/usecases/get_categories_use_case.dart';
import 'package:ascesa/features/home/data/repositories/home_repository_impl.dart';
import 'package:ascesa/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ascesa/features/home/data/datasources/home_local_data_source.dart';
import 'package:ascesa/features/member_area/data/datasources/user_remote_data_source.dart';
import 'package:ascesa/features/member_area/domain/usecases/update_user_use_case.dart';
import 'package:ascesa/features/member_area/domain/usecases/get_user_profile_use_case.dart';
import 'package:ascesa/features/member_area/presentation/controllers/user_profile_controller.dart';
import 'package:ascesa/features/auth/data/datasources/auth_local_data_source.dart';

class MainPage extends StatefulWidget {
  final User user;
  final String token;
  const MainPage({super.key, required this.user, required this.token});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final BenefitsController _benefitsController;
  late final HomeController _homeController;
  late final UserProfileController _userProfileController;
  late final FaqController _faqController;
  late final VitrineController _vitrineController;

  late User _currentUser;
  late final List<Widget> _pages;

  // Bottom nav items definition
  static const _navItems = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.handshake_outlined,
      activeIcon: Icons.handshake_rounded,
      label: 'Convênios',
    ),
    _NavItem(
      icon: Icons.article_outlined,
      activeIcon: Icons.article_rounded,
      label: 'Notícias',
    ),
    _NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Vitrine',
    ),
    _NavItem(
      icon: Icons.menu,
      activeIcon: Icons.menu,
      label: 'Mais',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;

    // Dependency Injection for Home
    final homeRemoteDataSource = HomeRemoteDataSource(token: widget.token);
    final homeLocalDataSource = HomeLocalDataSource();
    final homeRepository = HomeRepositoryImpl(
      remoteDataSource: homeRemoteDataSource,
      localDataSource: homeLocalDataSource,
    );
    final getCategoriesUseCase =
        GetCategoriesUseCase(repository: homeRepository);
    _homeController =
        HomeController(getCategoriesUseCase: getCategoriesUseCase);
    _homeController.fetchCategories();

    // Dependency Injection for Benefits
    final benefitsRemoteDataSource =
        BenefitsRemoteDataSource(token: widget.token);
    final benefitsLocalDataSource = BenefitsLocalDataSource();
    final benefitsRepository = BenefitsRepositoryImpl(
      remoteDataSource: benefitsRemoteDataSource,
      localDataSource: benefitsLocalDataSource,
    );
    final getPartnersUseCase =
        GetPartnersByCategoryUseCase(repository: benefitsRepository);
    _benefitsController = BenefitsController(
      getPartnersUseCase: getPartnersUseCase,
      remoteDataSource: benefitsRemoteDataSource,
    );
    _benefitsController.fetchAllPartners();

    // Dependency Injection for User Profile
    final userRemoteDataSource = UserRemoteDataSource(token: widget.token);
    final authLocalDataSource = AuthLocalDataSource();
    final updateUserUseCase =
        UpdateUserUseCase(dataSource: userRemoteDataSource);
    final getUserProfileUseCase =
        GetUserProfileUseCase(dataSource: userRemoteDataSource);
    _userProfileController = UserProfileController(
      updateUserUseCase: updateUserUseCase,
      getUserProfileUseCase: getUserProfileUseCase,
      authLocalDataSource: authLocalDataSource,
      user: _currentUser,
    );

    _userProfileController.addListener(_onUserProfileUpdated);
    _userProfileController.fetchProfile();

    // Dependency Injection for FAQ
    final faqRemoteDataSource = FaqRemoteDataSource();
    final faqRepository =
        FaqRepositoryImpl(remoteDataSource: faqRemoteDataSource);
    final getFaqsUseCase = GetFaqs(faqRepository);
    _faqController = FaqController(getFaqsUseCase: getFaqsUseCase);

    // Dependency Injection for Vitrine
    final vitrineRemoteDataSource = VitrineRemoteDataSource();
    final vitrineRepository =
        VitrineRepositoryImpl(remoteDataSource: vitrineRemoteDataSource);
    final getVitrineItemsUseCase = GetVitrineItems(vitrineRepository);
    _vitrineController =
        VitrineController(getVitrineItemsUseCase: getVitrineItemsUseCase);

    _pages = [
      // 0: Home
      HomePage(
        user: _currentUser,
        controller: _homeController,
        onCategorySelected: (categoryName) {
          _benefitsController.setFilter(categoryName);
          _onItemTapped(1); // Switch to Convênios tab
        },
      ),
      // 1: Convênios
      ConveniosPage(
        benefitsController: _benefitsController,
        homeController: _homeController,
      ),
      // 2: Notícias
      const NoticiasPage(),
      // 3: Vitrine Virtual
      VitrinePage(
        controller: _vitrineController,
      ),
      // 4: Mais opções
      MoreOptionsPage(
        user: _currentUser,
        userProfileController: _userProfileController,
        faqController: _faqController,
        token: widget.token,
        userId: _currentUser.id,
      ),
    ];

    // Configura callback para quando o usuário clica na notificação
    _setupNotificationNavigation();
  }

  void _setupNotificationNavigation() {
    NotificationService.onNotificationTapped = (payload) {
      if (payload == null || payload.isEmpty) return;

      debugPrint("[MainPage] Notificação clicada com payload: $payload");

      Partner? partner;

      if (payload.startsWith('zone_')) {
        partner = _benefitsController.findPartnerByZoneId(payload);
      } else {
        partner = _benefitsController.findPartnerById(payload);
      }

      if (partner != null) {
        debugPrint(
            "[MainPage] Navegando ao mapa com parceiro: ${partner.name}");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => BenefitsMapPage(
              benefitsController: _benefitsController,
              initialPartner: partner,
            ),
          ),
        );
      } else {
        debugPrint(
            "[MainPage] Parceiro não encontrado para payload: $payload. Abrindo mapa geral.");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => BenefitsMapPage(
              benefitsController: _benefitsController,
            ),
          ),
        );
      }
    };
  }

  void _onUserProfileUpdated() {
    if (_userProfileController.user != _currentUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentUser = _userProfileController.user;
            // Rebuild HomePage with updated user
            _pages[0] = HomePage(
              user: _currentUser,
              controller: _homeController,
              onCategorySelected: (categoryName) {
                _benefitsController.setFilter(categoryName);
                _onItemTapped(1);
              },
            );
            // Rebuild MoreOptionsPage with updated user
            _pages[4] = MoreOptionsPage(
              user: _currentUser,
              userProfileController: _userProfileController,
              faqController: _faqController,
              token: widget.token,
              userId: _currentUser.id,
            );
          });
        }
      });
    }
  }

  @override
  void dispose() {
    NotificationService.onNotificationTapped = null;
    _userProfileController.removeListener(_onUserProfileUpdated);
    super.dispose();
  }

  void _onItemTapped(int index) {
    HapticFeedback.selectionClick();
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    final isMoreButton = index == _navItems.length - 1;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.greenPrimary.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? AppColors.greenPrimary
                      : AppColors.textMuted,
                  size: isMoreButton ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                  color: isSelected
                      ? AppColors.greenPrimary
                      : AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple data class for nav bar items.
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
