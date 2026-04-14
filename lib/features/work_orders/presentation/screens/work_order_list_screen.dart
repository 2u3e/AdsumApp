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

class _WorkOrderListScreenState extends ConsumerState<WorkOrderListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Set<WorkStatus> _selectedStatuses = {};
  Set<WorkPriority> _selectedPriorities = {};
  String _addressFilter = '';

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
    orders.sort((a, b) {
      final pc = b.priority.value.compareTo(a.priority.value);
      if (pc != 0) return pc;
      return b.createdAt.compareTo(a.createdAt);
    });
    return orders;
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
                  Stack(
                    children: [
                      IconButton(icon: const Icon(Icons.tune_rounded, size: 22), onPressed: () => _showFilterSheet(context)),
                      if (_activeFilterCount > 0)
                        Positioned(right: 6, top: 6, child: Container(
                          width: 16, height: 16,
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          child: Center(child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
                        )),
                    ],
                  ),
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
                        padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
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
      // FAB - compact pill
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.small(
          onPressed: () => context.push('/work-orders/create'),
          elevation: 4,
          child: const Icon(Icons.add_rounded, size: 24),
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
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, sc) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: ListView(
              controller: sc,
              children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 20),
                  decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull))),
                Text('Filtrele', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Text('Adres / Mahalle / Cadde', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                TextField(controller: addrCtrl,
                  decoration: const InputDecoration(hintText: 'Örn: Tecde, İnönü Caddesi...', prefixIcon: Icon(Icons.location_on_outlined))),
                const SizedBox(height: 20),
                Text('Durum', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: WorkStatus.values.map((s) => FilterChip(
                  label: Text(s.label),
                  selected: tmpS.contains(s),
                  selectedColor: s.color.withValues(alpha: 0.2),
                  checkmarkColor: s.color,
                  onSelected: (v) => setS(() => v ? tmpS.add(s) : tmpS.remove(s)),
                )).toList()),
                const SizedBox(height: 20),
                Text('Öncelik', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: WorkPriority.values.map((p) => FilterChip(
                  label: Text(p.label),
                  selected: tmpP.contains(p),
                  selectedColor: p.color.withValues(alpha: 0.2),
                  checkmarkColor: p.color,
                  onSelected: (v) => setS(() => v ? tmpP.add(p) : tmpP.remove(p)),
                )).toList()),
                const SizedBox(height: 28),
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () { setState(() { _selectedStatuses = {}; _selectedPriorities = {}; _addressFilter = ''; }); Navigator.pop(context); },
                    child: const Text('Temizle'))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(
                    onPressed: () { setState(() { _selectedStatuses = tmpS; _selectedPriorities = tmpP; _addressFilter = addrCtrl.text.trim(); }); Navigator.pop(context); },
                    child: const Text('Uygula'))),
                ]),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// Yeni is karti - kompakt, temiz, vurucu
class _WorkCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WorkCard({required this.order, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.gray800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(color: order.status.color, width: 4),
            ),
            boxShadow: [
              if (!isDark) BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Satir 1: no + oncelik ikonu + durum
              Row(
                children: [
                  // Oncelik ikonu
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: order.priority.color.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(order.priority.icon, size: 14, color: order.priority.color),
                  ),
                  const SizedBox(width: 10),
                  // Is no + tur
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.workNumber, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontFamily: 'monospace', letterSpacing: 0.5,
                              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight)),
                        Text(order.workTypeName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  // Durum chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.status.color.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(order.status.icon, size: 12, color: order.status.color),
                        const SizedBox(width: 4),
                        Text(order.status.label, style: TextStyle(
                          color: order.status.color, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Satir 2: adres
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14,
                      color: isDark ? AppColors.gray500 : AppColors.gray400),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(order.shortAddress, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                  ),
                  // Zaman
                  Text(order.timeAgo, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
