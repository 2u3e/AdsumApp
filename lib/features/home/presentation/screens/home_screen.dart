import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../work_orders/data/mock_work_orders.dart';

/// Ana sayfa / Dashboard ekrani
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = DashboardStats.fromWorkOrders(mockWorkOrders);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
            Text(
              user?.fullName ?? 'Kullanıcı',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // Bildirimler sekmesine git (index 2)
              final shell = StatefulNavigationShell.of(context);
              shell.goBranch(2);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalLg,
              _StatsSection(stats: stats),
              AppSpacing.verticalXl,
              Text(
                'Hızlı İşlemler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.verticalMd,
              const _QuickActions(),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }
}

/// Istatistik kartlari - 5 adet, ilk satir 3, ikinci satir 2
class _StatsSection extends StatelessWidget {
  final DashboardStats stats;
  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ilk satir: 3 kart
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Açık',
                value: '${stats.openCount}',
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: _StatCard(
                title: 'Bugün Gelen',
                value: '${stats.todayCount}',
                icon: Icons.today_rounded,
                color: AppColors.info,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: _StatCard(
                title: 'Dünden',
                value: '${stats.yesterdayCount}',
                icon: Icons.history_rounded,
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
        AppSpacing.verticalMd,
        // Ikinci satir: 2 kart
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Devam Eden',
                value: '${stats.inProgressCount}',
                icon: Icons.autorenew_rounded,
                color: AppColors.warning,
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: _StatCard(
                title: 'Tamamlanan',
                value: '${stats.completedCount}',
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tek istatistik karti
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            AppSpacing.verticalXs,
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hizli aksiyonlar
class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: 'Yeni İş Emri',
            color: AppColors.primary,
            onTap: () {
              context.push('/work-orders/create');
            },
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _QuickActionButton(
            icon: Icons.map_outlined,
            label: 'Harita',
            color: AppColors.success,
            onTap: () {
              // TODO: Harita gorunumu
            },
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            AppSpacing.verticalSm,
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
