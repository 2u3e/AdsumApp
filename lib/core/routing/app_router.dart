import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notification_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_create_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_detail_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_list_screen.dart';
import '../theme/app_colors.dart';
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
      GoRoute(path: RoutePaths.splash, name: RouteNames.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.login, name: RouteNames.login, builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _AdsumShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.home, name: RouteNames.home, builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RoutePaths.workOrders, name: RouteNames.workOrders,
              builder: (context, state) => const WorkOrderListScreen(),
              routes: [
                GoRoute(path: 'create', name: RouteNames.workOrderCreate, builder: (context, state) => const WorkOrderCreateScreen()),
                GoRoute(path: ':id', name: RouteNames.workOrderDetail, builder: (context, state) => WorkOrderDetailScreen(workOrderId: state.pathParameters['id']!)),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.notifications, name: RouteNames.notifications, builder: (context, state) => const NotificationListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: RoutePaths.profile, name: RouteNames.profile, builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
});

/// Attached premium bottom navigation bar
class _AdsumShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _AdsumShell({required this.navigationShell});

  static const _items = [
    _NavItem(icon: Icons.space_dashboard_outlined, activeIcon: Icons.space_dashboard_rounded, label: 'Panel'),
    _NavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'İşler'),
    _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications_rounded, label: 'Bildirim'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray900 : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.gray800 : AppColors.gray200,
              width: 0.8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: bottomPadding > 0 ? 6 : 10, left: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = navigationShell.currentIndex == index;
                return _NavBarButton(
                  item: item,
                  isSelected: isSelected,
                  showBadge: index == 2,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
                  },
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

class _NavBarButton extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool showBadge;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.isSelected,
    this.showBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.gray800 : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                item.label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
