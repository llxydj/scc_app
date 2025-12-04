class AppException implements Exception {
  final String message;
  AppException(this.message);
  
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String message = 'Network error occurred']) : super(message);
}

class DatabaseException extends AppException {
  DatabaseException([String message = 'Database error occurred']) : super(message);
}

class AuthenticationException extends AppException {
  AuthenticationException([String message = 'Authentication failed']) : super(message);
}

class ValidationException extends AppException {
  ValidationException([String message = 'Validation failed']) : super(message);
}

class FileException extends AppException {
  FileException([String message = 'File operation failed']) : super(message);
}

class SyncException extends AppException {
  SyncException([String message = 'Sync failed']) : super(message);
}

