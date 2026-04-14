import 'work_enums.dart';

/// Is emri entity
class WorkOrder {
  final String id;
  final String workNumber;
  final String workTypeName;
  final String workTypeIcon;
  final WorkStatus status;
  final WorkPriority priority;
  final String? description;

  // Adres
  final String district; // Ilce
  final String neighborhood; // Mahalle
  final String? street; // Cadde/Sokak
  final String? buildingNo;
  final String fullAddress;
  final double? latitude;
  final double? longitude;

  // Basvuran
  final String? applicantName;
  final String? applicantPhone;

  // Atanan
  final String? assigneeName;
  final String? assigneeDepartment;

  // Tarihler
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? startedAt;
  final DateTime? completedAt;

  // Adimlar
  final String currentStepName;
  final List<WorkHistoryEntry> history;
  final List<WorkStep> steps;

  // Ek bilgiler
  final int commentCount;
  final int attachmentCount;
  final int? estimatedHours;
  final int? actualHours;
  final double completionPercentage;
  final List<String> tags;

  const WorkOrder({
    required this.id,
    required this.workNumber,
    required this.workTypeName,
    this.workTypeIcon = 'build',
    required this.status,
    required this.priority,
    this.description,
    required this.district,
    required this.neighborhood,
    this.street,
    this.buildingNo,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    this.applicantName,
    this.applicantPhone,
    this.assigneeName,
    this.assigneeDepartment,
    required this.createdAt,
    this.dueDate,
    this.startedAt,
    this.completedAt,
    required this.currentStepName,
    this.history = const [],
    this.steps = const [],
    this.commentCount = 0,
    this.attachmentCount = 0,
    this.estimatedHours,
    this.actualHours,
    this.completionPercentage = 0,
    this.tags = const [],
  });

  /// Kac gun once olusturuldu
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${(diff.inDays / 7).floor()} hafta önce';
  }

  /// Bekleme suresi
  String get waitingDuration {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inHours < 24) return '${diff.inHours} saat';
    return '${diff.inDays} gün';
  }

  /// Kisa adres
  String get shortAddress {
    if (street != null) {
      return '$neighborhood, $street${buildingNo != null ? ' No:$buildingNo' : ''}';
    }
    return '$neighborhood, $district';
  }
}

/// Is gecmisi giris kaydı
class WorkHistoryEntry {
  final String id;
  final String action;
  final String description;
  final String performedBy;
  final DateTime performedAt;
  final String? note;
  final List<String> attachmentUrls;

  const WorkHistoryEntry({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.performedAt,
    this.note,
    this.attachmentUrls = const [],
  });
}

/// Is adimi
class WorkStep {
  final String id;
  final String name;
  final int order;
  final WorkStepStatus status;
  final String? assignee;
  final DateTime? enteredAt;
  final DateTime? completedAt;
  final List<WorkStepField> fields;

  const WorkStep({
    required this.id,
    required this.name,
    required this.order,
    required this.status,
    this.assignee,
    this.enteredAt,
    this.completedAt,
    this.fields = const [],
  });
}

/// Adim icin dinamik alan
class WorkStepField {
  final String id;
  final String label;
  final WorkFieldType type;
  final bool isRequired;
  final String? value;
  final List<String>? options; // select tipi icin

  const WorkStepField({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.value,
    this.options,
  });
}

/// Dinamik alan tipleri
enum WorkFieldType {
  text,
  textarea,
  number,
  select,
  multiSelect,
  photo,
  date,
  location,
  signature,
  checkbox,
}
