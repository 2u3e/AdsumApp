import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/share_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../work_orders/data/mobile_menu_provider.dart';
import '../../../work_orders/data/mobile_stats_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final userName = ref.watch(authStateProvider.select((s) => s.value?.user?.firstName)) ?? 'Yönetici';
    final canUnit = ref.watch(canSeeUnitWorksProvider);

    // Rapor kartları: Ekip / Bana / Birim
    final cards = <_CardSpec>[
      _CardSpec(ReportScope.team, 'Ekip İşleri', const [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFF8B5CF6)]),
      _CardSpec(ReportScope.personal, 'Bana Atanan', const [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)]),
      if (canUnit)
        _CardSpec(ReportScope.unit, 'Birim İşleri', const [Color(0xFF0E7490), Color(0xFF0891B2), Color(0xFF06B6D4)]),
    ];

    final blocks = <Widget>[
      _Header(
        userName: userName,
        isDark: isDark,
        onBell: () => StatefulNavigationShell.of(context).goBranch(3),
      ),
      const SizedBox(height: 16),
      const _PeriodSelector(),
      const SizedBox(height: 12),
      _StatCarousel(cards: cards, animate: !reduce),
      const SizedBox(height: 26),
      _SectionTitle(title: 'Hızlı İşlemler'),
      const SizedBox(height: 12),
      const _QuickActions(),
      const SizedBox(height: 18),
      Center(
        child: Text('Sürüm ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                  letterSpacing: 0.4,
                )),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            for (final s in ReportScope.values) {
              for (final p in ReportPeriod.values) {
                ref.invalidate(mobileStatsProvider((s, p)));
              }
            }
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: blocks
                  .animate(interval: 55.ms)
                  .fadeIn(duration: 360.ms, curve: Curves.easeOutCubic)
                  .slideY(begin: reduce ? 0 : 0.1, end: 0, duration: 360.ms, curve: Curves.easeOutCubic),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSpec {
  final ReportScope scope;
  final String title;
  final List<Color> gradient;
  _CardSpec(this.scope, this.title, this.gradient);
}

// ─────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  final bool isDark;
  final VoidCallback onBell;
  const _Header({required this.userName, required this.isDark, required this.onBell});

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
              Text(_dateLine,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        letterSpacing: 0.3,
                      )),
              const SizedBox(height: 3),
              Text('$_greeting, $userName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        _IconBtn(icon: Icons.notifications_outlined, isDark: isDark, badge: true, onTap: onBell),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final bool badge;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.isDark, this.badge = false, required this.onTap});

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
        child: Stack(
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
                    border: Border.all(color: isDark ? AppColors.gray800 : AppColors.gray100, width: 1.5),
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
// Dönem seçici (Günlük / Haftalık / Aylık)
// ─────────────────────────────────────────────────────────────
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final period = ref.watch(reportPeriodProvider);
    final fill = isDark ? AppColors.gray800 : AppColors.gray100;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final p in ReportPeriod.values)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(reportPeriodProvider.notifier).state = p;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: p == period ? (isDark ? AppColors.cardDark : Colors.white) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: p == period
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p == period ? AppColors.primary : (isDark ? AppColors.gray400 : AppColors.gray500),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Kaydırmalı rapor kartları
// ─────────────────────────────────────────────────────────────
class _StatCarousel extends StatefulWidget {
  final List<_CardSpec> cards;
  final bool animate;
  const _StatCarousel({required this.cards, required this.animate});

  @override
  State<_StatCarousel> createState() => _StatCarouselState();
}

class _StatCarouselState extends State<_StatCarousel> {
  final _controller = PageController(viewportFraction: 0.94);
  int _page = 0;
  late List<GlobalKey> _keys;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.cards.length, (_) => GlobalKey());
  }

  @override
  void didUpdateWidget(covariant _StatCarousel old) {
    super.didUpdateWidget(old);
    if (old.cards.length != widget.cards.length) {
      _keys = List.generate(widget.cards.length, (_) => GlobalKey());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share(int i) async {
    final ctx = _keys[i].currentContext;
    final boundary = ctx?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    HapticFeedback.lightImpact();
    await ShareService.captureAndShare(boundary,
        subject: '${widget.cards[i].title} Raporu', fileName: 'adsum_rapor');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 186,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: widget.cards.length,
            itemBuilder: (_, i) => Padding(
              padding: EdgeInsets.only(right: i == widget.cards.length - 1 ? 0 : 10),
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: _keys[i],
                    child: _StatCard(spec: widget.cards[i], animate: widget.animate),
                  ),
                  Positioned(
                    top: 10,
                    right: 12,
                    child: _ShareBtn(onTap: () => _share(i)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.cards.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.gray300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ShareBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _ShareBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(7),
          child: Icon(Icons.ios_share_rounded, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}

class _StatCard extends ConsumerWidget {
  final _CardSpec spec;
  final bool animate;
  const _StatCard({required this.spec, required this.animate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final async = ref.watch(mobileStatsProvider((spec.scope, period)));
    final stats = async.valueOrNull ?? const MobileStats();
    final loading = async.isLoading && !async.hasValue;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: spec.gradient),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: spec.gradient[1].withValues(alpha: 0.34), blurRadius: 22, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0)]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spec.title,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('Toplam bekleyen',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40), // paylaş butonuna yer
                    loading
                        ? const Padding(
                            padding: EdgeInsets.only(top: 6, right: 8),
                            child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
                          )
                        : _CountUp(
                            value: stats.total,
                            animate: animate,
                            style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800, height: 1),
                          ),
                  ],
                ),
                const Spacer(),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Sub(label: 'Devreden', value: stats.carriedOver, animate: animate),
                    _miniDivider(),
                    _Sub(label: 'Gelen', value: stats.arrived, animate: animate),
                    _miniDivider(),
                    _Sub(label: 'Devam', value: stats.inProgress, animate: animate),
                    _miniDivider(),
                    _Sub(label: 'Tamamlanan', value: stats.completed, animate: animate),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDivider() => Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.15));
}

class _Sub extends StatelessWidget {
  final String label;
  final int value;
  final bool animate;
  const _Sub({required this.label, required this.value, required this.animate});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          _CountUp(value: value, animate: animate,
              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10.5, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

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
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text('${v.round()}', style: style),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bölüm başlığı + hızlı işlemler
// ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700));
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final items = [
      _AQ(Icons.add_circle_outline_rounded, 'Yeni İş', [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          () => context.push('/work-orders/create')),
      _AQ(Icons.assignment_outlined, 'Atanan', [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
          () => StatefulNavigationShell.of(context).goBranch(1)),
      _AQ(Icons.map_outlined, 'Harita', [const Color(0xFF10B981), const Color(0xFF059669)], () {}),
      _AQ(Icons.notifications_none_rounded, 'Bildirim', [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          () => StatefulNavigationShell.of(context).goBranch(3)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.gray200),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: it.gradient),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [BoxShadow(color: it.gradient.first.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Icon(it.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(it.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
