import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_work_orders.dart';
import '../../domain/entities/work_enums.dart';
import '../../domain/entities/work_order.dart';

class WorkOrderListScreen extends ConsumerStatefulWidget {
  const WorkOrderListScreen({super.key});

  @override
  ConsumerState<WorkOrderListScreen> createState() => _WorkOrderListScreenState();
}

/// Siralama secenekleri
enum WorkSortBy {
  smart('Akıllı (Varsayılan)', Icons.auto_awesome_rounded),
  createdNewest('En Yeni İşler', Icons.schedule_rounded),
  createdOldest('En Eski İşler', Icons.history_rounded),
  workNumber('İş Numarası', Icons.numbers_rounded),
  workType('İş Türü', Icons.category_rounded),
  address('Adres', Icons.location_on_outlined),
  priority('Öncelik', Icons.flag_rounded);

  final String label;
  final IconData icon;
  const WorkSortBy(this.label, this.icon);
}

/// Durum siralama agirliklari - devam eden ustte, tamamlanan altta
int _statusOrder(WorkStatus s) {
  return switch (s) {
    WorkStatus.inProgress => 1,
    WorkStatus.inTransit => 2,
    WorkStatus.onHold => 3,
    WorkStatus.pending => 4,
    WorkStatus.draft => 5,
    WorkStatus.completed => 6,
    WorkStatus.cancelled => 7,
  };
}

