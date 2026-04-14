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
    return userName.substring(0, 2).toUpperCase();
  }

  bool get isAdmin => roles.contains('Admin') || roles.contains('admin');

  bool hasPermission(String permission) => permissions.contains(permission);

  bool hasRole(String role) => roles.contains(role);
}
