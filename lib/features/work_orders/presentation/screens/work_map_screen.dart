import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/location_provider.dart';
import '../../../../core/services/map_settings_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/map_route_service.dart';
import '../../domain/entities/mobile_work.dart';
import '../widgets/work_detail_sheet.dart';
import '../widgets/work_visuals.dart';

/// İşleri harita üzerinde gösteren sayfa. Listeden gelen (filtrelenmiş) işleri pin'ler;
/// en yakın işi bulur, mesafe (kuş uçuşu; OSRM açıksa araçla) gösterir, telefon
/// haritasıyla yol tarifi açar, OSRM açıksa güzergah optimizasyonu çizer.
class WorkMapScreen extends ConsumerStatefulWidget {
  final List<MobileWork> works;
  const WorkMapScreen({super.key, required this.works});

  @override
  ConsumerState<WorkMapScreen> createState() => _WorkMapScreenState();
}

class _WorkMapScreenState extends ConsumerState<WorkMapScreen> {
  final _map = MapController();
  MobileWork? _selected;
  List<LatLng> _route = const [];
  Map<int, DriveMetric> _drive = const {}; // work index → araç metriği
  bool _busy = false;

  static const _malatya = LatLng(38.3552, 38.3095);

  List<MobileWork> get _located => widget.works.where((w) => w.hasLocation).toList();

  LatLng? get _myLatLng {
    final pos = ref.watch(currentLocationProvider).valueOrNull;
    return pos == null ? null : LatLng(pos.latitude, pos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(mapSettingsProvider);
    final me = _myLatLng;
    final located = _located;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureMatrix(me, located, settings.osrmEnabled));

    // Önce işlerin konumuna ortala (emülatör GPS'i alakasız yer döndürebilir); pin'ler hep görünür.
    final center = located.isNotEmpty
        ? LatLng(located.first.latitude!, located.first.longitude!)
        : (me ?? _malatya);
    final nearest = _nearest(me, located);

    return Scaffold(
      appBar: AppBar(
        title: Text('Harita · ${located.length} iş', style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          if (settings.osrmEnabled)
            IconButton(
              tooltip: 'Güzergah oluştur',
              onPressed: _busy ? null : () => _buildRoute(me, located),
              icon: _busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.route_rounded),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (_, _) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate: settings.tileUrl,
                userAgentPackageName: 'gov.adsum.app',
                maxZoom: 19,
              ),
              if (_route.isNotEmpty)
                PolylineLayer(polylines: [
                  Polyline(points: _route, strokeWidth: 5, color: AppColors.primary.withValues(alpha: 0.85)),
                ]),
              MarkerLayer(markers: [
                for (var i = 0; i < located.length; i++) _workMarker(located[i], i, nearest),
                if (me != null) _meMarker(me),
              ]),
            ],
          ),

          if (settings.usingOsmFallback)
            Positioned(
              top: 8, left: 12, right: 12,
              child: _Banner(
                color: AppColors.warning,
                icon: Icons.info_outline_rounded,
                text: 'Self-host harita URL\'si tanımlı değil, OSM kullanılıyor.',
              ),
            ),

          // En yakın iş + seçili iş paneli
          Positioned(
            left: 12, right: 12, bottom: 12,
            child: _selected != null
                ? _WorkPanel(
                    work: _selected!,
                    distanceText: _distLabel(me, _selected!),
                    onDirections: () => _openDirections(_selected!),
                    onDetail: () => showWorkDetailSheet(context, _selected!,
                        distanceText: _distValue(me, _selected!), isDriving: _isDriving(_selected!)),
                    isDark: isDark,
                  )
                : (nearest != null
                    ? _NearestBanner(
                        work: nearest,
                        distanceText: _distLabel(me, nearest),
                        onGo: () => _openDirections(nearest),
                        onShow: () {
                          setState(() => _selected = nearest);
                          _map.move(LatLng(nearest.latitude!, nearest.longitude!), 16);
                        },
                        isDark: isDark,
                      )
                    : const SizedBox.shrink()),
          ),

          // Konumum butonu
          Positioned(
            right: 12,
            bottom: _selected != null || nearest != null ? 132 : 24,
            child: FloatingActionButton.small(
              heroTag: 'loc',
              onPressed: () {
                ref.invalidate(currentLocationProvider);
                final m = _myLatLng;
                if (m != null) _map.move(m, 15);
              },
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }

  Marker _workMarker(MobileWork w, int i, MobileWork? nearest) {
    final color = stepColorOf(w);
    final isNearest = nearest != null && nearest.id == w.id;
    final selected = _selected?.id == w.id;
    final highlight = selected || isNearest;
    final pinColor = isNearest ? AppColors.primary : color;
    return Marker(
      key: ValueKey('m_${w.id}'),
      point: LatLng(w.latitude!, w.longitude!),
      width: 26,
      height: 26,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selected = w);
        },
        child: Container(
          decoration: BoxDecoration(
            color: pinColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: highlight ? 3.5 : 2.5),
          ),
          // İçte küçük beyaz nokta — seçili/en yakını belirginleştirir (gölge yok → hayalet yok).
          child: highlight
              ? const Center(child: Icon(Icons.circle, size: 7, color: Colors.white))
              : null,
        ),
      ),
    );
  }

  Marker _meMarker(LatLng me) => Marker(
        key: const ValueKey('me'),
        point: me,
        width: 20,
        height: 20,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      );

  MobileWork? _nearest(LatLng? me, List<MobileWork> located) {
    if (me == null || located.isEmpty) return null;
    MobileWork? best;
    double bestD = double.infinity;
    for (final w in located) {
      final d = distanceMeters(me.latitude, me.longitude, w.latitude!, w.longitude!);
      if (d < bestD) {
        bestD = d;
        best = w;
      }
    }
    return best;
  }

  /// İşin OSRM araç metriği (varsa) — index eşlemesiyle.
  DriveMetric? _driveOf(MobileWork w) {
    final idx = _located.indexWhere((e) => e.id == w.id);
    return idx >= 0 ? _drive[idx] : null;
  }

  bool _isDriving(MobileWork w) => _driveOf(w)?.durationSeconds != null;

  /// Mesafe değeri (etiketsiz): araçla "2,3 km · 4 dk" ya da kuş uçuşu "1,2 km".
  String _distValue(LatLng? me, MobileWork w) {
    final dm = _driveOf(w);
    if (dm != null && dm.durationSeconds != null) {
      return '${formatDistance(dm.distanceMeters ?? 0)} · ${formatDuration(dm.durationSeconds!)}';
    }
    if (me == null) return 'Konum kapalı';
    return formatDistance(distanceMeters(me.latitude, me.longitude, w.latitude!, w.longitude!));
  }

  /// Panel/banner için etiketli metin.
  String _distLabel(LatLng? me, MobileWork w) {
    if (me == null && !_isDriving(w)) return 'Konum kapalı';
    return '${_distValue(me, w)} (${_isDriving(w) ? "araçla" : "kuş uçuşu"})';
  }

  String _matrixSig = '';

  /// OSRM açıksa mevcut konumdan tüm işlere araç matrisini otomatik çeker (güzergaha gerek yok).
  Future<void> _ensureMatrix(LatLng? me, List<MobileWork> located, bool osrmOn) async {
    if (!osrmOn || me == null || located.isEmpty) return;
    final sig = '${me.latitude.toStringAsFixed(4)},${me.longitude.toStringAsFixed(4)}|'
        '${located.map((w) => w.id).join(',')}';
    if (sig == _matrixSig) return;
    _matrixSig = sig;
    final svc = MapRouteService(ref.read(apiClientProvider));
    final matrix = await svc.routeMatrix(me, located.map((w) => LatLng(w.latitude!, w.longitude!)).toList());
    if (!mounted || matrix.isEmpty) return;
    setState(() => _drive = matrix);
  }

  Future<void> _openDirections(MobileWork w) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${w.latitude},${w.longitude}&travelmode=driving');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _buildRoute(LatLng? me, List<MobileWork> located) async {
    if (me == null || located.isEmpty) return;
    setState(() => _busy = true);
    final svc = MapRouteService(ref.read(apiClientProvider));
    final points = [me, ...located.map((w) => LatLng(w.latitude!, w.longitude!))];
    final result = await svc.optimize(points);
    final matrix = await svc.routeMatrix(me, located.map((w) => LatLng(w.latitude!, w.longitude!)).toList());
    if (!mounted) return;
    setState(() {
      _route = result?.geometry ?? const [];
      _drive = matrix;
      _busy = false;
    });
    if (result == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güzergah alınamadı (OSRM kapalı olabilir).')),
      );
    }
  }
}

