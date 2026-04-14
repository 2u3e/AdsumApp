import 'dart:convert';

import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../services/secure_storage_service.dart';
import 'api_client.dart';

/// Auth Interceptor - QueuedInterceptor kullanarak token yonetimi
///
/// QueuedInterceptor: Birden fazla istek 401 aldiginda sadece BIR kez
/// refresh token denemesi yapar, diger istekler kuyrukta bekler.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio dio;
  final SecureStorageService storage;
  bool _isRefreshing = false;

  /// Token eklenmeyecek endpoint'ler
  static const _skipAuthPaths = [
    '/connect/token',
    '/connect/authorize',
    '/connect/userinfo',
  ];

  AuthInterceptor({required this.dio, required this.storage});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Bazi endpoint'ler token gerektirmez
    final shouldSkip = _skipAuthPaths.any(
      (path) => options.path.contains(path),
    );

    if (!shouldSkip) {
      final token = await storage.read(StorageKeys.accessToken);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401 hatasi - token gecersiz, refresh dene
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();
        _isRefreshing = false;

        if (refreshed) {
          // Basarili refresh - orijinal istegi tekrarla
          final token = await storage.read(StorageKeys.accessToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $token';

          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } else {
          // Refresh basarisiz - cikis yap
          await _clearTokens();
          return handler.next(err);
        }
      } catch (e) {
        _isRefreshing = false;
        await _clearTokens();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Refresh token ile yeni access token al
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await storage.read(StorageKeys.refreshToken);
      if (refreshToken == null) return false;

      // DIKKAT: Bu endpoint form-urlencoded bekliyor, JSON degil!
      final response = await Dio().post(
        '${dio.options.baseUrl}${ApiConstants.tokenEndpoint}',
        data: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        await _saveTokens(data);
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Token refresh basarisiz', error: e);
      return false;
    }
  }

  /// Token verilerini kaydet
  Future<void> _saveTokens(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String?;
    final expiresIn = data['expires_in'] as int?;

    await storage.write(StorageKeys.accessToken, accessToken);

    if (refreshToken != null) {
      await storage.write(StorageKeys.refreshToken, refreshToken);
    }

    if (expiresIn != null) {
      final expiry = DateTime.now().add(Duration(seconds: expiresIn));
      await storage.write(
        StorageKeys.tokenExpiry,
        expiry.toIso8601String(),
      );
    }

    // JWT'den kullanici bilgilerini cikart
    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        ) as Map<String, dynamic>;
        await storage.write(StorageKeys.userId, payload['sub'] as String? ?? '');
      }
    } catch (_) {}
  }

  /// Tum token'lari temizle
  Future<void> _clearTokens() async {
    await storage.delete(StorageKeys.accessToken);
    await storage.delete(StorageKeys.refreshToken);
    await storage.delete(StorageKeys.tokenExpiry);
    await storage.delete(StorageKeys.userId);
  }
}
