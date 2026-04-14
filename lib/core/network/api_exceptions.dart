/// API hata siniflari hiyerarsisi
sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 401 - Yetkisiz erisim
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.',
    super.statusCode = 401,
  });
}

/// 403 - Yasak erisim
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Bu işlem için yetkiniz bulunmamaktadır.',
    super.statusCode = 403,
  });
}

/// 404 - Bulunamadi
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'İstenen kaynak bulunamadı.',
    super.statusCode = 404,
  });
}

/// 422 - Validasyon hatasi
class ValidationException extends ApiException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    super.message = 'Girdiğiniz bilgilerde hatalar var.',
    super.statusCode = 422,
    this.fieldErrors = const {},
    super.data,
  });
}

/// 500+ - Sunucu hatasi
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin.',
    super.statusCode = 500,
  });
}

/// Ag baglantisi yok
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'İnternet bağlantınızı kontrol ediniz.',
    super.statusCode,
  });
}

/// Istek zaman asimi
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.',
    super.statusCode,
  });
}
