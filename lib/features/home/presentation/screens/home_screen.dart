import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Ana sayfa / Dashboard ekrani
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Bildirimler sayfasina git
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Dashboard verilerini yenile
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalLg,

              // Istatistik kartlari
              _StatsGrid(),

              AppSpacing.verticalXl,

              // Hizli aksiyonlar
              Text(
                'Hızlı İşlemler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              AppSpacing.verticalMd,
              _QuickActions(),

              AppSpacing.verticalXl,

              // Son is emirleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Son İş Emirleri',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // Tum is emirleri sayfasina git
                    },
                    child: const Text('Tümünü Gör'),
                  ),
                ],
              ),
              AppSpacing.verticalSm,

              // Placeholder - API baglandiginda gercek veri gelecek
              _EmptyWorkOrdersPlaceholder(),
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

/// Istatistik grid'i
class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: const [
        _StatCard(
          title: 'Açık İş Emri',
          value: '--',
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Bugün Bitmeli',
          value: '--',
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
        ),
        _StatCard(
          title: 'Geciken',
          value: '--',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
        ),
        _StatCard(
          title: 'Tamamlanan',
          value: '--',
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.success,
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
              // TODO: Is emri olusturma sayfasi
            },
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _QuickActionButton(
            icon: Icons.person_outline_rounded,
            label: 'Atananlarım',
            color: AppColors.info,
            onTap: () {
              // TODO: Bana atanan is emirleri filtresi
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
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
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

/// Bos is emri placeholder
class _EmptyWorkOrdersPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: isDark ? AppColors.gray600 : AppColors.gray300,
            ),
            AppSpacing.verticalMd,
            Text(
              'Henüz iş emri verisi yok',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
            ),
            AppSpacing.verticalXs,
            Text(
              'API bağlantısı kurulduğunda veriler burada görünecek',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
