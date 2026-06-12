/// Mobil iste gosterilen is ozeti — BE GetAllWorksPagedResponse'tan map'lenir.
/// Hangi gruba ait oldugu (rozet icin) [scope] ile isaretlenir.
enum MobileWorkScope { personal, team, unit }

class MobileWork {
  final String id;
  final String code;
  final String workTypeName;
  final String workGroupName;
  final String? stepName;
  final int stepStatusId;
  final String stepStatusName;
  final String? description;
  final int priority;
  final DateTime? createdAt;
  final String? districtName;
  final String? quarterName;
  final String? csbmName;
  final String? buildingName;
  final String? apartmentNo;
  final String? primaryAssigneeName;
  final String? primaryAssignmentTypeName;
  final String? primaryAssigneeOrganizationId;
  final int assignmentCount;

  /// İş adımının rengi (#RRGGBB) — admin tanımlı. Kart accent'i/badge tinti bundan gelir.
  final String? stepColor;

  /// Csbm tip adı (Cadde/Sokak/Bulvar...).
  final String? csbmTypeName;

  /// İşin harita konumu (varsa). Haritada pin + mesafe için.
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  /// Bu kaydin hangi listeye/gruba ait oldugu (rozet icin). Servis doldurur.
  final MobileWorkScope scope;

  const MobileWork({
    required this.id,
    required this.code,
    required this.workTypeName,
    required this.workGroupName,
    this.stepName,
    required this.stepStatusId,
    required this.stepStatusName,
    this.description,
    required this.priority,
    this.createdAt,
    this.districtName,
    this.quarterName,
    this.csbmName,
    this.buildingName,
    this.apartmentNo,
    this.primaryAssigneeName,
    this.primaryAssignmentTypeName,
    this.primaryAssigneeOrganizationId,
    this.assignmentCount = 0,
    this.stepColor,
    this.csbmTypeName,
    this.latitude,
    this.longitude,
    this.scope = MobileWorkScope.personal,
  });

  /// Tam adres ozeti: csbm (+ tip) , mahalle, ilce.
  String get addressSummary {
    final parts = <String>[];
    if (csbmName?.isNotEmpty == true) {
      parts.add(csbmTypeName?.isNotEmpty == true ? '$csbmName $csbmTypeName' : csbmName!);
    }
    if (quarterName?.isNotEmpty == true) parts.add(quarterName!);
    if (districtName?.isNotEmpty == true) parts.add(districtName!);
    return parts.join(', ');
  }

  /// Bina/kapı bilgisi (varsa) — detay sheet'inde gosterilir.
  String? get buildingSummary {
    final parts = <String>[];
    if (buildingName?.isNotEmpty == true) parts.add('Bina: $buildingName');
    if (apartmentNo?.isNotEmpty == true) parts.add('Kapı: $apartmentNo');
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// Aciklama metni temizlenmis (basindaki "KOD — Tip" otomatik onekini at, kullanici notunu birak).
  String? get cleanDescription {
    final d = description?.trim();
    if (d == null || d.isEmpty) return null;
    final lines = d.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return null;
    // Ilk satir "D01006 — EPM..." gibi otomatik baslik ise ve baska satir varsa onu atla.
    if (lines.length > 1 && (lines.first.contains('—') || lines.first.startsWith('D'))) {
      return lines.skip(1).join('\n');
    }
    return lines.join('\n');
  }

  bool get isFieldWork => workGroupName.toLowerCase().contains('saha');

  factory MobileWork.fromJson(Map<String, dynamic> j, MobileWorkScope scope) {
    return MobileWork(
      id: (j['id'] as String?) ?? '',
      code: (j['code'] as String?) ?? '',
      workTypeName: (j['workTypeName'] as String?) ?? '',
      workGroupName: (j['workGroupName'] as String?) ?? '',
      stepName: j['stepName'] as String?,
      stepStatusId: (j['stepStatusId'] as num?)?.toInt() ?? 0,
      stepStatusName: (j['stepStatusName'] as String?) ?? '',
      description: j['description'] as String?,
      priority: (j['priority'] as num?)?.toInt() ?? 3,
      createdAt: j['createdAt'] != null ? DateTime.tryParse(j['createdAt'].toString()) : null,
      districtName: j['districtName'] as String?,
      quarterName: j['quarterName'] as String?,
      csbmName: j['csbmName'] as String?,
      buildingName: j['buildingName'] as String?,
      apartmentNo: j['apartmentNo'] as String?,
      primaryAssigneeName: j['primaryAssigneeName'] as String?,
      primaryAssignmentTypeName: j['primaryAssignmentTypeName'] as String?,
      primaryAssigneeOrganizationId: j['primaryAssigneeOrganizationId'] as String?,
      assignmentCount: (j['assignmentCount'] as num?)?.toInt() ?? 0,
      stepColor: j['stepColor'] as String?,
      csbmTypeName: j['csbmTypeName'] as String?,
      latitude: (j['latitude'] as num?)?.toDouble(),
      longitude: (j['longitude'] as num?)?.toDouble(),
      scope: scope,
    );
  }
}
