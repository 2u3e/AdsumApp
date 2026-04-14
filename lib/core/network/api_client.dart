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
/// Android emulator icin: https://10.0.2.2:7196
/// Gercek cihaz/production icin: https://api.adsum.gov
const String _devBaseUrl = 'https://10.0.2.2:7196';

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