class _WorkOrderListScreenState extends ConsumerState<WorkOrderListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Set<WorkStatus> _selectedStatuses = {};
  Set<WorkPriority> _selectedPriorities = {};
  String _addressFilter = '';
  WorkSortBy _sortBy = WorkSortBy.smart;

  List<WorkOrder> get _filteredOrders {
    var orders = mockWorkOrders.toList();
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      orders = orders.where((w) =>
          w.workNumber.toLowerCase().contains(q) ||
          w.workTypeName.toLowerCase().contains(q) ||
          w.fullAddress.toLowerCase().contains(q) ||
          w.neighborhood.toLowerCase().contains(q) ||
          (w.street?.toLowerCase().contains(q) ?? false) ||
          (w.applicantName?.toLowerCase().contains(q) ?? false) ||
          (w.assigneeName?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (_addressFilter.isNotEmpty) {
      final q = _addressFilter.toLowerCase();
      orders = orders.where((w) =>
          w.fullAddress.toLowerCase().contains(q) ||
          w.neighborhood.toLowerCase().contains(q) ||
          (w.street?.toLowerCase().contains(q) ?? false) ||
          w.district.toLowerCase().contains(q)).toList();
    }
    if (_selectedStatuses.isNotEmpty) {
      orders = orders.where((w) => _selectedStatuses.contains(w.status)).toList();
    }
    if (_selectedPriorities.isNotEmpty) {
      orders = orders.where((w) => _selectedPriorities.contains(w.priority)).toList();
    }

    // DURUM ONCELIGI HER ZAMAN UYGULANIR
    // Devam edenler ustte, tamamlananlar altta, diger siralama ayni durum icinde
    orders.sort((a, b) {
      final statusDiff = _statusOrder(a.status).compareTo(_statusOrder(b.status));
      if (statusDiff != 0) return statusDiff;
      return _secondarySort(a, b);
    });
    return orders;
  }

  int _secondarySort(WorkOrder a, WorkOrder b) {
    switch (_sortBy) {
      case WorkSortBy.smart:
        // Oncelik yuksek ustte, sonra yeni tarih
        final p = b.priority.value.compareTo(a.priority.value);
        if (p != 0) return p;
        return b.createdAt.compareTo(a.createdAt);
      case WorkSortBy.createdNewest:
        return b.createdAt.compareTo(a.createdAt);
      case WorkSortBy.createdOldest:
        return a.createdAt.compareTo(b.createdAt);
      case WorkSortBy.workNumber:
        return b.workNumber.compareTo(a.workNumber);
      case WorkSortBy.workType:
        return a.workTypeName.compareTo(b.workTypeName);
      case WorkSortBy.address:
        return a.fullAddress.compareTo(b.fullAddress);
      case WorkSortBy.priority:
        return b.priority.value.compareTo(a.priority.value);
    }
  }

  int get _activeFilterCount {
    int c = 0;
    if (_selectedStatuses.isNotEmpty) c++;
    if (_selectedPriorities.isNotEmpty) c++;
    if (_addressFilter.isNotEmpty) c++;
    return c;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = _filteredOrders;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  if (!_isSearching)
                    Expanded(
                      child: Text('İş Emirleri',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                  if (_isSearching)
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.gray800 : AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'İş no, tür, adres, kişi...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search, size: 20,
                                color: isDark ? AppColors.gray500 : AppColors.gray400),
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(_isSearching ? Icons.close : Icons.search_rounded, size: 22),
                    onPressed: () => setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) { _searchController.clear(); _searchQuery = ''; }
                    }),
                  ),
                  // Siralama butonu
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_vert_rounded, size: 22),
                        onPressed: () => _showSortSheet(context),
                        tooltip: 'Sırala',
                      ),
                      if (_sortBy != WorkSortBy.smart)
                        Positioned(right: 10, top: 10, child: Container(
                          width: 7, height: 7,
                          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        )),
                    ],
                  ),
                  // Filtre butonu
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 22),
                        onPressed: () => _showFilterSheet(context),
                        tooltip: 'Filtrele',
                      ),
                      if (_activeFilterCount > 0)
                        Positioned(right: 6, top: 6, child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          child: Center(child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                        )),
                    ],
                  ),
                  const SizedBox(width: 4),
                  // Yeni is emri butonu
                  GestureDetector(
                    onTap: () => context.push('/work-orders/create'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),

            // Liste
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async { await Future.delayed(const Duration(seconds: 1)); setState(() {}); },
                child: orders.isEmpty
                    ? _buildEmpty(context, isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return Dismissible(
                            key: Key(order.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              HapticFeedback.mediumImpact();
                              _showQuickActions(context, order);
                              return false;
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.more_horiz_rounded, color: AppColors.primary),
                            ),
                            child: _WorkCard(
                              order: order,
                              onTap: () => context.push('/work-orders/${order.id}'),
                              onLongPress: () { HapticFeedback.mediumImpact(); _showQuickActions(context, order); },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, bool isDark) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.search_off_rounded, size: 56, color: isDark ? AppColors.gray600 : AppColors.gray300),
      AppSpacing.verticalMd,
      Text('Sonuç bulunamadı', style: Theme.of(context).textTheme.titleMedium),
    ]));
  }

  void _showQuickActions(BuildContext context, WorkOrder order) {
    showModalBottomSheet(context: context, builder: (context) => SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull)),
        ListTile(leading: const Icon(Icons.visibility_rounded, color: AppColors.primary),
          title: const Text('Detay'), onTap: () { Navigator.pop(context); context.push('/work-orders/${order.id}'); }),
        if (order.status != WorkStatus.completed && order.status != WorkStatus.cancelled) ...[
          ListTile(leading: const Icon(Icons.directions_car_rounded, color: AppColors.info),
            title: const Text('İntikal Et'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.play_circle_outline_rounded, color: AppColors.success),
            title: const Text('Başla'), onTap: () => Navigator.pop(context)),
        ],
      ]),
    )));
  }

  void _showFilterSheet(BuildContext context) {
    final tmpS = Set<WorkStatus>.from(_selectedStatuses);
    final tmpP = Set<WorkPriority>.from(_selectedPriorities);
    final addrCtrl = TextEditingController(text: _addressFilter);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(builder: (context, setS) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, sc) => Column(
            children: [
              // Fixed header
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 12),
                  decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Filtrele', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              // Scrollable filters
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Text('Adres / Mahalle / Cadde', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addrCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Örn: Tecde, İnönü Caddesi...',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Durum', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WorkStatus.values.map((s) => _ColoredFilterChip(
                        label: s.label,
                        color: s.color,
                        selected: tmpS.contains(s),
                        onTap: () => setS(() => tmpS.contains(s) ? tmpS.remove(s) : tmpS.add(s)),
                      )).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Öncelik', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WorkPriority.values.map((p) => _ColoredFilterChip(
                        label: p.label,
                        color: p.color,
                        selected: tmpP.contains(p),
                        onTap: () => setS(() => tmpP.contains(p) ? tmpP.remove(p) : tmpP.add(p)),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Sticky footer with action buttons
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatuses = {};
                            _selectedPriorities = {};
                            _addressFilter = '';
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Temizle'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatuses = tmpS;
                            _selectedPriorities = tmpP;
                            _addressFilter = addrCtrl.text.trim();
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Uygula', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Siralama secim sheet'i
  void _showSortSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                children: [
                  const Icon(Icons.swap_vert_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('Sırala', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Devam edenler her zaman en üstte, tamamlananlar en altta görünür.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: WorkSortBy.values.length,
                itemBuilder: (context, index) {
                  final sort = WorkSortBy.values[index];
                  final selected = _sortBy == sort;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _sortBy = sort);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      color: selected ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08) : null,
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                                  : isDark ? AppColors.gray800 : AppColors.gray100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              sort.icon,
                              size: 18,
                              color: selected ? AppColors.primary : (isDark ? AppColors.gray400 : AppColors.gray500),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              sort.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? AppColors.primary : null,
                              ),
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ozel renkli filtre chip'i - secili/secilmemis durumlar net
class _ColoredFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColoredFilterChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.22 : 0.12)
              : isDark ? AppColors.gray800 : AppColors.gray100,
          borderRadius: AppSpacing.borderRadiusFull,
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded, size: 14, color: color),
              const SizedBox(width: 5),
            ] else ...[
              Container(
                width: 7, height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? color
                    : isDark ? AppColors.textSecondaryDark : AppColors.textPrimaryLight,
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Is turune gore ikon esleme
IconData _workTypeIcon(String type) {
  final t = type.toLowerCase();
  if (t.contains('asfalt') || t.contains('yol')) return Icons.construction_rounded;
  if (t.contains('su') || t.contains('kanalizasyon')) return Icons.water_drop_rounded;
  if (t.contains('elektrik') || t.contains('aydınlatma')) return Icons.electric_bolt_rounded;
  if (t.contains('ağaç') || t.contains('park') || t.contains('çevre') || t.contains('bahçe')) return Icons.park_rounded;
  if (t.contains('çöp') || t.contains('temiz')) return Icons.delete_outline_rounded;
  if (t.contains('trafik') || t.contains('işaret')) return Icons.traffic_rounded;
  if (t.contains('kaldırım') || t.contains('tretuar')) return Icons.directions_walk_rounded;
  if (t.contains('boya')) return Icons.format_paint_rounded;
  if (t.contains('kazı')) return Icons.dashboard_customize_rounded;
  return Icons.handyman_rounded;
}

/// Premium is karti - split layout, durum accent strip + zengin icerik
class _WorkCard extends StatefulWidget {
  final WorkOrder order;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WorkCard({required this.order, required this.onTap, required this.onLongPress});

  @override
  State<_WorkCard> createState() => _WorkCardState();
}

class _WorkCardState extends State<_WorkCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final statusColor = order.status.color;
    final isHighPriority = order.priority == WorkPriority.critical ||
        order.priority == WorkPriority.urgent;
    final isCompleted = order.status == WorkStatus.completed ||
        order.status == WorkStatus.cancelled;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: isCompleted ? 0.78 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              height: 104,
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isHighPriority
                        ? statusColor.withValues(alpha: isDark ? 0.25 : 0.12)
                        : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: isHighPriority ? 16 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // SOL: Status accent strip + work type icon
                  Container(
                    width: 58,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor.withValues(alpha: isDark ? 0.95 : 1.0),
                          statusColor.withValues(alpha: isDark ? 0.75 : 0.82),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Buyuk arka plan ikonu (dekoratif)
                        Positioned(
                          right: -8,
                          bottom: -8,
                          child: Icon(
                            _workTypeIcon(order.workTypeName),
                            size: 56,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        // Merkez ikon
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _workTypeIcon(order.workTypeName),
                              size: 26,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            // Oncelik dot serisi (1-5)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final filled = i < order.priority.value;
                                return Container(
                                  width: 4, height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: filled ? 0.95 : 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // SAG: icerik
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top: is tipi + durum dot
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.workTypeName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.1,
                                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                                        decorationColor: isDark ? AppColors.gray500 : AppColors.gray400,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          order.workNumber,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontFamily: 'monospace',
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.gray500 : AppColors.gray400,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 3, height: 3,
                                          decoration: BoxDecoration(
                                            color: isDark ? AppColors.gray600 : AppColors.gray300,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          order.status.label,
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Yuksek oncelik isareti
                              if (isHighPriority)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: order.priority.color.withValues(alpha: isDark ? 0.22 : 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(order.priority.icon, size: 11, color: order.priority.color),
                                      const SizedBox(width: 3),
                                      Text(
                                        order.priority.label.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                          color: order.priority.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          // Bottom: address + meta
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 12,
                                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      order.shortAddress,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  // Atanan kisi
                                  if (order.assigneeName != null) ...[
                                    _MiniAvatar(name: order.assigneeName!),
                                    const SizedBox(width: 5),
                                    Text(
                                      order.assigneeName!.split(' ').first,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.gray700,
                                      ),
                                    ),
                                  ] else ...[
                                    Icon(Icons.person_off_outlined, size: 13,
                                        color: isDark ? AppColors.gray500 : AppColors.gray400),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Atanmadı',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FontStyle.italic,
                                        color: isDark ? AppColors.gray500 : AppColors.gray400,
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  if (order.commentCount > 0) ...[
                                    Icon(Icons.chat_bubble_outline_rounded, size: 11,
                                        color: isDark ? AppColors.gray500 : AppColors.gray400),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${order.commentCount}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (order.attachmentCount > 0) ...[
                                    Icon(Icons.attach_file_rounded, size: 11,
                                        color: isDark ? AppColors.gray500 : AppColors.gray400),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${order.attachmentCount}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Icon(Icons.schedule_rounded, size: 11,
                                      color: isDark ? AppColors.gray500 : AppColors.gray400),
                                  const SizedBox(width: 2),
                                  Text(
                                    order.timeAgo,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kisi adindan ilk harfleri alan mini avatar
class _MiniAvatar extends StatelessWidget {
  final String name;
  const _MiniAvatar({required this.name});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  Color get _bgColor {
    // Ad hash'inden tutarli renk
    final colors = [
      const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF06B6D4),
      const Color(0xFFEC4899), const Color(0xFF14B8A6),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgColor, _bgColor.withValues(alpha: 0.7)],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
