/// Uygulama genelinde kullanilan sabitler
class AppConstants {
  AppConstants._();

  static const String appName = 'ADSUM';
  // Her mobil değişiklikten sonra son haneyi +1 artır (login + anasayfa footer
  // bu tek kaynaktan okur). Kod cihaza ulaştı mı doğrulamak için kullanılır.
  static const String appVersion = '0.2.25';

  // Network
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Pagination
  static const int defaultPageSize = 25;
  static const int maxPageSize = 100;

  // Token
  static const int tokenRefreshBufferSeconds = 60;

  // OAuth2 scopes
  static const String oauthScopes = 'openid email profile roles offline_access';

  // Cache
  static const Duration cacheDuration = Duration(minutes: 5);

  // Animation
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 3);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
}
