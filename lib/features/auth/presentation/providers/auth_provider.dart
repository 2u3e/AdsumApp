import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user.dart';

/// Auth durumu
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Auth state provider - tum uygulama auth durumunu buradan okur
final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Auth notifier - giris/cikis islemlerini yonetir
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final SecureStorageService _storage;
  late final AuthRemoteDatasource _authDatasource;
  Timer? _refreshTimer;

  @override
  Future<AuthState> build() async {
    _storage = ref.read(secureStorageProvider);
    _authDatasource = AuthRemoteDatasource(ref.read(apiClientProvider));

    // Mevcut token'lari kontrol et
    final token = await _storage.read(StorageKeys.accessToken);
    if (token != null) {
      try {
        final user = _parseUserFromToken(token);
        _scheduleTokenRefresh();
        return AuthState(isAuthenticated: true, user: user);
      } catch (_) {
        await _clearTokens();
      }
    }

    return const AuthState(isAuthenticated: false);
  }

  /// Giris yap
  Future<void> login(String username, String password) async {
    state = const AsyncValue.data(
      AuthState(isLoading: true),
    );

    try {
      final response = await _authDatasource.login(
        username: username,
        password: password,
      );

      await _saveTokens(response);
      final user = _parseUserFromToken(response['access_token'] as String);
      _scheduleTokenRefresh();

      state = AsyncValue.data(
        AuthState(isAuthenticated: true, user: user),
      );
    } catch (e) {
      String errorMessage = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';

      state = AsyncValue.data(
        AuthState(isAuthenticated: false, error: errorMessage),
      );
    }
  }

  /// Cikis yap
  Future<void> logout() async {
    _refreshTimer?.cancel();

    try {
      final token = await _storage.read(StorageKeys.accessToken);
      if (token != null) {
        await _authDatasource.logout(token);
      }
    } catch (_) {}

    await _clearTokens();
    state = const AsyncValue.data(AuthState(isAuthenticated: false));
  }

  /// JWT token'dan kullanici bilgisi cikart
  User _parseUserFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Geçersiz token');

    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;

    // Rolleri al (tek string veya liste olabilir)
    List<String> roles = [];
    final roleData = payload['role'] ?? payload['roles'];
    if (roleData is String) {
      roles = [roleData];
    } else if (roleData is List) {
      roles = roleData.cast<String>();
    }

    // Permission'lari al
    List<String> permissions = [];
    final permData = payload['permission'] ?? payload['permissions'];
    if (permData is String) {
      permissions = [permData];
    } else if (permData is List) {
      permissions = permData.cast<String>();
    }

    return User(
      id: payload['sub'] as String? ?? '',
      userName: payload['name'] as String? ?? payload['preferred_username'] as String? ?? '',
      email: payload['email'] as String? ?? '',
      firstName: payload['given_name'] as String?,
      lastName: payload['family_name'] as String?,
      roles: roles,
      permissions: permissions,
    );
  }

  /// Token'lari kaydet
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await _storage.write(
      StorageKeys.accessToken,
      data['access_token'] as String,
    );

    if (data['refresh_token'] != null) {
      await _storage.write(
        StorageKeys.refreshToken,
        data['refresh_token'] as String,
      );
    }

    if (data['expires_in'] != null) {
      final expiry = DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      );
      await _storage.write(StorageKeys.tokenExpiry, expiry.toIso8601String());
    }
  }

  /// Tum token'lari temizle
  Future<void> _clearTokens() async {
    await _storage.delete(StorageKeys.accessToken);
    await _storage.delete(StorageKeys.refreshToken);
    await _storage.delete(StorageKeys.tokenExpiry);
    await _storage.delete(StorageKeys.userId);
    await _storage.delete(StorageKeys.userData);
  }

  /// Token yenileme zamanlayicisi - suresi dolmadan 60sn once
  void _scheduleTokenRefresh() async {
    _refreshTimer?.cancel();

    final expiryStr = await _storage.read(StorageKeys.tokenExpiry);
    if (expiryStr == null) return;

    final expiry = DateTime.parse(expiryStr);
    final refreshAt = expiry.subtract(const Duration(seconds: 60));
    final delay = refreshAt.difference(DateTime.now());

    if (delay.isNegative) {
      // Zaten suresi gecmis, hemen yenile
      _tryRefreshToken();
    } else {
      _refreshTimer = Timer(delay, _tryRefreshToken);
    }
  }

  /// Token yenileme denemesi
  Future<void> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(StorageKeys.refreshToken);
      if (refreshToken == null) return;

      final response = await _authDatasource.refreshToken(refreshToken);
      await _saveTokens(response);
      _scheduleTokenRefresh();
    } catch (_) {
      // Refresh basarisiz - kullaniciyi cikis yaptir
      await logout();
    }
  }
}
