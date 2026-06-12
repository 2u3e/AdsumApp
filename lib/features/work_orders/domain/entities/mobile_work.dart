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
    this.scope = MobileWorkScope.personal,
  });

  /// Kisa adres ozeti (mahalle, ilce).
  String get addressSummary {
    final parts = <String>[];
    if (quarterName?.isNotEmpty == true) parts.add(quarterName!);
    if (districtName?.isNotEmpty == true) parts.add(districtName!);
    return parts.join(', ');
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
      scope: scope,
    );
  }
}
