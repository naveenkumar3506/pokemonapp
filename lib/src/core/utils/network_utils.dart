import 'package:dio/dio.dart';
import '../error/app_exception.dart';

/// Utility class for network operations
class NetworkUtils {
  NetworkUtils._();

  /// Converts DioException to AppException
  static AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          'TIMEOUT',
        );
      case DioExceptionType.badResponse:
        return NetworkException(
          'Server error: ${error.response?.statusCode}',
          'SERVER_ERROR',
        );
      case DioExceptionType.cancel:
        return NetworkException('Request cancelled', 'CANCELLED');
      case DioExceptionType.unknown:
        return NetworkException(
          'Network error: ${error.message ?? 'Unknown error'}',
          'UNKNOWN',
        );
      case DioExceptionType.badCertificate:
        return NetworkException('Bad certificate', 'BAD_CERTIFICATE');
      case DioExceptionType.connectionError:
        return NetworkException(
          'Connection error. Please check your internet connection.',
          'CONNECTION_ERROR',
        );
    }
  }
}


