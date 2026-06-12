import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers/active_org_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';

/// Rapor kartı kapsamı.
enum ReportScope { team, personal, unit }

/// Rapor dönemi (BE Period: 1=günlük, 2=haftalık, 3=aylık).
enum ReportPeriod { daily, weekly, monthly }

extension ReportPeriodX on ReportPeriod {
  int get apiValue => switch (this) { ReportPeriod.daily => 1, ReportPeriod.weekly => 2, ReportPeriod.monthly => 3 };
  String get label => switch (this) { ReportPeriod.daily => 'Günlük', ReportPeriod.weekly => 'Haftalık', ReportPeriod.monthly => 'Aylık' };
}

/// Rapor kartı sayıları.
class MobileStats {
  final int total; // toplam bekleyen
  final int carriedOver; // devreden
  final int arrived; // dönemde gelen
  final int inProgress; // devam eden
  final int completed; // dönemde tamamlanan
  const MobileStats({
    this.total = 0,
    this.carriedOver = 0,
    this.arrived = 0,
    this.inProgress = 0,
    this.completed = 0,
  });

  factory MobileStats.fromJson(Map<String, dynamic> j) => MobileStats(
        total: (j['total'] as num?)?.toInt() ?? 0,
        carriedOver: (j['carriedOver'] as num?)?.toInt() ?? 0,
        arrived: (j['arrived'] as num?)?.toInt() ?? 0,
        inProgress: (j['inProgress'] as num?)?.toInt() ?? 0,
        completed: (j['completed'] as num?)?.toInt() ?? 0,
      );
}

/// Seçili rapor dönemi (tüm kartlar ortak).
final reportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.daily);

/// Kapsam + döneme göre rapor istatistikleri.
final mobileStatsProvider =
    FutureProvider.family<MobileStats, (ReportScope, ReportPeriod)>((ref, key) async {
  final (scope, period) = key;
  final dio = ref.read(apiClientProvider);
  final user = ref.watch(authStateProvider.select((s) => s.value?.user));
  if (user == null) return const MobileStats();

  final qp = <String, dynamic>{'period': period.apiValue};
  Options? options;

  switch (scope) {
    case ReportScope.personal:
      if (user.employeeId == null || user.employeeId!.isEmpty) return const MobileStats();
      qp['employeeId'] = user.employeeId;
      break;
    case ReportScope.team:
      final teamIds = user.fieldTeams.map((m) => m.organizationId).toList();
      if (teamIds.isEmpty) return const MobileStats();
      qp['organizationIds'] = teamIds;
      options = Options(listFormat: ListFormat.multiCompatible);
      break;
    case ReportScope.unit:
      final orgId = ref.watch(activeOrganizationProvider);
      if (orgId == null) return const MobileStats();
      qp['useActiveOrgScope'] = true;
      options = Options(headers: {'X-Active-Organization-Id': orgId});
      break;
  }

  final r = await dio.get(ApiConstants.mobileStats, queryParameters: qp, options: options);
  final body = r.data;
  final data = (body is Map<String, dynamic>) ? body['data'] : body;
  return data is Map<String, dynamic> ? MobileStats.fromJson(data) : const MobileStats();
});
