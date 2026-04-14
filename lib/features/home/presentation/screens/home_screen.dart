import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../work_orders/data/mock_work_orders.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = DashboardStats.fromWorkOrders(mockWorkOrders);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Gösterge Paneli',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          final shell = StatefulNavigationShell.of(context);
                          shell.goBranch(2);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.gray800 : AppColors.gray100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.notifications_outlined, size: 22,
                                  color: isDark ? AppColors.gray300 : AppColors.gray600),
                              Positioned(
                                right: 11, top: 10,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.gray800 : AppColors.gray100,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Hero rapor karti - 5 veri
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _HeroStatsCard(stats: stats),
                ),
                const SizedBox(height: 28),

                // Hizli islemler
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Hızlı İşlemler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _ActionCard(
                        icon: Icons.add_circle_rounded,
                        label: 'Yeni İş Emri',
                        gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        onTap: () => context.push('/work-orders/create'),
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _ActionCard(
                        icon: Icons.map_rounded,
                        label: 'Harita',
                        gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                        onTap: () {},
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }
}

/// Hero kart - toplam ust, 4 mini stat altta 2x2 grid
class _HeroStatsCard extends StatelessWidget {
  final DashboardStats stats;
  const _HeroStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF60A5FA)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ust: toplam
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol: etiket + rakam
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment_rounded, color: Colors.white.withValues(alpha: 0.9), size: 16),
                          const SizedBox(width: 6),
                          const Text(
                            'Toplam Açık İş Emri',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${stats.totalCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'adet',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Sag: formul bilgisi
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stats.yesterdayCount} + ${stats.todayCount}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '− ${stats.completedCount}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ayirac cizgi
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white.withValues(alpha: 0.2),
          ),

          // Alt: 4 stat 2x2 grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatTile(
                      icon: Icons.history_rounded,
                      label: 'Dünden Kalan',
                      value: stats.yesterdayCount,
                    ),
                    _verticalDivider(),
                    _StatTile(
                      icon: Icons.today_rounded,
                      label: 'Bugün Gelen',
                      value: stats.todayCount,
                      isHighlighted: true,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
                ),
                Row(
                  children: [
                    _StatTile(
                      icon: Icons.autorenew_rounded,
                      label: 'Devam Eden',
                      value: stats.inProgressCount,
                    ),
                    _verticalDivider(),
                    _StatTile(
                      icon: Icons.check_circle_rounded,
                      label: 'Tamamlanan',
                      value: stats.completedCount,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

/// 2x2 gridde tek stat kutusu
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final bool isHighlighted;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isHighlighted ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1),
                ),
                Text(
                  label,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 10.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
