import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/active_org_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/mobile_work.dart';
import 'mobile_menu_provider.dart';

List<MobileWork> _parseList(dynamic body, MobileWorkScope scope) {
  final list = (body is Map<String, dynamic>) ? body['data'] : body;
  final out = <MobileWork>[];
  if (list is List) {
    for (final m in list) {
      if (m is Map<String, dynamic>) out.add(MobileWork.fromJson(m, scope));
    }
  }
  return out;
}

/// Sayfa A — "Atanan Isler": kisiye atanan (grup1, her zaman) + ekibe atanan (grup2,
/// "Ekip Isleri" yetkisi varsa). Tek birlesik liste; her kayit scope rozeti tasir.
final assignedWorksProvider = FutureProvider<List<MobileWork>>((ref) async {
  final dio = ref.read(apiClientProvider);
  final user = ref.watch(authStateProvider.select((s) => s.value?.user));
  if (user == null) return const [];

  final results = <MobileWork>[];

  // Grup 1 — bana atanan (employeeId varsa)
  if (user.employeeId != null && user.employeeId!.isNotEmpty) {
    final r = await dio.get(ApiConstants.mobileAssignedToMe,
        queryParameters: {'employeeId': user.employeeId, 'pageSize': 100});
    results.addAll(_parseList(r.data, MobileWorkScope.personal));
  }

  // Grup 2 — ekip isleri (yetki + saha ekibi uyeligi varsa)
  final canTeam = ref.watch(canSeeTeamWorksProvider);
  final teamIds = user.fieldTeams.map((m) => m.organizationId).toList();
  if (canTeam && teamIds.isNotEmpty) {
    final r = await dio.get(ApiConstants.mobileTeamWorks,
        queryParameters: {'organizationIds': teamIds, 'pageSize': 100},
        options: Options(listFormat: ListFormat.multiCompatible));
    results.addAll(_parseList(r.data, MobileWorkScope.team));
  }

  return results;
});

/// Sayfa B — "Birim Isleri": AKTIF birimde (ve alt birimlerinde) bekleyen işler.
/// Web is listesiyle birebir ayni kapsami kullanmak icin mevcut /Work/all
/// endpoint'i, web'in kullandigi `X-Active-Organization-Id` header'i ile cagrilir
/// (scope = aktif birim + descendants). stepStatusId=1230001 (AtamaDurumunda) ile
/// yalniz dagitim bekleyen/atanmamis isler suzulur. "Birim Isleri" yetkisi gerekir.
final unitWorksProvider = FutureProvider<List<MobileWork>>((ref) async {
  final dio = ref.read(apiClientProvider);
  final canUnit = ref.watch(canSeeUnitWorksProvider);
  final orgId = ref.watch(activeOrganizationProvider);
  if (!canUnit || orgId == null) return const [];

  final r = await dio.get(
    ApiConstants.works, // '/Work/all'
    queryParameters: {'stepStatusId': 1230001, 'pageSize': 100},
    options: Options(headers: {'X-Active-Organization-Id': orgId}),
  );
  return _parseList(r.data, MobileWorkScope.unit);
});
