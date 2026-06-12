import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Mevcut konum (tek seferlik). İzin/servis kapalıysa null döner.
/// Yenilemek için: ref.invalidate(currentLocationProvider).
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  if (!await Geolocator.isLocationServiceEnabled()) return null;

  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
    return null;
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).timeout(const Duration(seconds: 10));
  } catch (_) {
    // Son bilinen konuma düş.
    return await Geolocator.getLastKnownPosition();
  }
});

/// İki nokta arası kuş uçuşu mesafe (metre).
double distanceMeters(double lat1, double lng1, double lat2, double lng2) =>
    Geolocator.distanceBetween(lat1, lng1, lat2, lng2);

/// Mesafeyi okunur biçime çevir: <1km → "850 m", aksi → "1,2 km".
String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  final km = meters / 1000;
  return '${km.toStringAsFixed(1).replaceAll('.', ',')} km';
}
