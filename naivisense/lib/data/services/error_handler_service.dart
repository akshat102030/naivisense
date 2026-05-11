import 'package:dio/dio.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final bool retryable;

  const AppException(this.message, {this.code, this.retryable = false});

  @override
  String toString() => message;
}

class ErrorHandlerService {
  ErrorHandlerService._();

  static AppException handle(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final err = data['error'] as Map<String, dynamic>?;
        if (err != null) {
          return AppException(
            err['message'] as String? ?? 'An error occurred',
            code:      err['code'] as String?,
            retryable: err['retryable'] as bool? ?? false,
          );
        }
      }
      return switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout    => const AppException(
            'Connection timed out. Please try again.',
            retryable: true,
          ),
        DioExceptionType.connectionError => const AppException(
            'No internet connection.',
            retryable: true,
          ),
        _ => AppException(
            error.message ?? 'Network error',
            retryable: false,
          ),
      };
    }

    return AppException(error.toString());
  }
}