class _NearestBanner extends StatelessWidget {
  final MobileWork work;
  final String distanceText;
  final VoidCallback onGo;
  final VoidCallback onShow;
  final bool isDark;
  const _NearestBanner({
    required this.work,
    required this.distanceText,
    required this.onGo,
    required this.onShow,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        child: Row(
          children: [
            const Icon(Icons.near_me_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('En yakın iş', style: TextStyle(fontSize: 11, color: isDark ? AppColors.gray400 : AppColors.gray500)),
                  Text('${work.code} · ${work.workTypeName}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(distanceText, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            TextButton(onPressed: onShow, child: const Text('Göster')),
            FilledButton.icon(onPressed: onGo, icon: const Icon(Icons.navigation_rounded, size: 16), label: const Text('Git')),
          ],
        ),
      ),
    );
  }
}

class _WorkPanel extends StatelessWidget {
  final MobileWork work;
  final String distanceText;
  final VoidCallback onDirections;
  final VoidCallback onDetail;
  final bool isDark;
  const _WorkPanel({
    required this.work,
    required this.distanceText,
    required this.onDirections,
    required this.onDetail,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accent = stepColorOf(work);
    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: InkWell(
        onTap: onDetail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(work.code, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(work.stepStatusName,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w600))),
                ],
              ),
              const SizedBox(height: 4),
              Text(work.workTypeName, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (work.addressSummary.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(work.addressSummary, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.gray400 : AppColors.gray500)),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(distanceText,
                        style: const TextStyle(color: AppColors.primary, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(onPressed: onDetail, child: const Text('Detay')),
                  FilledButton.icon(
                      onPressed: onDirections,
                      icon: const Icon(Icons.navigation_rounded, size: 16),
                      label: const Text('Yol Tarifi')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _Banner({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12.5))),
          ],
        ),
      ),
    );
  }
}
