import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../services/secure_storage_service.dart';
import 'auth_interceptor.dart';

final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
);

/// API base URL - gelistirme ortamina gore degistir
/// VPS (emulator + gercek cihaz + web hepsi erisir): http://187.127.72.4:5000
/// Lokal backend + Android emulator icin: http://10.0.2.2:5000
/// Production icin: https://api.adsum.gov
/// Not: HTTP (cleartext) kullanildigindan AndroidManifest'te
/// android:usesCleartextTraffic="true" gereklidir.
const String _devBaseUrl = 'http://187.127.72.4:5000';

/// Ana Dio HTTP client provider'i
/// Tum uygulama bu tek instance'i kullanir
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _devBaseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      sendTimeout: AppConstants.sendTimeout,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Auth interceptor - token ekleme ve 401 refresh
  final storage = ref.read(secureStorageProvider);
  dio.interceptors.add(AuthInterceptor(dio: dio, storage: storage));

  // Log interceptor - sadece debug modda
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => logger.d(obj),
      ),
    );
  }

  return dio;
});
