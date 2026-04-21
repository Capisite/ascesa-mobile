import 'package:flutter/material.dart';
import 'package:ascesa/core/theme/app_colors.dart';
import 'package:ascesa/core/services/notification_service.dart';
import 'package:ascesa/main.dart' show navigatorKey;
import 'package:ascesa/features/home/presentation/pages/home_page.dart';
import 'package:ascesa/features/benefits/presentation/pages/convenios_page.dart';
import 'package:ascesa/features/benefits/presentation/pages/benefits_map_page.dart';
import 'package:ascesa/features/news/presentation/pages/noticias_page.dart';
import 'package:ascesa/features/member_area/presentation/pages/configuracoes_page.dart';
import 'package:ascesa/features/member_area/presentation/pages/configuracoes_page.dart';
import 'package:ascesa/features/faq/presentation/pages/faq_page.dart';
import 'package:ascesa/features/faq/presentation/controllers/faq_controller.dart';
import 'package:ascesa/features/faq/domain/usecases/get_faqs.dart';
import 'package:ascesa/features/faq/data/repositories/faq_repository_impl.dart';
import 'package:ascesa/features/faq/data/datasources/faq_remote_data_source.dart';
import 'package:ascesa/features/vitrine/presentation/pages/vitrine_page.dart';
import 'package:ascesa/features/vitrine/presentation/controllers/vitrine_controller.dart';
import 'package:ascesa/features/vitrine/domain/usecases/get_vitrine_items.dart';
import 'package:ascesa/features/vitrine/data/repositories/vitrine_repository_impl.dart';
import 'package:ascesa/features/vitrine/data/datasources/vitrine_remote_data_source.dart';
import 'package:ascesa/features/main/presentation/widgets/app_drawer.dart';

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
import 'package:ascesa/features/support/presentation/controllers/support_controller.dart';
import 'package:ascesa/features/support/data/repositories/support_repository_impl.dart';
import 'package:ascesa/features/support/data/datasources/support_remote_data_source.dart';
import 'package:ascesa/features/support/data/services/support_socket_service.dart';

class MainPage extends StatefulWidget {
  final User user;
  final String token;
  const MainPage({super.key, required this.user, required this.token});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  late final BenefitsController _benefitsController;
  late final HomeController _homeController;
  late final UserProfileController _userProfileController;
  late final SupportController _supportController;
  late final FaqController _faqController;
  late final VitrineController _vitrineController;

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
 
    final supportRemoteDataSource = SupportRemoteDataSourceImpl(
      token: widget.token,
    );
    final supportRepository = SupportRepositoryImpl(remoteDataSource: supportRemoteDataSource);
    final supportSocketService = SupportSocketService(token: widget.token);
    _supportController = SupportController(
      repository: supportRepository,
      socketService: supportSocketService,
    );
    _supportController.init();
    _supportController.addListener(_onSupportUpdate);

    _userProfileController.addListener(_onUserProfileUpdated);
    _userProfileController.fetchProfile();

    // Dependency Injection for FAQ
    final faqRemoteDataSource = FaqRemoteDataSource();
    final faqRepository = FaqRepositoryImpl(remoteDataSource: faqRemoteDataSource);
    final getFaqsUseCase = GetFaqs(faqRepository);
    _faqController = FaqController(getFaqsUseCase: getFaqsUseCase);

    // Dependency Injection for Vitrine
    final vitrineRemoteDataSource = VitrineRemoteDataSource();
    final vitrineRepository = VitrineRepositoryImpl(remoteDataSource: vitrineRemoteDataSource);
    final getVitrineItemsUseCase = GetVitrineItems(vitrineRepository);
    _vitrineController = VitrineController(getVitrineItemsUseCase: getVitrineItemsUseCase);

    _pages = [
      HomePage(
        user: _currentUser,
        controller: _homeController,
        supportController: _supportController,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onCategorySelected: (categoryName) {
          _benefitsController.setFilter(categoryName);
          _onItemTapped(1); // Switch to Convenios tab
        },
      ),
      ConveniosPage(
        benefitsController: _benefitsController,
        homeController: _homeController,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      NoticiasPage(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      ConfiguracoesPage(
        userProfileController: _userProfileController,
        supportController: _supportController,
        token: widget.token,
        userId: _currentUser.id,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      FaqPage(
        controller: _faqController,
        supportController: _supportController,
        userId: _currentUser.id,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      VitrinePage(
        controller: _vitrineController,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentUser = _userProfileController.user;
            // Rebuild pages with new user
            _pages[0] = HomePage(
              user: _currentUser,
              controller: _homeController,
              supportController: _supportController,
              onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
              onCategorySelected: (categoryName) {
                _benefitsController.setFilter(categoryName);
                _onItemTapped(1);
              },
            );
          });
        }
      });
    }
  }

  void _onSupportUpdate() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    NotificationService.onNotificationTapped = null;
    _userProfileController.removeListener(_onUserProfileUpdated);
    _supportController.removeListener(_onSupportUpdate);
    _supportController.dispose();
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
      key: _scaffoldKey,
      backgroundColor: AppColors.bgLight,
      drawer: AppDrawer(
        user: _currentUser,
        currentIndex: _selectedIndex,
        onSelectItem: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
    );
  }
}
