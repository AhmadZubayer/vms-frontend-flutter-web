import 'package:dio/dio.dart';

/// A request that the API refused, or could not be reached at all.
class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const <String, String>{},
  });

  final String message;
  final int? statusCode;

  /// Field name to message, taken from the `errors` array of a validation problem.
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => statusCode == 401;

  bool get isForbidden => statusCode == 403;

  bool get isNotFound => statusCode == 404;

  bool get isConflict => statusCode == 409;

  /// Reads an RFC 7807 `application/problem+json` body, or falls back to the
  /// transport failure that stopped the request from being answered.
  factory ApiException.from(DioException error) {
    final Response<dynamic>? response = error.response;
    if (response == null) {
      return ApiException(_transportMessage(error));
    }

    final int? status = response.statusCode;
    final dynamic body = response.data;

    String message = _statusMessage(status);
    final Map<String, String> fields = <String, String>{};

    if (body is Map) {
      final Object? detail = body['detail'] ?? body['title'] ?? body['message'];
      if (detail is String && detail.trim().isNotEmpty) {
        message = detail.trim();
      }

      final Object? errors = body['errors'];
      if (errors is List) {
        for (final Object? entry in errors) {
          if (entry is Map) {
            final Object? field = entry['field'];
            final Object? reason = entry['message'];
            if (field is String && reason is String) {
              fields[field] = reason;
            }
          }
        }
      }
    }

    return ApiException(message, statusCode: status, fieldErrors: fields);
  }

  static String _transportMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return 'The server took too long to answer.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'The server certificate was rejected.';
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        return 'Cannot reach the server. Check that the API is running.';
    }
  }

  static String _statusMessage(int? status) {
    switch (status) {
      case 400:
        return 'The request was rejected. Check the values and try again.';
      case 401:
        return 'Your session has ended. Sign in again.';
      case 403:
        return 'You do not have access to this resource.';
      case 404:
        return 'That record no longer exists.';
      case 409:
        return 'That record conflicts with one already saved.';
      case 500:
        return 'The server could not complete the request.';
      default:
        return 'The request failed.';
    }
  }

  @override
  String toString() => message;
}
