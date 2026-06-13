import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:latlong2/latlong.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_provider.dart';
import '../../../../core/services/map_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/map_route_service.dart';
import '../../domain/entities/mobile_work.dart';
import '../screens/work_map_screen.dart';
import '../screens/work_state_views.dart';
import 'active_org_selector.dart';
import 'mobile_work_card.dart';

enum _SortKey { code, address, priority, type, status }

const _sortLabels = {
  _SortKey.code: 'Numara',
  _SortKey.address: 'Adres',
  _SortKey.priority: 'Önem',
  _SortKey.type: 'İş Tipi',
  _SortKey.status: 'Durum',
};

/// İş listesi gövdesi: tek satır başlık (birim seçici + arama + filtre + sıralama)
/// + aşağı çekerek yenileme. Filtre/sıralama yüklenen liste üzerinde uygulanır.
class WorkListBody extends ConsumerStatefulWidget {
  final AsyncValue<List<MobileWork>> works;
  final Future<void> Function() onRefresh;
  final bool showScopeBadge;
  final String emptyTitle;
  final String emptyMessage;

  const WorkListBody({
    super.key,
    required this.works,
    required this.onRefresh,
    this.showScopeBadge = false,
    this.emptyTitle = 'İş yok',
    this.emptyMessage = 'Gösterilecek iş bulunmuyor.',
  });

  @override
  ConsumerState<WorkListBody> createState() => _WorkListBodyState();
}

