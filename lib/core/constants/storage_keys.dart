/// Secure storage ve SharedPreferences anahtarlari
class StorageKeys {
  StorageKeys._();

  // Auth tokens (secure storage)
  static const String accessToken = 'adsum_access_token';
  static const String refreshToken = 'adsum_refresh_token';
  static const String tokenExpiry = 'adsum_token_expiry';

  // User data (secure storage)
  static const String userId = 'adsum_user_id';
  static const String userData = 'adsum_user_data';

  // Preferences (shared preferences)
  static const String themeMode = 'adsum_theme_mode';
  static const String biometricEnabled = 'adsum_biometric_enabled';
  static const String hasLoggedInBefore = 'adsum_has_logged_in';
  static const String fcmToken = 'adsum_fcm_token';
  static const String locale = 'adsum_locale';
}
