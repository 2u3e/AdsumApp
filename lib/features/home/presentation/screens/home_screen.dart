import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../work_orders/data/mock_work_orders.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey _heroCardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareReport() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    HapticFeedback.lightImpact();

    try {
      final boundary = _heroCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }

      // Kisa gecikme - paylaş butonunun saf kart görünümünde çekilmesi icin
      await Future.delayed(const Duration(milliseconds: 50));

      final now = DateTime.now();
      const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
      final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

      await ShareService.captureAndShare(
        boundary,
        text: 'ADSUM İş Emri Raporu - $dateStr',
        subject: 'ADSUM Rapor',
        fileName: 'adsum_rapor',
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = DashboardStats.fromWorkOrders(mockWorkOrders);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
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
                      Row(
                        children: [
                          // Paylas butonu
                          GestureDetector(
                            onTap: _shareReport,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.gray800 : AppColors.gray100,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: _isSharing
                                  ? Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: isDark ? AppColors.gray300 : AppColors.gray600,
                                        ),
                                      ),
                                    )
                                  : Icon(Icons.ios_share_rounded, size: 20,
                                      color: isDark ? AppColors.gray300 : AppColors.gray600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Bildirim butonu
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Hero rapor karti - RepaintBoundary ile paylaşım için
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RepaintBoundary(
                    key: _heroCardKey,
                    child: _HeroStatsCard(stats: stats),
                  ),
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

/// Hero kart - ust satir: toplam + tamamlanan; alt satir: 1x3 stat
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
          // Ust satir: Toplam Acik + Tamamlanan
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Sol: Toplam Acik Is Emri
                Expanded(
                  child: _HeadlineStat(
                    label: 'Toplam Açık İş Emri',
                    value: stats.totalCount,
                    valueColor: Colors.white,
                    valueSize: 48,
                  ),
                ),
                // Sag: Tamamlanan - yesil sayi
                _HeadlineStat(
                  label: 'Tamamlanan',
                  value: stats.completedCount,
                  valueColor: const Color(0xFF6EE7B7), // acik yesil
                  valueSize: 38,
                  alignEnd: true,
                ),
              ],
            ),
          ),

          // Ayirac cizgi
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.white.withValues(alpha: 0.18),
          ),

          // Alt satir: 1x3 stat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Row(
              children: [
                _StatTile(
                  label: 'Dünden',
                  value: stats.yesterdayCount,
                  valueColor: Colors.white,
                ),
                _verticalDivider(),
                _StatTile(
                  label: 'Bugün',
                  value: stats.todayCount,
                  valueColor: Colors.white,
                ),
                _verticalDivider(),
                _StatTile(
                  label: 'Devam Eden',
                  value: stats.inProgressCount,
                  valueColor: const Color(0xFFFCD34D), // soft amber/sari
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

/// Ust satirdaki buyuk stat (Toplam + Tamamlanan)
class _HeadlineStat extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;
  final double valueSize;
  final bool alignEnd;

  const _HeadlineStat({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueSize,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$value',
              style: TextStyle(
                color: valueColor,
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                'adet',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Alt satirdaki stat - sadece rakam + label, ikonsuz
class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  color: valueColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  'adet',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
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
