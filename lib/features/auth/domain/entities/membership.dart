/// Kullanicinin bir birimdeki uyeligi — o birim + o birimde sahip oldugu roller.
/// Coklu birim/rol: kullanici birden fazla birimde (farkli rollerle) gorev alabilir.
class Membership {
  final String organizationId;
  final String organizationName;
  final String? organizationShortName;

  /// OrganizationTypes (ReferenceData). Saha ekibi = 1060013.
  final int organizationTypeId;

  /// Bu birim bir Saha Ekibi mi? Mobil "Ekip Isleri" sayfasi bunu kullanir.
  final bool isFieldTeam;

  final List<String> roleNames;

  const Membership({
    required this.organizationId,
    required this.organizationName,
    this.organizationShortName,
    required this.organizationTypeId,
    required this.isFieldTeam,
    this.roleNames = const [],
  });

  String get displayName =>
      organizationShortName?.isNotEmpty == true ? organizationShortName! : organizationName;

  String get rolesSummary => roleNames.isEmpty ? '' : roleNames.join(', ');

  factory Membership.fromJson(Map<String, dynamic> json) {
    final roles = <String>[];
    final r = json['roles'];
    if (r is List) {
      for (final item in r) {
        if (item is Map && item['roleName'] != null) {
          roles.add(item['roleName'] as String);
        } else if (item is String) {
          roles.add(item);
        }
      }
    }
    return Membership(
      organizationId: json['organizationId'] as String,
      organizationName: (json['organizationName'] as String?) ?? '',
      organizationShortName: json['organizationShortName'] as String?,
      organizationTypeId: (json['organizationTypeId'] as num?)?.toInt() ?? 0,
      isFieldTeam: (json['isFieldTeam'] as bool?) ?? false,
      roleNames: roles,
    );
  }
}
