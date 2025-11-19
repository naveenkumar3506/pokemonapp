/// Base exception class for application errors
abstract class AppException implements Exception {
  const AppException(this.message, [this.code]);
  
  final String message;
  final String? code;
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Image processing exceptions
class ImageProcessingException extends AppException {
  const ImageProcessingException(super.message, [super.code]);
}

/// Unknown exceptions
class UnknownException extends AppException {
  const UnknownException(super.message, [super.code]);
}


