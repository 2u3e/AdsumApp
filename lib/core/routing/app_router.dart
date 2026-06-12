import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notification_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/work_orders/data/mobile_menu_provider.dart';
import '../../features/work_orders/presentation/screens/assigned_works_screen.dart';
import '../../features/work_orders/presentation/screens/unit_works_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_create_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_detail_screen.dart';
import '../services/menu_position_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/adsum_bottom_nav.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isAuthenticated ?? false;
      final isOnSplash = state.matchedLocation == RoutePaths.splash;
      final isOnLogin = state.matchedLocation == RoutePaths.login;
      if (isOnSplash) return null;
      if (!isLoggedIn && !isOnLogin) return RoutePaths.login;
      if (isLoggedIn && isOnLogin) return RoutePaths.home;
      return null;
    },
    routes: [
      GoRoute(path: RoutePaths.splash, name: RouteNames.splash, builder: (c, s) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, name: RouteNames.login, builder: (c, s) => const LoginScreen()),

      // İş oluştur / detay — shell üzerine tam ekran push (mock; ileride gerçek detay).
      GoRoute(
        path: RoutePaths.workOrderCreate,
        name: RouteNames.workOrderCreate,
        builder: (c, s) => const WorkOrderCreateScreen(),
      ),
      GoRoute(
        path: '/work-orders/:id',
        name: RouteNames.workOrderDetail,
        builder: (c, s) => WorkOrderDetailScreen(workOrderId: s.pathParameters['id']!),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _AdsumShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.home, name: RouteNames.home, builder: (c, s) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.assignedWorks, name: RouteNames.assignedWorks, builder: (c, s) => const AssignedWorksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.unitWorks, name: RouteNames.unitWorks, builder: (c, s) => const UnitWorksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.notifications, name: RouteNames.notifications, builder: (c, s) => const NotificationListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.profile, name: RouteNames.profile, builder: (c, s) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});

/// Branch index sabitleri (StatefulShellRoute sırasıyla).
class _Branch {
  static const home = 0;
  static const assigned = 1;
  static const unit = 2;
  static const notifications = 3;
  static const profile = 4;
}

/// Shell + modern menü. Öğeler yetkiye göre dinamik (Birim yalnız yetkiliyse).
/// Menü konumu ayarına göre altta sabit pill nav ya da solda açılır drawer.
class _AdsumShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const _AdsumShell({required this.navigationShell});

  @override
  ConsumerState<_AdsumShell> createState() => _AdsumShellState();
}

class _AdsumShellState extends ConsumerState<_AdsumShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final canUnit = ref.watch(canSeeUnitWorksProvider);
    final menuPos = ref.watch(menuPositionProvider);

    final entries = <(AdsumNavItem, int)>[
      (const AdsumNavItem(icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard_rounded, label: 'Panel'), _Branch.home),
      (const AdsumNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Atanan'), _Branch.assigned),
      if (canUnit)
        (const AdsumNavItem(icon: Icons.domain_outlined, activeIcon: Icons.domain_rounded, label: 'Birim'), _Branch.unit),
      (const AdsumNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Bildirim'), _Branch.notifications),
      (const AdsumNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'), _Branch.profile),
    ];
    final items = entries.map((e) => e.$1).toList();
    final branchOf = entries.map((e) => e.$2).toList();
    var currentDisplay = branchOf.indexOf(navigationShell.currentIndex);
    if (currentDisplay < 0) currentDisplay = 0;

    void go(int displayIndex) => navigationShell.goBranch(
          branchOf[displayIndex],
          initialLocation: branchOf[displayIndex] == navigationShell.currentIndex,
        );

    if (menuPos == MenuPosition.left) {
      final user = ref.watch(authStateProvider.select((s) => s.value?.user));
      return Scaffold(
        key: _scaffoldKey,
        drawer: AdsumSideMenu(
          items: items,
          currentIndex: currentDisplay,
          userName: user?.fullName,
          userInitials: user?.initials,
          onTap: (i) {
            Navigator.of(context).pop(); // drawer'ı kapat
            go(i);
          },
        ),
        body: Stack(
          children: [
            navigationShell,
            // Sol-alt açılır menü düğmesi (ekranın altını işlere bırakır)
            Positioned(
              left: 12,
              bottom: 12 + MediaQuery.viewPaddingOf(context).bottom,
              child: _MenuFab(onTap: () => _scaffoldKey.currentState?.openDrawer()),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: AdsumBottomNav(items: items, currentIndex: currentDisplay, onTap: go),
    );
  }
}

class _MenuFab extends StatelessWidget {
  final VoidCallback onTap;
  const _MenuFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
          ),
          child: const Icon(Icons.menu_rounded, color: AppColors.primary),
        ),
      ),
    );
  }
}
