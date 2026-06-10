import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../work_orders/data/mock_work_orders.dart';
import '../../../work_orders/domain/entities/work_enums.dart';
import '../../../work_orders/domain/entities/work_order.dart';

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
      final boundary =
          _heroCardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        setState(() => _isSharing = false);
        return;
      }
      await Future.delayed(const Duration(milliseconds: 50));
      const months = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
      final now = DateTime.now();
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
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final stats = DashboardStats.fromWorkOrders(mockWorkOrders);
    final userName = ref.watch(authStateProvider).value?.user?.firstName ?? 'Yönetici';
    final recent = mockWorkOrders.take(4).toList();

    final blocks = <Widget>[
      _Header(
        userName: userName,
        isDark: isDark,
        isSharing: _isSharing,
        onShare: _shareReport,
        onBell: () => StatefulNavigationShell.of(context).goBranch(2),
      ),
      const SizedBox(height: 22),
      RepaintBoundary(
        key: _heroCardKey,
        child: _HeroStatsCard(stats: stats, animate: !reduce),
      ),
      const SizedBox(height: 22),
      _StatusDistribution(orders: mockWorkOrders, isDark: isDark),
      const SizedBox(height: 24),
      _SectionTitle(title: 'Hızlı İşlemler'),
      const SizedBox(height: 12),
      _QuickActions(),
      const SizedBox(height: 26),
      _SectionTitle(
        title: 'Son İş Emirleri',
        actionLabel: 'Tümü',
        onAction: () => StatefulNavigationShell.of(context).goBranch(1),
      ),
      const SizedBox(height: 12),
      ...recent.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RecentWorkCard(
              order: w,
              isDark: isDark,
              onTap: () => context.push('/work-orders/${w.id}'),
            ),
          )),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 700)),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: blocks
                  .animate(interval: 60.ms)
                  .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: reduce ? 0 : 0.12, end: 0, duration: 380.ms, curve: Curves.easeOutCubic),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Header — selamlama + aksiyon ikonlari
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  final bool isDark;
  final bool isSharing;
  final VoidCallback onShare;
  final VoidCallback onBell;
  const _Header({
    required this.userName,
    required this.isDark,
    required this.isSharing,
    required this.onShare,
    required this.onBell,
  });

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 6) return 'İyi geceler';
    if (h < 12) return 'Günaydın';
    if (h < 18) return 'İyi günler';
    return 'İyi akşamlar';
  }

  String get _dateLine {
    const months = ['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran','Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    const days = ['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];
    final n = DateTime.now();
    return '${days[n.weekday - 1]}, ${n.day} ${months[n.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateLine,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      letterSpacing: 0.3,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                '$_greeting, $userName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
        _IconBtn(
          icon: Icons.ios_share_rounded,
          isDark: isDark,
          loading: isSharing,
          onTap: onShare,
        ),
        const SizedBox(width: 10),
        _IconBtn(
          icon: Icons.notifications_outlined,
          isDark: isDark,
          badge: true,
          onTap: onBell,
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool loading;
  final bool badge;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.isDark,
    this.loading = false,
    this.badge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray800 : AppColors.gray100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: loading
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
            : Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 21, color: isDark ? AppColors.gray300 : AppColors.gray600),
                  if (badge)
                    Positioned(
                      right: 11,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hero stats kart — count-up + derin gradient
// ─────────────────────────────────────────────────────────────
class _HeroStatsCard extends StatelessWidget {
  final DashboardStats stats;
  final bool animate;
  const _HeroStatsCard({required this.stats, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Kose parlamasi
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: _HeadlineStat(
                        label: 'Toplam Açık İş Emri',
                        value: stats.totalCount,
                        valueColor: Colors.white,
                        valueSize: 46,
                        animate: animate,
                      ),
                    ),
                    _HeadlineStat(
                      label: 'Tamamlanan',
                      value: stats.completedCount,
                      valueColor: const Color(0xFF6EE7B7),
                      valueSize: 36,
                      alignEnd: true,
                      animate: animate,
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 18),
                color: Colors.white.withValues(alpha: 0.16),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                child: Row(
                  children: [
                    _StatTile(label: 'Dünden', value: stats.yesterdayCount, valueColor: Colors.white, animate: animate),
                    _miniDivider(),
                    _StatTile(label: 'Bugün', value: stats.todayCount, valueColor: Colors.white, animate: animate),
                    _miniDivider(),
                    _StatTile(label: 'Devam Eden', value: stats.inProgressCount, valueColor: const Color(0xFFFCD34D), animate: animate),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniDivider() => Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.15));
}

/// 0'dan hedefe sayan animasyonlu rakam
class _CountUp extends StatelessWidget {
  final int value;
  final TextStyle style;
  final bool animate;
  const _CountUp({required this.value, required this.style, required this.animate});

  @override
  Widget build(BuildContext context) {
    if (!animate) return Text('$value', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('${v.round()}', style: style),
    );
  }
}

class _HeadlineStat extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;
  final double valueSize;
  final bool alignEnd;
  final bool animate;
  const _HeadlineStat({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueSize,
    this.alignEnd = false,
    required this.animate,
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
            _CountUp(
              value: value,
              animate: animate,
              style: TextStyle(color: valueColor, fontSize: valueSize, fontWeight: FontWeight.w800, height: 1),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('adet', style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color valueColor;
  final bool animate;
  const _StatTile({required this.label, required this.value, required this.valueColor, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _CountUp(
            value: value,
            animate: animate,
            style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.w800, height: 1),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11.5, fontWeight: FontWeight.w500, letterSpacing: 0.2),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Durum dagilimi — segment bar + legend
// ─────────────────────────────────────────────────────────────
class _StatusDistribution extends StatelessWidget {
  final List<WorkOrder> orders;
  final bool isDark;
  const _StatusDistribution({required this.orders, required this.isDark});

  @override
  Widget build(BuildContext context) {
    const shown = [
      WorkStatus.pending,
      WorkStatus.inTransit,
      WorkStatus.inProgress,
      WorkStatus.onHold,
      WorkStatus.completed,
    ];
    final counts = {for (final s in shown) s: orders.where((o) => o.status == s).length};
    final total = counts.values.fold<int>(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Durum Dağılımı', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('$total iş emri',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
            ],
          ),
          const SizedBox(height: 14),
          // Segment bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                for (final s in shown)
                  if (counts[s]! > 0)
                    Expanded(
                      flex: counts[s]!,
                      child: Container(
                        height: 10,
                        margin: const EdgeInsets.only(right: 2),
                        color: s.color,
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final s in shown)
                if (counts[s]! > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 9, height: 9, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(s.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      const SizedBox(width: 4),
                      Text('${counts[s]}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bolum basligi
// ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _SectionTitle({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(actionLabel!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Hizli islemler
// ─────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      (_AQ(Icons.add_circle_outline_rounded, 'Yeni İş Emri', [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          () => context.push('/work-orders/create'))),
      (_AQ(Icons.assignment_outlined, 'İş Emirleri', [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
          () => StatefulNavigationShell.of(context).goBranch(1))),
      (_AQ(Icons.map_outlined, 'Harita', [const Color(0xFF10B981), const Color(0xFF059669)], () {})),
      (_AQ(Icons.notifications_none_rounded, 'Bildirimler', [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          () => StatefulNavigationShell.of(context).goBranch(2))),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: _ActionCard(item: items[i])),
          if (i < items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _AQ {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  _AQ(this.icon, this.label, this.gradient, this.onTap);
}

class _ActionCard extends StatefulWidget {
  final _AQ item;
  const _ActionCard({required this.item});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.selectionClick();
        it.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.gray200,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: it.gradient),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(color: it.gradient.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Icon(it.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                it.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Son is emri karti
// ─────────────────────────────────────────────────────────────
class _RecentWorkCard extends StatelessWidget {
  final WorkOrder order;
  final bool isDark;
  final VoidCallback onTap;
  const _RecentWorkCard({required this.order, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
        ),
        child: Row(
          children: [
            // Durum ikonlu sekme
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: order.status.color.withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(order.status.icon, color: order.status.color, size: 22),
            ),
            const SizedBox(width: 12),
            // Orta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.workTypeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (order.priority.value >= WorkPriority.high.value) ...[
                        Icon(order.priority.icon, size: 14, color: order.priority.color),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 13, color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${order.neighborhood}, ${order.district}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatusChip(status: order.status),
                      const Spacer(),
                      Text(order.workNumber,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final WorkStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: status.color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
