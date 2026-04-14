/// Backend'den gelen standart Response wrapper'i
/// ASP.NET Core backend Response formatina uyumlu
class ApiResponse<T> {
  final int statusCode;
  final String? message;
  final T? data;
  final List<ErrorDetail>? errors;
  final PaginationMeta? pagination;
  final String? correlationId;
  final String? timestampUtc;

  const ApiResponse({
    required this.statusCode,
    this.message,
    this.data,
    this.errors,
    this.pagination,
    this.correlationId,
    this.timestampUtc,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get hasErrors => errors != null && errors!.isNotEmpty;
  bool get hasPagination => pagination != null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      statusCode: json['statusCode'] as int? ?? 0,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => ErrorDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      correlationId: json['correlationId'] as String?,
      timestampUtc: json['timestampUtc'] as String?,
    );
  }
}

/// Hata detay modeli
class ErrorDetail {
  final String? field;
  final String? message;
  final String? code;

  const ErrorDetail({this.field, this.message, this.code});

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      field: json['field'] as String?,
      message: json['message'] as String?,
      code: json['code'] as String?,
    );
  }
}

/// Sayfalama meta verisi
class PaginationMeta {
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['currentPage'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 25,
      totalCount: json['totalCount'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNextPage: json['hasNextPage'] as bool? ?? false,
      hasPreviousPage: json['hasPreviousPage'] as bool? ?? false,
    );
  }
}
