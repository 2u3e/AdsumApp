import 'membership.dart';

/// Kullanici entity - domain katmani
class User {
  final String id;
  final String userName;
  final String email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;
  final List<String> permissions;
  final String? avatarUrl;
  final String? organizationName;
  final String? departmentName;

  /// OMS calisan kaydi id'si (varsa). "Bana atanan isler" sorgusu bunu kullanir.
  final String? employeeId;

  /// Kullanicinin tum birim uyelikleri (coklu birim + rol). Aktif birim secici bunu listeler.
  final List<Membership> memberships;

  const User({
    required this.id,
    required this.userName,
    required this.email,
    this.firstName,
    this.lastName,
    this.roles = const [],
    this.permissions = const [],
    this.avatarUrl,
    this.organizationName,
    this.departmentName,
    this.employeeId,
    this.memberships = const [],
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return userName;
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return userName.length >= 2 ? userName.substring(0, 2).toUpperCase() : userName.toUpperCase();
  }

  bool get isAdmin => roles.contains('Admin') || roles.contains('admin');

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasRole(String role) => roles.contains(role);

  /// Saha ekibi olan uyelikler (Ekip Isleri sayfasi icin).
  List<Membership> get fieldTeams => memberships.where((m) => m.isFieldTeam).toList();

  /// Saha ekibi olmayan birimler (Birim Isleri sayfasi icin).
  List<Membership> get units => memberships.where((m) => !m.isFieldTeam).toList();

  /// /Auth/me cevabindan (Response.data) User olustur.
  factory User.fromMeJson(Map<String, dynamic> json) {
    final roles = <String>[];
    if (json['roles'] is List) {
      for (final r in (json['roles'] as List)) {
        if (r is String) roles.add(r);
      }
    }
    final memberships = <Membership>[];
    if (json['memberships'] is List) {
      for (final m in (json['memberships'] as List)) {
        if (m is Map<String, dynamic>) memberships.add(Membership.fromJson(m));
      }
    }
    return User(
      id: (json['id'] as String?) ?? '',
      userName: (json['userName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      roles: roles,
      permissions: const [],
      avatarUrl: json['profilePictureUrl'] as String?,
      employeeId: json['employeeId'] as String?,
      memberships: memberships,
    );
  }
}
