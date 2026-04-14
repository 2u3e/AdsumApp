import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/mock_work_orders.dart';
import '../../domain/entities/work_enums.dart';
import '../../domain/entities/work_order.dart';

/// Is emri liste ekrani
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

    // Metin araması
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

    // Adres filtresi
    if (_addressFilter.isNotEmpty) {
      final q = _addressFilter.toLowerCase();
      orders = orders.where((w) =>
          w.fullAddress.toLowerCase().contains(q) ||
          w.neighborhood.toLowerCase().contains(q) ||
          (w.street?.toLowerCase().contains(q) ?? false) ||
          w.district.toLowerCase().contains(q)).toList();
    }

    // Durum filtresi
    if (_selectedStatuses.isNotEmpty) {
      orders = orders.where((w) => _selectedStatuses.contains(w.status)).toList();
    }

    // Oncelik filtresi
    if (_selectedPriorities.isNotEmpty) {
      orders = orders.where((w) => _selectedPriorities.contains(w.priority)).toList();
    }

    // Siralama: oncelik (yuksek once), sonra tarih (yeni once)
    orders.sort((a, b) {
      final pc = b.priority.value.compareTo(a.priority.value);
      if (pc != 0) return pc;
      return b.createdAt.compareTo(a.createdAt);
    });

    return orders;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedStatuses.isNotEmpty) count++;
    if (_selectedPriorities.isNotEmpty) count++;
    if (_addressFilter.isNotEmpty) count++;
    return count;
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
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'İş no, tür, adres, kişi ara...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                      ),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                onPressed: () => _showFilterSheet(context),
              ),
              if (_activeFilterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: orders.isEmpty
            ? _buildEmptyState(context, isDark)
            : ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _WorkOrderCard(
                    order: order,
                    onTap: () => context.push('/work-orders/${order.id}'),
                    onLongPress: () => _showQuickActions(context, order),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/work-orders/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni İş Emri'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: isDark ? AppColors.gray600 : AppColors.gray300),
          AppSpacing.verticalLg,
          Text('Sonuç bulunamadı', style: Theme.of(context).textTheme.titleMedium),
          AppSpacing.verticalXs,
          Text(
            'Filtre veya arama kriterlerinizi değiştirin',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(BuildContext context, WorkOrder order) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_rounded, color: AppColors.primary),
                title: const Text('Detay Görüntüle'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/work-orders/${order.id}');
                },
              ),
              if (order.status != WorkStatus.completed && order.status != WorkStatus.cancelled) ...[
                ListTile(
                  leading: const Icon(Icons.directions_car_rounded, color: AppColors.info),
                  title: const Text('İntikal Et'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline_rounded, color: AppColors.success),
                  title: const Text('Çalışmaya Başla'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add_outlined, color: AppColors.warning),
                  title: const Text('Yeniden Ata'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final tempStatuses = Set<WorkStatus>.from(_selectedStatuses);
    final tempPriorities = Set<WorkPriority>.from(_selectedPriorities);
    final addressCtrl = TextEditingController(text: _addressFilter);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        decoration: BoxDecoration(color: AppColors.gray300, borderRadius: AppSpacing.borderRadiusFull),
                      ),
                    ),
                    Text('Filtrele', style: Theme.of(context).textTheme.headlineSmall),
                    AppSpacing.verticalLg,

                    // Adres arama
                    Text('Adres / Mahalle / Cadde', style: Theme.of(context).textTheme.titleSmall),
                    AppSpacing.verticalSm,
                    TextField(
                      controller: addressCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Örn: Tecde, İnönü Caddesi...',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    AppSpacing.verticalLg,

                    // Durum
                    Text('Durum', style: Theme.of(context).textTheme.titleSmall),
                    AppSpacing.verticalSm,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WorkStatus.values.map((s) {
                        final selected = tempStatuses.contains(s);
                        return FilterChip(
                          label: Text(s.label),
                          selected: selected,
                          selectedColor: s.color.withValues(alpha: 0.2),
                          checkmarkColor: s.color,
                          onSelected: (v) => setSheetState(() {
                            v ? tempStatuses.add(s) : tempStatuses.remove(s);
                          }),
                        );
                      }).toList(),
                    ),
                    AppSpacing.verticalLg,

                    // Oncelik
                    Text('Öncelik', style: Theme.of(context).textTheme.titleSmall),
                    AppSpacing.verticalSm,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: WorkPriority.values.map((p) {
                        final selected = tempPriorities.contains(p);
                        return FilterChip(
                          label: Text(p.label),
                          selected: selected,
                          selectedColor: p.color.withValues(alpha: 0.2),
                          checkmarkColor: p.color,
                          onSelected: (v) => setSheetState(() {
                            v ? tempPriorities.add(p) : tempPriorities.remove(p);
                          }),
                        );
                      }).toList(),
                    ),

                    const Spacer(),
                    Row(
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
                            child: const Text('Temizle'),
                          ),
                        ),
                        AppSpacing.horizontalMd,
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedStatuses = tempStatuses;
                                _selectedPriorities = tempPriorities;
                                _addressFilter = addressCtrl.text.trim();
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Uygula'),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalLg,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Is emri karti - durum rengiyle sol border
class _WorkOrderCard extends StatelessWidget {
  final WorkOrder order;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _WorkOrderCard({
    required this.order,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isDark ? order.status.bgColor.withValues(alpha: 0.15) : order.status.bgColor,
        borderRadius: AppSpacing.borderRadiusMd,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: order.status.borderColor),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Sol renk cubugu
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      color: order.status.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppSpacing.radiusMd),
                        bottomLeft: Radius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                  ),
                  // Kart icerigi
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ust satir: is no + oncelik
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order.workNumber,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.5,
                                    ),
                              ),
                              _PriorityBadge(priority: order.priority),
                            ],
                          ),
                          AppSpacing.verticalSm,

                          // Is turu
                          Row(
                            children: [
                              Icon(order.status.icon, size: 16, color: order.status.color),
                              AppSpacing.horizontalXs,
                              Text(
                                order.workTypeName,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalXs,

                          // Adres
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                              ),
                              AppSpacing.horizontalXs,
                              Expanded(
                                child: Text(
                                  order.shortAddress,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.verticalMd,

                          // Alt satir: durum + bekleme + tarih
                          Row(
                            children: [
                              // Durum chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: order.status.color.withValues(alpha: 0.15),
                                  borderRadius: AppSpacing.borderRadiusFull,
                                ),
                                child: Text(
                                  order.status.label,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: order.status.color,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              AppSpacing.horizontalSm,

                              // Bekleme suresi
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: isDark ? AppColors.gray500 : AppColors.gray400,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                order.waitingDuration,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      fontSize: 10,
                                    ),
                              ),

                              const Spacer(),

                              // Yorum sayisi
                              if (order.commentCount > 0) ...[
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 13,
                                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${order.commentCount}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                        fontSize: 10,
                                      ),
                                ),
                                AppSpacing.horizontalSm,
                              ],

                              // Tarih
                              Text(
                                order.timeAgo,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                                      fontSize: 10,
                                    ),
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

/// Oncelik badge'i
class _PriorityBadge extends StatelessWidget {
  final WorkPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.12),
        borderRadius: AppSpacing.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: priority.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: priority.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
