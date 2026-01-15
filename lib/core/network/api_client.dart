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
    required TenantContext tenantContext,
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
      ),
    );

    return ApiClient._(dio);
  }

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
}

/// Interceptor that injects:
/// - Authorization: Bearer token
/// - X-School-Id: effective school id (optional)
///
/// If you prefer path-based scoping (/schools/{schoolId}/...), you can remove
/// the X-School-Id part.
class _AuthTenantInterceptor extends Interceptor {
  final Session? Function() sessionProvider;
  final TenantContext tenantContext;

  _AuthTenantInterceptor({
    required this.sessionProvider,
    required this.tenantContext,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = sessionProvider();

    // Attach bearer token if available
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }

    // Optional: Attach tenant/school context as a header (useful for multi-tenant APIs)
    final effectiveSchoolId =
        session?.schoolId ?? tenantContext.selectedSchoolId;
    if (effectiveSchoolId != null && effectiveSchoolId.isNotEmpty) {
      options.headers['X-School-Id'] = effectiveSchoolId;
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
