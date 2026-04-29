/// EPM modülü için minimal Dart model tanımları.
/// Sahada en sık kullanılacak alanlar — UI tarafı genişledikçe DTO'lar da büyür.

class EpmPermitDetail {
  final String id;
  final String permitCode;
  final String agencyId;
  final String? agencyName;
  final String title;
  final String? description;
  final int statusId;
  final bool isEmergency;
  final int? districtId;
  final int? quarterId;
  final int? csbmId;
  final String? streetNote;
  final DateTime plannedStartDate;
  final DateTime plannedEndDate;
  final double declaredAreaSqM;
  final int trafficImpactLevelId;
  final int billingPayerModeId;

  EpmPermitDetail({
    required this.id,
    required this.permitCode,
    required this.agencyId,
    this.agencyName,
    required this.title,
    this.description,
    required this.statusId,
    required this.isEmergency,
    this.districtId,
    this.quarterId,
    this.csbmId,
    this.streetNote,
    required this.plannedStartDate,
    required this.plannedEndDate,
    required this.declaredAreaSqM,
    required this.trafficImpactLevelId,
    required this.billingPayerModeId,
  });

  factory EpmPermitDetail.fromJson(Map<String, dynamic> j) => EpmPermitDetail(
        id: j['id'] as String,
        permitCode: j['permitCode'] as String,
        agencyId: j['agencyId'] as String,
        agencyName: j['agencyName'] as String?,
        title: j['title'] as String,
        description: j['description'] as String?,
        statusId: j['statusId'] as int,
        isEmergency: j['isEmergency'] as bool,
        districtId: j['districtId'] as int?,
        quarterId: j['quarterId'] as int?,
        csbmId: j['csbmId'] as int?,
        streetNote: j['streetNote'] as String?,
        plannedStartDate: DateTime.parse(j['plannedStartDate'] as String),
        plannedEndDate: DateTime.parse(j['plannedEndDate'] as String),
        declaredAreaSqM: (j['declaredAreaSqM'] as num).toDouble(),
        trafficImpactLevelId: j['trafficImpactLevelId'] as int,
        billingPayerModeId: j['billingPayerModeId'] as int,
      );
}

class EpmChecklistItem {
  final String id;
  final int applicableInspectionType;
  final String code;
  final String name;
  final String? descriptionForInspector;
  final bool photoRequired;
  final int order;

  EpmChecklistItem({
    required this.id,
    required this.applicableInspectionType,
    required this.code,
    required this.name,
    this.descriptionForInspector,
    required this.photoRequired,
    required this.order,
  });

  factory EpmChecklistItem.fromJson(Map<String, dynamic> j) => EpmChecklistItem(
        id: j['id'] as String,
        applicableInspectionType: j['applicableInspectionType'] as int,
        code: j['code'] as String,
        name: j['name'] as String,
        descriptionForInspector: j['descriptionForInspector'] as String?,
        photoRequired: j['photoRequired'] as bool,
        order: j['order'] as int,
      );
}

class EpmInspectionPayload {
  final String permitId;
  final String permitWorkOrderId;
  final int inspectionType;
  final String inspectorUserId;
  final double? latitude;
  final double? longitude;
  final int? zoneTypeId;
  final double? measuredLengthM;
  final double? measuredWidthM;
  final double? measuredDepthM;
  final double? measuredAreaSqM;
  final bool violationFound;
  final int? violationCategoryId;
  final String? violationDescription;
  final int photoCount;
  final bool settlementDetected;
  final int? settlementSeverityId;
  final bool restorationRequired;
  final String? restorationNotes;
  final String? notes;
  final String? checklistResultJson;
  final List<EpmInspectionItemPayload>? items;

  EpmInspectionPayload({
    required this.permitId,
    required this.permitWorkOrderId,
    required this.inspectionType,
    required this.inspectorUserId,
    this.latitude,
    this.longitude,
    this.zoneTypeId,
    this.measuredLengthM,
    this.measuredWidthM,
    this.measuredDepthM,
    this.measuredAreaSqM,
    this.violationFound = false,
    this.violationCategoryId,
    this.violationDescription,
    this.photoCount = 0,
    this.settlementDetected = false,
    this.settlementSeverityId,
    this.restorationRequired = false,
    this.restorationNotes,
    this.notes,
    this.checklistResultJson,
    this.items,
  });

  Map<String, dynamic> toJson() => {
        'permitId': permitId,
        'permitWorkOrderId': permitWorkOrderId,
        'inspectionType': inspectionType,
        'inspectorUserId': inspectorUserId,
        'latitude': latitude,
        'longitude': longitude,
        'zoneTypeId': zoneTypeId,
        'measuredLengthM': measuredLengthM,
        'measuredWidthM': measuredWidthM,
        'measuredDepthM': measuredDepthM,
        'measuredAreaSqM': measuredAreaSqM,
        'violationFound': violationFound,
        'violationCategoryId': violationCategoryId,
        'violationDescription': violationDescription,
        'photoCount': photoCount,
        'settlementDetected': settlementDetected,
        'settlementSeverityId': settlementSeverityId,
        'restorationRequired': restorationRequired,
        'restorationNotes': restorationNotes,
        'notes': notes,
        'checklistResultJson': checklistResultJson,
        'items': items?.map((i) => i.toJson()).toList(),
      };
}

class EpmInspectionItemPayload {
  final String? checklistTemplateItemId;
  final String code;
  final String name;
  final int result; // 1=Ok, 2=NotOk, 3=NotApplicable
  final String? notes;
  final String? photoDocumentRefs;

  EpmInspectionItemPayload({
    this.checklistTemplateItemId,
    required this.code,
    required this.name,
    required this.result,
    this.notes,
    this.photoDocumentRefs,
  });

  Map<String, dynamic> toJson() => {
        'checklistTemplateItemId': checklistTemplateItemId,
        'code': code,
        'name': name,
        'result': result,
        'notes': notes,
        'photoDocumentRefs': photoDocumentRefs,
      };
}

class EpmTransitionPayload {
  final String permitId;
  final int toStatusId;
  final String changedByUserId;
  final String? reason;

  EpmTransitionPayload({
    required this.permitId,
    required this.toStatusId,
    required this.changedByUserId,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'permitId': permitId,
        'toStatusId': toStatusId,
        'changedByUserId': changedByUserId,
        'reason': reason,
      };
}

class EpmPublicVerification {
  final String permitCode;
  final String agencyName;
  final String title;
  final int statusId;
  final DateTime plannedStartDate;
  final DateTime plannedEndDate;
  final String? streetNote;
  final DateTime expiresAt;

  EpmPublicVerification({
    required this.permitCode,
    required this.agencyName,
    required this.title,
    required this.statusId,
    required this.plannedStartDate,
    required this.plannedEndDate,
    this.streetNote,
    required this.expiresAt,
  });

  factory EpmPublicVerification.fromJson(Map<String, dynamic> j) => EpmPublicVerification(
        permitCode: j['permitCode'] as String,
        agencyName: j['agencyName'] as String,
        title: j['title'] as String,
        statusId: j['statusId'] as int,
        plannedStartDate: DateTime.parse(j['plannedStartDate'] as String),
        plannedEndDate: DateTime.parse(j['plannedEndDate'] as String),
        streetNote: j['streetNote'] as String?,
        expiresAt: DateTime.parse(j['expiresAt'] as String),
      );
}
