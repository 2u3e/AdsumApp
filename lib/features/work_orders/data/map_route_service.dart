import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/api_constants.dart';

/// Bir hedefe araçla mesafe/süre (OSRM table). Null = ulaşılamadı.
class DriveMetric {
  final int index;
  final double? distanceMeters;
  final double? durationSeconds;
  const DriveMetric(this.index, this.distanceMeters, this.durationSeconds);
}

/// Güzergah optimizasyonu sonucu (OSRM trip).
class OptimizeResult {
  final List<int> order; // giriş noktalarının optimal sırası
  final double totalDistanceMeters;
  final double totalDurationSeconds;
  final List<LatLng> geometry; // çizilecek polyline
  const OptimizeResult(this.order, this.totalDistanceMeters, this.totalDurationSeconds, this.geometry);
}

/// OSRM tabanlı harita servisleri. OSRM kapalı/kurulu değilse boş/null döner (B planı).
class MapRouteService {
  final Dio _dio;
  MapRouteService(this._dio);

  Future<bool> osrmAvailable() async {
    try {
      final r = await _dio.get(ApiConstants.mapConfig);
      final d = _data(r.data);
      return d is Map && d['osrmAvailable'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Origin'den hedeflere araçla mesafe/süre (tek istek). index → DriveMetric.
  Future<Map<int, DriveMetric>> routeMatrix(LatLng origin, List<LatLng> destinations) async {
    if (destinations.isEmpty) return {};
    final dest = destinations.map((d) => '${d.latitude},${d.longitude}').join(';');
    try {
      final r = await _dio.get(ApiConstants.mapRouteMatrix, queryParameters: {
        'originLat': origin.latitude,
        'originLng': origin.longitude,
        'destinations': dest,
      });
      final d = _data(r.data);
      if (d is! Map || d['osrmAvailable'] != true) return {};
      final items = (d['items'] as List?) ?? const [];
      final map = <int, DriveMetric>{};
      for (final it in items) {
        if (it is Map) {
          final idx = (it['index'] as num).toInt();
          map[idx] = DriveMetric(
            idx,
            (it['distanceMeters'] as num?)?.toDouble(),
            (it['durationSeconds'] as num?)?.toDouble(),
          );
        }
      }
      return map;
    } catch (_) {
      return {};
    }
  }

  /// Güzergah optimizasyonu. points[0] başlangıç (genelde mevcut konum).
  Future<OptimizeResult?> optimize(List<LatLng> points) async {
    if (points.length < 2) return null;
    final pts = points.map((p) => '${p.latitude},${p.longitude}').join(';');
    try {
      final r = await _dio.get(ApiConstants.mapOptimize, queryParameters: {'points': pts, 'roundTrip': false});
      final d = _data(r.data);
      if (d is! Map || d['osrmAvailable'] != true) return null;
      final order = ((d['order'] as List?) ?? const []).map((e) => (e as num).toInt()).toList();
      final geom = ((d['geometry'] as List?) ?? const [])
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())) // [lng,lat] → LatLng
          .toList();
      return OptimizeResult(
        order,
        (d['totalDistanceMeters'] as num?)?.toDouble() ?? 0,
        (d['totalDurationSeconds'] as num?)?.toDouble() ?? 0,
        geom,
      );
    } catch (_) {
      return null;
    }
  }

  static dynamic _data(dynamic body) => (body is Map && body['data'] != null) ? body['data'] : body;
}

/// Süreyi okunur biçime çevir: <60dk → "12 dk", aksi → "1 sa 20 dk".
String formatDuration(double seconds) {
  final m = (seconds / 60).round();
  if (m < 60) return '$m dk';
  final h = m ~/ 60;
  final rem = m % 60;
  return rem == 0 ? '$h sa' : '$h sa $rem dk';
}
