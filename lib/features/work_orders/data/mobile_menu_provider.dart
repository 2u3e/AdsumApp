import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/active_org_provider.dart';

/// Aktif birim icin mobil menulerin (Platform=Mobile) izin verilen route kumesi.
/// Web /role ekranindan role verilen VIEW yetkisine gore doner. Bos kume = yetki yok.
/// "Ekip Isleri" (/team-works) ve "Birim Isleri" (/unit-works) gorunurlugu buna baglanir.
final mobileMenuRoutesProvider = FutureProvider<Set<String>>((ref) async {
  final orgId = ref.watch(activeOrganizationProvider);
  if (orgId == null) return <String>{};

  final dio = ref.read(apiClientProvider);
  final resp = await dio.get(
    ApiConstants.menusForUser,
    queryParameters: {'organizationId': orgId, 'platform': 2}, // 2 = Mobile
  );

  final body = resp.data;
  final list = (body is Map<String, dynamic>) ? body['data'] : body;
  final routes = <String>{};
  if (list is List) {
    for (final m in list) {
      if (m is Map && m['route'] is String) {
        routes.add(m['route'] as String);
      }
    }
  }
  return routes;
});

/// Kullanici "Ekip Isleri" menusunu gorebiliyor mu?
final canSeeTeamWorksProvider = Provider<bool>((ref) {
  final routes = ref.watch(mobileMenuRoutesProvider).valueOrNull ?? const <String>{};
  return routes.contains('/team-works');
});

/// Kullanici "Birim Isleri" menusunu gorebiliyor mu?
final canSeeUnitWorksProvider = Provider<bool>((ref) {
  final routes = ref.watch(mobileMenuRoutesProvider).valueOrNull ?? const <String>{};
  return routes.contains('/unit-works');
});
