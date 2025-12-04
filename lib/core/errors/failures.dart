abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure([String message = 'Network error occurred']) : super(message);
}

class DatabaseFailure extends Failure {
  DatabaseFailure([String message = 'Database error occurred']) : super(message);
}

class AuthenticationFailure extends Failure {
  AuthenticationFailure([String message = 'Authentication failed']) : super(message);
}

class ValidationFailure extends Failure {
  ValidationFailure([String message = 'Validation failed']) : super(message);
}

class FileFailure extends Failure {
  FileFailure([String message = 'File operation failed']) : super(message);
}

class SyncFailure extends Failure {
  SyncFailure([String message = 'Sync failed']) : super(message);
}

