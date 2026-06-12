import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Harita altlık kaynağı.
enum BasemapSource { osm, selfHosted }

/// Harita ayarları — basemap kaynağı, self-host tile URL'i ve OSRM (araç rotası) açık/kapalı.
/// Sistemi tek bir seçeneğe mahkum etmemek için hepsi kullanıcı/yönetici tarafından
/// değiştirilebilir; SharedPreferences'ta saklanır.
class MapSettings {
  final BasemapSource basemap;

  /// Self-host XYZ raster tile şablonu (örn. http://host:8080/styles/.../{z}/{x}/{y}.png).
  /// Boşsa self-host seçili olsa bile OSM'e düşülür.
  final String selfHostTileUrl;

  /// OSRM (araçla mesafe + güzergah optimizasyonu) özellikleri açık mı.
  final bool osrmEnabled;

  const MapSettings({
    this.basemap = BasemapSource.osm,
    this.selfHostTileUrl = defaultSelfHostUrl,
    this.osrmEnabled = false,
  });

  static const String _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Sunucumuzdaki OSM önbellekli tile proxy (nginx) — varsayılan self-host adresi.
  static const String defaultSelfHostUrl = 'http://187.127.72.4:8082/{z}/{x}/{y}.png';

  /// Aktif tile URL şablonu. Self-host seçili ama URL boşsa OSM'e düşer (B planı).
  String get tileUrl =>
      basemap == BasemapSource.selfHosted && selfHostTileUrl.trim().isNotEmpty ? selfHostTileUrl.trim() : _osmUrl;

  bool get usingOsmFallback => basemap == BasemapSource.selfHosted && selfHostTileUrl.trim().isEmpty;

  MapSettings copyWith({BasemapSource? basemap, String? selfHostTileUrl, bool? osrmEnabled}) => MapSettings(
        basemap: basemap ?? this.basemap,
        selfHostTileUrl: selfHostTileUrl ?? this.selfHostTileUrl,
        osrmEnabled: osrmEnabled ?? this.osrmEnabled,
      );
}

final mapSettingsProvider =
    NotifierProvider<MapSettingsNotifier, MapSettings>(MapSettingsNotifier.new);

class MapSettingsNotifier extends Notifier<MapSettings> {
  @override
  MapSettings build() {
    _load();
    return const MapSettings();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = MapSettings(
        basemap: prefs.getString(StorageKeys.mapBasemap) == 'selfHosted' ? BasemapSource.selfHosted : BasemapSource.osm,
        selfHostTileUrl: prefs.getString(StorageKeys.mapSelfHostUrl) ?? MapSettings.defaultSelfHostUrl,
        osrmEnabled: prefs.getBool(StorageKeys.mapOsrmEnabled) ?? false,
      );
    } catch (_) {}
  }

  Future<void> setBasemap(BasemapSource b) async {
    state = state.copyWith(basemap: b);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.mapBasemap, b.name);
  }

  Future<void> setSelfHostUrl(String url) async {
    state = state.copyWith(selfHostTileUrl: url);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.mapSelfHostUrl, url);
  }

  Future<void> setOsrmEnabled(bool v) async {
    state = state.copyWith(osrmEnabled: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.mapOsrmEnabled, v);
  }
}
