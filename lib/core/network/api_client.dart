import 'dart:developer';

import 'package:dio/dio.dart';
import '../auth/session.dart';
import '../tenant/tenant_context.dart';
import 'endpoints.dart';

/// A thin wrapper around Dio with interceptors for:
/// - Bearer token
/// - (optional) tenant/school context header
class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  factory ApiClient({
    required Session? Function() sessionProvider,
    required TenantContext Function() tenantContext,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      _AuthTenantInterceptor(
        sessionProvider: sessionProvider,
        tenantContext: tenantContext,
      ),
    );

    // Optional: simple logging for dev
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (object) => log(object.toString()),
      ),
    );

    return ApiClient._(dio);
  }
  var d = {
    "success": true,
    "data": {
      "count": 4,
      "page": 1,
      "page_size": 10,
      "total_pages": 1,
      "next": null,
      "previous": null,
      "results": [
        {
          "id": "12044e56-d2f4-49de-acee-38e368fd70f2",
          "total_paid": "200.00",
          "student_name": "Student1",
          "academic_year_details": {
            "id": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
            "name": "20225-2026",
          },
          "classroom_name": "4A",
          "total_fee": "0.00",
          "paid_fee": "200.00",
          "dues": -200.0,
          "academic_year": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
        },
        {
          "id": "ca5467b7-7d03-4cd0-b37c-98d07e3e7cdd",
          "total_paid": "0.00",
          "student_name": "Student1",
          "academic_year_details": {
            "id": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
            "name": "20225-2026",
          },
          "classroom_name": "4A",
          "total_fee": "0.00",
          "paid_fee": "0.00",
          "dues": 0.0,
          "academic_year": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
        },
        {
          "id": "846c984f-6e42-4c50-8900-425d63e947ef",
          "total_paid": "1000.00",
          "student_name": "Dilshad",
          "academic_year_details": {
            "id": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
            "name": "20225-2026",
          },
          "classroom_name": "6A",
          "total_fee": "0.00",
          "paid_fee": "1000.00",
          "dues": -1000.0,
          "academic_year": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
        },
        {
          "id": "3ce45c5d-4430-4f8d-a78e-9993649dc65e",
          "total_paid": "7500.00",
          "student_name": "Dilshad",
          "academic_year_details": {
            "id": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
            "name": "20225-2026",
          },
          "classroom_name": "6A",
          "total_fee": "15000.00",
          "paid_fee": "7500.00",
          "dues": 7500.0,
          "academic_year": "0c53a22f-b8af-497d-9df1-23d1d6891b77",
        },
      ],
    },
    "meta": {
      "request_id": "32436cab-1bd5-42ea-b257-5e3612daf687",
      "timestamp": "2026-03-26T06:05:58.849628+00:00",
    },
  };
  // Convenience methods (optional)
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Interceptor that injects:
/// - Authorization: Bearer token
/// - X-School-Id: effective school id (optional)
///
/// If you prefer path-based scoping (/schools/{schoolId}/...), you can remove
/// the X-School-Id part.
class _AuthTenantInterceptor extends Interceptor {
  final Session? Function() sessionProvider;
  final TenantContext Function() tenantContext;

  _AuthTenantInterceptor({
    required this.sessionProvider,
    required this.tenantContext,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = sessionProvider();

    // Attach tenant/school context as a header (useful for multi-tenant APIs)
    // Priority: session.schoolId > tenantContext.selectedSchoolId
    final effectiveSchoolId =
        ((session?.schoolId?.isNotEmpty ?? false) ? session?.schoolId : null) ??
        tenantContext().selectedSchoolId;

    if (effectiveSchoolId != null && effectiveSchoolId.isNotEmpty) {
      options.headers['X-School-Id'] = effectiveSchoolId;
    }

    // Attach bearer token if available
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      // log('Attached Authorization header: ${options.headers['Authorization']}');
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Optional: central place to map errors, handle 401, etc.
    // For initial stage, just pass it through.
    handler.next(err);
  }
}
