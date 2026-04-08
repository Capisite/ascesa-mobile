import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/main.dart' show navigatorKey;
import 'package:ascesa/features/home/presentation/pages/home_page.dart';
import 'package:ascesa/features/benefits/presentation/pages/convenios_page.dart';
import 'package:ascesa/features/benefits/presentation/pages/benefits_map_page.dart';
import 'package:ascesa/features/news/presentation/pages/noticias_page.dart';
import 'package:ascesa/features/member_area/presentation/pages/configuracoes_page.dart';

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

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final BenefitsController _benefitsController;
  late final HomeController _homeController;
  late final UserProfileController _userProfileController;

  late User _currentUser;
  late final List<Widget> _pages;

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
    final getCategoriesUseCase = GetCategoriesUseCase(repository: homeRepository);
    _homeController = HomeController(getCategoriesUseCase: getCategoriesUseCase);
    _homeController.fetchCategories();

    // Dependency Injection for Benefits
    final benefitsRemoteDataSource = BenefitsRemoteDataSource(token: widget.token);
    final benefitsLocalDataSource = BenefitsLocalDataSource();
    final benefitsRepository = BenefitsRepositoryImpl(
      remoteDataSource: benefitsRemoteDataSource,
      localDataSource: benefitsLocalDataSource,
    );
    final getPartnersUseCase = GetPartnersByCategoryUseCase(repository: benefitsRepository);
    _benefitsController = BenefitsController(
      getPartnersUseCase: getPartnersUseCase,
      remoteDataSource: benefitsRemoteDataSource,
    );
    _benefitsController.fetchAllPartners();

    // Dependency Injection for User Profile
    final userRemoteDataSource = UserRemoteDataSource(token: widget.token);
    final authLocalDataSource = AuthLocalDataSource();
    final updateUserUseCase = UpdateUserUseCase(dataSource: userRemoteDataSource);
    final getUserProfileUseCase = GetUserProfileUseCase(dataSource: userRemoteDataSource);
    _userProfileController = UserProfileController(
      updateUserUseCase: updateUserUseCase,
      getUserProfileUseCase: getUserProfileUseCase,
      authLocalDataSource: authLocalDataSource,
      user: _currentUser,
    );

    _userProfileController.addListener(_onUserProfileUpdated);
    _userProfileController.fetchProfile();

    _pages = [
      HomePage(
        user: _currentUser,
        controller: _homeController,
        onCategorySelected: (categoryName) {
          _benefitsController.setFilter(categoryName);
          _onItemTapped(1); // Switch to Convenios tab
        },
      ),
      ConveniosPage(
        benefitsController: _benefitsController,
        homeController: _homeController,
      ),
      const NoticiasPage(),
      ConfiguracoesPage(userProfileController: _userProfileController),
    ];

    // Configura callback para quando o usuário clica na notificação
    _setupNotificationNavigation();
  }

  void _setupNotificationNavigation() {
    NotificationService.onNotificationTapped = (payload) {
      if (payload == null || payload.isEmpty) return;

      debugPrint("[MainPage] Notificação clicada com payload: $payload");

      // Tenta encontrar o parceiro
      // payload pode ser:
      //   - partnerId direto (do ProximityService)
      //   - zoneId no formato "zone_{partnerId}_{addressName}" (do GeofencingService)
      Partner? partner;
      
      if (payload.startsWith('zone_')) {
        partner = _benefitsController.findPartnerByZoneId(payload);
      } else {
        partner = _benefitsController.findPartnerById(payload);
      }

      if (partner != null) {
        debugPrint("[MainPage] Navegando ao mapa com parceiro: ${partner.name}");
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => BenefitsMapPage(
              benefitsController: _benefitsController,
              initialPartner: partner,
            ),
          ),
        );
      } else {
        debugPrint("[MainPage] Parceiro não encontrado para payload: $payload. Abrindo mapa geral.");
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
      setState(() {
        _currentUser = _userProfileController.user;
        // Rebuild pages with new user
        _pages[0] = HomePage(
          user: _currentUser,
          controller: _homeController,
          onCategorySelected: (categoryName) {
            _benefitsController.setFilter(categoryName);
            _onItemTapped(1);
          },
        );
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
