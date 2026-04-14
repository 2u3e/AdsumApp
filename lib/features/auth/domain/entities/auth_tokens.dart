/// Auth token entity
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isAboutToExpire =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));

  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
}
