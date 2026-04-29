import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/epm_models.dart';

/// EPM (Kazı Ruhsatı / AYKOME) API client.
/// Saha ekipleri için: ruhsat detay görüntüleme, denetim raporu kaydetme,
/// public ruhsat doğrulama (QR kodu).
class EpmPermitClient {
  EpmPermitClient(this._dio);

  final Dio _dio;

  /// BMS work tipinden açılmış EPM ruhsat detayını getirir.
  Future<EpmPermitDetail> getPermit(String permitId) async {
    final res = await _dio.get('/Epm/Permits/$permitId');
    return EpmPermitDetail.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// Verilen denetim tipi için aktif checklist kalemlerini getirir.
  Future<List<EpmChecklistItem>> getChecklist(int inspectionType) async {
    final res = await _dio.get(
      '/Epm/ChecklistTemplates',
      queryParameters: {'inspectionType': inspectionType, 'isActive': true},
    );
    final list = (res.data['data'] as List).cast<Map<String, dynamic>>();
    return list.map(EpmChecklistItem.fromJson).toList();
  }

  /// Saha ekibi denetim raporunu kapatınca çağrılır.
  Future<String> createInspection(EpmInspectionPayload payload) async {
    final res = await _dio.post('/Epm/Inspections', data: payload.toJson());
    return res.data['data'] as String;
  }

  /// Saha denetiminde QR/kısa kodla ruhsat doğrulama (zabıta için).
  Future<EpmPublicVerification> verifyPublic(String shortCode) async {
    final res = await _dio.get('/Epm/PublicVerification/$shortCode');
    return EpmPublicVerification.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// Permit-bağlı işler için statü geçişi (ör. ekipten ofise dönüş bildirimleri).
  Future<bool> performTransition(String permitId, EpmTransitionPayload payload) async {
    final res = await _dio.post('/Epm/Permits/$permitId/transition', data: payload.toJson());
    return res.data['data'] as bool;
  }
}

final epmPermitClientProvider = Provider<EpmPermitClient>((ref) {
  return EpmPermitClient(ref.read(apiClientProvider));
});
