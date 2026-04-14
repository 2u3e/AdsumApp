import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';

/// Splash ekrani - profesyonel acilis animasyonu
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeIn)),
    );

    _slideUp = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );

    _controller.forward();
    Future.delayed(const Duration(seconds: 2), _checkAuth);
  }

  Future<void> _checkAuth() async {
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
      loading: () => Future.delayed(const Duration(seconds: 1), _checkAuth),
      error: (_, _) => context.go(RoutePaths.login),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo - gradient circle with icon
                Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.location_city_rounded, size: 56, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 32),

                // App name
                Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Column(
                      children: [
                        Text(
                          'ADSUM',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: isDark ? Colors.white : AppColors.gray900,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 6,
                              ),
                        ),
                        AppSpacing.verticalSm,
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: AppSpacing.borderRadiusFull,
                          ),
                        ),
                        AppSpacing.verticalMd,
                        Text(
                          'Belediye Yönetim Sistemi',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                letterSpacing: 1,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
