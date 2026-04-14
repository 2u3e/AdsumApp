import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';

/// Splash ekrani - uygulama acilisinda auth durumunu kontrol eder
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    // 2 saniye sonra auth kontrolu yap ve yonlendir
    Future.delayed(const Duration(seconds: 2), checkAuthAndNavigate);
  }

  Future<void> checkAuthAndNavigate() async {
    if (!mounted) return;

    final authState = ref.read(authStateProvider);

    authState.when(
      data: (state) {
        if (state.isAuthenticated) {
          context.go(RoutePaths.home);
        } else {
          context.go(RoutePaths.login);
        }
      },
      loading: () {
        // Henuz yukleniyor, biraz daha bekle
        Future.delayed(const Duration(seconds: 1), checkAuthAndNavigate);
      },
      error: (_, _) {
        context.go(RoutePaths.login);
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo placeholder - gercek logo eklendiginde degistirilecek
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.borderRadiusLg,
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              AppSpacing.verticalXl,
              Text(
                'ADSUM',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
              ),
              AppSpacing.verticalSm,
              Text(
                'Belediye Yönetim Sistemi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
