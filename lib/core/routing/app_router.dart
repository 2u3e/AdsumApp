import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notifications/presentation/screens/notification_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_detail_screen.dart';
import '../../features/work_orders/presentation/screens/work_order_list_screen.dart';
import 'route_names.dart';

/// Ana router provider'i
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,

    // Auth redirect - giris kontrolu
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isAuthenticated ?? false;
      final isOnSplash = state.matchedLocation == RoutePaths.splash;
      final isOnLogin = state.matchedLocation == RoutePaths.login;

      // Splash ekranindaysa birak (kendi kontrolu yapar)
      if (isOnSplash) return null;

      // Giris yapilmamissa login'e yonlendir
      if (!isLoggedIn && !isOnLogin) return RoutePaths.login;

      // Giris yapilmissa ve login sayfasindaysa ana sayfaya yonlendir
      if (isLoggedIn && isOnLogin) return RoutePaths.home;

      return null;
    },

    routes: [
      // Splash
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Ana kabuk - Bottom Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Work Orders tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.workOrders,
                name: RouteNames.workOrders,
                builder: (context, state) => const WorkOrderListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.workOrderDetail,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return WorkOrderDetailScreen(workOrderId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Notifications tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.notifications,
                name: RouteNames.notifications,
                builder: (context, state) => const NotificationListScreen(),
              ),
            ],
          ),

          // Profile tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// Ana kabuk - Bottom Navigation Bar iceren scaffold
class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'İş Emirleri',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Bildirimler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
