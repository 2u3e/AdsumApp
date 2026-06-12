import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';

/// Auth API islemleri - OpenIddict backend ile iletisim
class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  /// OAuth 2.0 Password Grant ile giris yap
  /// DIKKAT: form-urlencoded format kullanilmali, JSON degil!
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      ApiConstants.tokenEndpoint,
      data: {
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': AppConstants.oauthScopes,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Accept': 'application/json'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Refresh token ile yeni token al
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.tokenEndpoint,
      data: {
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Accept': 'application/json'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Cikis yap - token iptal
  Future<void> logout(String token) async {
    try {
      await _dio.post(
        ApiConstants.logoutEndpoint,
        data: {'token': token},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
    } catch (_) {
      // Logout basarisiz olsa bile devam et
    }
  }

  /// Mevcut kullanici bilgilerini getir
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dio.get(ApiConstants.users);
    return response.data as Map<String, dynamic>;
  }

  /// Oturum bilgisi: employeeId + memberships (org + rol + isFieldTeam).
  /// Response zarfindan (.data) icteki nesneyi dondurur.
  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get(ApiConstants.authMe);
    final body = response.data;
    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    return body as Map<String, dynamic>;
  }
}
