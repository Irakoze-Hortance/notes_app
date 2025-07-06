import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';

/// Custom Firebase Exception Handler
class FirebaseExceptionHandler {
  /// Handle Firebase Auth exceptions
  static String handleAuthException(FirebaseAuthException exception) {
    return FirebaseConfig.getErrorMessage(exception.code, isAuth: true);
  }

  /// Handle Firestore exceptions
  static String handleFirestoreException(FirebaseException exception) {
    return FirebaseConfig.getErrorMessage(exception.code, isAuth: false);
  }

  /// Handle generic exceptions
  static String handleGenericException(Exception exception) {
    if (exception is FirebaseAuthException) {
      return handleAuthException(exception);
    } else if (exception is FirebaseException) {
      return handleFirestoreException(exception);
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Custom Firebase Exceptions
class FirebaseAppException implements Exception {
  final String message;
  final String code;
  final dynamic originalException;

  const FirebaseAppException({
    required this.message,
    required this.code,
    this.originalException,
  });

  @override
  String toString() => 'FirebaseAppException: $message';
}

class AuthenticationException extends FirebaseAppException {
  const AuthenticationException({
    required super.message,
    required super.code,
    super.originalException,
  });
}

class DatabaseException extends FirebaseAppException {
  const DatabaseException({
    required super.message,
    required super.code,
    super.originalException,
  });
}

class StorageException extends FirebaseAppException {
  const StorageException({
    required super.message,
    required super.code,
    super.originalException,
  });
}

class NetworkException extends FirebaseAppException {
  const NetworkException({
    required super.message,
    required super.code,
    super.originalException,
  });
}

class ValidationException extends FirebaseAppException {
  const ValidationException({
    required super.message,
    required super.code,
    super.originalException,
  });
}