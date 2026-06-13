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
      duration: const Duration(milliseconds: 800),
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
    // Beklemeden hemen kontrol et; oturum hazır olduğunda anında yönlendir
    // (uzun splash yok). Hazır değilse kısa aralıklarla tekrar dener.
    _checkAuth();
  }

  int _authCheckAttempts = 0;

  Future<void> _checkAuth() async {
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (state) {
        context.go(state.isAuthenticated ? RoutePaths.home : RoutePaths.login);
      },
      // Auth henüz hazır değilse kısa aralıkla tekrar dene; en fazla ~7,5 sn sonra
      // login'e düş (splash kilitlenmesin).
      loading: () {
        if (_authCheckAttempts++ < 30) {
          Future.delayed(const Duration(milliseconds: 250), _checkAuth);
        } else {
          context.go(RoutePaths.login);
        }
      },
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
                // Logo - uygulama iconu (beyaz kart icinde)
                Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => const Icon(
                        Icons.location_city_rounded,
                        size: 56,
                        color: AppColors.primary,
                      ),
                    ),
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
