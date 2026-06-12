class TransportException implements Exception {
  final int statusCode;
  final String message;
  TransportException(this.statusCode, this.message);
  
  @override
  String toString() => '$runtimeType: $message (StatusCode: $statusCode)';
}

class AuthenticationException extends TransportException {
  AuthenticationException(String message) : super(401, message);
}

class ForbiddenException extends TransportException {
  ForbiddenException(String message) : super(403, message);
}

class RateLimitException extends TransportException {
  RateLimitException(String message) : super(429, message);
}

class ServerException extends TransportException {
  ServerException(String message) : super(500, message);
}

class RefreshFailedException extends TransportException {
  RefreshFailedException(String message) : super(401, message);
}

class NetworkException extends TransportException {
  NetworkException(String message) : super(0, message);
}

class TimeoutException extends TransportException {
  TimeoutException(String message) : super(408, message);
}
