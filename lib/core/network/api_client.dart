import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';
import 'session_events.dart';

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (Ref ref) => ApiClient(
    ref.watch(tokenStorageProvider),
    ref.watch(sessionEventsProvider),
  ),
);

/// Talks to the Stark VMS API.
///
/// Every successful body is wrapped in a `data` field by the server, so the
/// request helpers answer with that payload. Failures always surface as an
/// [ApiException].
class ApiClient {
  ApiClient(this._tokens, this._sessionEvents, {Dio? dio})
    : _dio = dio ?? Dio() {
    _dio.options = _dio.options.copyWith(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.requestTimeout,
      receiveTimeout: AppConfig.requestTimeout,
      sendTimeout: AppConfig.requestTimeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // Status handling lives in the interceptor below.
      validateStatus: (int? status) => status != null && status < 400,
    );
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _attachToken, onError: _noteExpiredToken),
    );
  }

  static const String _loginPath = '/api/auth/login';

  final Dio _dio;
  final TokenStorage _tokens;
  final SessionEvents _sessionEvents;

  Future<void> _attachToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path != _loginPath) {
      final String? token = await _tokens.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  void _noteExpiredToken(DioException error, ErrorInterceptorHandler handler) {
    final bool rejectedToken = error.response?.statusCode == 401;
    // A rejected sign-in is a wrong password, not an expired session.
    if (rejectedToken && error.requestOptions.path != _loginPath) {
      _sessionEvents.reportSessionExpired();
    }
    handler.next(error);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post<dynamic>(path, data: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put<dynamic>(path, data: body));

  Future<void> delete(String path) async {
    await _send(() => _dio.delete<dynamic>(path));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final Response<dynamic> response = await request();
      final dynamic body = response.data;
      if (body is Map && body.containsKey('data')) {
        return body['data'];
      }
      return body;
    } on DioException catch (error) {
      throw ApiException.from(error);
    }
  }
}