class _WorkListBodyState extends ConsumerState<WorkListBody> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searching = false;
  String _search = '';
  String? _filterType;
  String? _filterStatus;
  String _filterCode = '';
  String _filterCsbm = '';
  _SortKey _sortKey = _SortKey.code;
  bool _sortAsc = false;

  // OSRM araç mesafesi matrisi (workId → metrik) + son hesaplama imzası (gereksiz tekrar fetch'i önler).
  Map<String, DriveMetric> _drive = {};
  String _driveSig = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _hasFilter =>
      _filterType != null || _filterStatus != null || _filterCode.isNotEmpty || _filterCsbm.isNotEmpty;

  List<MobileWork> _apply(List<MobileWork> src) {
    var list = src;
    if (_search.trim().isNotEmpty) {
      final t = _search.trim().toLowerCase();
      list = list.where((w) {
        return w.code.toLowerCase().contains(t) ||
            w.workTypeName.toLowerCase().contains(t) ||
            (w.csbmName?.toLowerCase().contains(t) ?? false) ||
            (w.quarterName?.toLowerCase().contains(t) ?? false) ||
            (w.districtName?.toLowerCase().contains(t) ?? false);
      }).toList();
    }
    if (_filterCode.isNotEmpty) {
      final c = _filterCode.toLowerCase();
      list = list.where((w) => w.code.toLowerCase().contains(c)).toList();
    }
    if (_filterCsbm.isNotEmpty) {
      final c = _filterCsbm.toLowerCase();
      list = list.where((w) =>
          (w.csbmName?.toLowerCase().contains(c) ?? false) ||
          (w.quarterName?.toLowerCase().contains(c) ?? false) ||
          (w.districtName?.toLowerCase().contains(c) ?? false)).toList();
    }
    if (_filterType != null) list = list.where((w) => w.workTypeName == _filterType).toList();
    if (_filterStatus != null) list = list.where((w) => w.stepStatusName == _filterStatus).toList();

    int cmp(MobileWork a, MobileWork b) {
      switch (_sortKey) {
        case _SortKey.code:
          return a.code.compareTo(b.code);
        case _SortKey.address:
          return a.addressSummary.toLowerCase().compareTo(b.addressSummary.toLowerCase());
        case _SortKey.priority:
          return a.priority.compareTo(b.priority);
        case _SortKey.type:
          return a.workTypeName.toLowerCase().compareTo(b.workTypeName.toLowerCase());
        case _SortKey.status:
          return a.stepStatusName.toLowerCase().compareTo(b.stepStatusName.toLowerCase());
      }
    }

    final sorted = [...list]..sort(cmp);
    return _sortAsc ? sorted : sorted.reversed.toList();
  }

  void _exitSearch() {
    setState(() {
      _searching = false;
      _searchCtrl.clear();
      _search = '';
    });
  }

  void _openMap() {
    HapticFeedback.selectionClick();
    final filtered = _apply(widget.works.valueOrNull ?? const <MobileWork>[])
        .where((w) => w.hasLocation)
        .toList();
    // rootNavigator: harita tam ekran açılsın (alt menü/üst kabuk üstünde),
    // iş detay paneli menünün altında kalmasın.
    Navigator.of(context, rootNavigator: true)
        .push(MaterialPageRoute(builder: (_) => WorkMapScreen(works: filtered)));
  }

  /// OSRM açıksa mevcut konumdan tüm işlere araçla mesafe matrisini (tek istek) çeker.
  /// İmza (konum + iş id'leri) değişmedikçe tekrar çağırmaz. Kapalıysa matrisi temizler.
  Future<void> _ensureDriveMatrix(List<MobileWork> all, dynamic pos, bool osrmOn) async {
    if (!osrmOn || pos == null) {
      if (_drive.isNotEmpty) setState(() => _drive = {});
      return;
    }
    final located = all.where((w) => w.hasLocation).toList();
    if (located.isEmpty) return;
    final sig = '${pos.latitude.toStringAsFixed(4)},${pos.longitude.toStringAsFixed(4)}|'
        '${located.map((w) => w.id).join(',')}';
    if (sig == _driveSig) return;
    _driveSig = sig;

    final svc = MapRouteService(ref.read(apiClientProvider));
    final origin = LatLng(pos.latitude, pos.longitude);
    final matrix = await svc.routeMatrix(origin, located.map((w) => LatLng(w.latitude!, w.longitude!)).toList());
    if (!mounted) return;
    final byId = <String, DriveMetric>{};
    matrix.forEach((idx, m) {
      if (idx >= 0 && idx < located.length) byId[located[idx].id] = m;
    });
    setState(() => _drive = byId);
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.works.valueOrNull ?? const <MobileWork>[];
    final pos = ref.watch(currentLocationProvider).valueOrNull;
    final osrmOn = ref.watch(mapSettingsProvider).osrmEnabled;
    if (osrmOn && pos != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureDriveMatrix(all, pos, osrmOn));
    }

    return Column(
      children: [
        _Header(
          searching: _searching,
          searchCtrl: _searchCtrl,
          searchFocus: _searchFocus,
          hasFilter: _hasFilter,
          onStartSearch: () {
            setState(() => _searching = true);
            WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
          },
          onExitSearch: _exitSearch,
          onSearchChanged: (v) => setState(() => _search = v),
          onFilter: () => _openFilterSheet(all),
          onSort: _openSortSheet,
          onMap: _openMap,
        ),
        Expanded(
          child: widget.works.when(
            loading: () => const WorkLoadingView(),
            error: (e, _) => WorkErrorView(onRetry: widget.onRefresh),
            data: (works) {
              final filtered = _apply(works);
              return RefreshIndicator(
                onRefresh: widget.onRefresh,
                child: filtered.isEmpty
                    ? (works.isEmpty
                        ? WorkEmptyView(icon: Icons.inbox_outlined, title: widget.emptyTitle, message: widget.emptyMessage)
                        : const WorkEmptyView(
                            icon: Icons.search_off_rounded,
                            title: 'Sonuç yok',
                            message: 'Arama/filtre ölçütlerine uyan iş bulunamadı.'))
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 104),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final w = filtered[i];
                          String? distText;
                          var driving = false;
                          final dm = osrmOn ? _drive[w.id] : null;
                          if (dm != null && dm.distanceMeters != null) {
                            distText = formatDistance(dm.distanceMeters!); // araçla yol mesafesi
                            driving = true;
                          } else if (pos != null && w.hasLocation) {
                            distText = formatDistance(
                                distanceMeters(pos.latitude, pos.longitude, w.latitude!, w.longitude!));
                          }
                          return MobileWorkCard(
                            work: w,
                            showScopeBadge: widget.showScopeBadge,
                            distanceText: distText,
                            isDriving: driving,
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openFilterSheet(List<MobileWork> all) {
    HapticFeedback.selectionClick();
    final types = all.map((w) => w.workTypeName).where((s) => s.isNotEmpty).toSet().toList()..sort();
    final statuses = all.map((w) => w.stepStatusName).where((s) => s.isNotEmpty).toSet().toList()..sort();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Bekleyen seçimler — "Uygula"da commit edilir.
    var pType = _filterType;
    var pStatus = _filterStatus;
    final codeCtrl = TextEditingController(text: _filterCode);
    final csbmCtrl = TextEditingController(text: _filterCsbm);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SheetHandle(),
                  Row(
                    children: [
                      Text('Filtrele', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setSheet(() {
                          pType = null;
                          pStatus = null;
                          codeCtrl.clear();
                          csbmCtrl.clear();
                        }),
                        child: const Text('Temizle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _filterField(label: 'Numara', controller: codeCtrl, hint: 'Örn. 100T029', icon: Icons.tag_rounded),
                  const SizedBox(height: 14),
                  _filterField(label: 'Csbm / Adres', controller: csbmCtrl, hint: 'Cadde, sokak, mahalle…', icon: Icons.place_outlined),
                  const SizedBox(height: 16),
                  _ChipFilter(title: 'İş Tipi', options: types, selected: pType, onSelected: (v) => setSheet(() => pType = v)),
                  const SizedBox(height: 16),
                  _ChipFilter(title: 'Durum', options: statuses, selected: pStatus, onSelected: (v) => setSheet(() => pStatus = v)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _filterType = pType;
                          _filterStatus = pStatus;
                          _filterCode = codeCtrl.text.trim();
                          _filterCsbm = csbmCtrl.text.trim();
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Uygula'),
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

  Widget _filterField({required String label, required TextEditingController controller, required String hint, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: isDark ? AppColors.gray800 : AppColors.gray100,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _openSortSheet() {
    HapticFeedback.selectionClick();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text('Sırala', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _sortAsc = !_sortAsc);
                      Navigator.of(ctx).pop();
                    },
                    icon: Icon(_sortAsc ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 18),
                    label: Text(_sortAsc ? 'Artan' : 'Azalan'),
                  ),
                ],
              ),
            ),
            for (final k in _SortKey.values)
              ListTile(
                dense: true,
                title: Text(_sortLabels[k]!),
                trailing: _sortKey == k ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                onTap: () {
                  setState(() => _sortKey = k);
                  Navigator.of(ctx).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Tek satır başlık: birim seçici + arama (genişleyen) + filtre + sıralama.
class _Header extends StatelessWidget {
  final bool searching;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final bool hasFilter;
  final VoidCallback onStartSearch;
  final VoidCallback onExitSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final VoidCallback onMap;

  const _Header({
    required this.searching,
    required this.searchCtrl,
    required this.searchFocus,
    required this.hasFilter,
    required this.onStartSearch,
    required this.onExitSearch,
    required this.onSearchChanged,
    required this.onFilter,
    required this.onSort,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.gray800 : AppColors.gray100;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: SizedBox(
        height: 44,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SizeTransition(sizeFactor: anim, axis: Axis.horizontal, axisAlignment: 1, child: child),
          ),
          layoutBuilder: (current, previous) => Stack(alignment: Alignment.centerLeft, children: [?current]),
          child: searching
              ? Row(
                  key: const ValueKey('search'),
                  children: [
                    _IconBtn(icon: Icons.arrow_back_rounded, fill: fill, onTap: onExitSearch),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: searchCtrl,
                        focusNode: searchFocus,
                        onChanged: onSearchChanged,
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'No, csbm, iş tipi ara…',
                          filled: true,
                          fillColor: fill,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          suffixIcon: searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  onPressed: () {
                                    searchCtrl.clear();
                                    onSearchChanged('');
                                  },
                                ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('actions'),
                  children: [
                    _IconBtn(icon: Icons.search_rounded, fill: fill, onTap: onStartSearch),
                    const SizedBox(width: 8),
                    _IconBtn(icon: Icons.map_outlined, fill: fill, onTap: onMap),
                    const Spacer(),
                    _IconBtn(icon: Icons.sort_rounded, fill: fill, onTap: onSort),
                    const SizedBox(width: 8),
                    _IconBtn(icon: Icons.tune_rounded, fill: fill, active: hasFilter, onTap: onFilter),
                    const SizedBox(width: 8),
                    const Flexible(child: ActiveOrgSelector()),
                  ],
                ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Color fill;
  const _IconBtn({required this.icon, required this.onTap, required this.fill, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.14) : fill,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 20, color: active ? AppColors.primary : null),
      ),
    );
  }
}

/// Okunur, kontrastı net seçim chip'leri (ChoiceChip tema sorunlarından kaçınmak için custom).
class _ChipFilter extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;
  const _ChipFilter({required this.title, required this.options, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (options.isEmpty)
          Text('—', style: Theme.of(context).textTheme.bodySmall)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in options)
                _chip(context, o, selected == o, isDark, () => onSelected(selected == o ? null : o)),
            ],
          ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, bool sel, bool isDark, VoidCallback onTap) {
    final fg = sel ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);
    return Material(
      color: sel ? AppColors.primary : (isDark ? AppColors.gray800 : AppColors.gray100),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sel) ...[const Icon(Icons.check_rounded, size: 15, color: Colors.white), const SizedBox(width: 5)],
              Text(label, style: TextStyle(color: fg, fontSize: 13, fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.gray700 : AppColors.gray300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
