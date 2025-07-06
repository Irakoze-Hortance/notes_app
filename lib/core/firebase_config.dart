import 'package:flutter/foundation.dart';

/// Firebase Configuration Constants
class FirebaseConfig {
  // Collection Names
  static const String usersCollection = 'users';
  static const String notesCollection = 'notes';
  static const String userProfilesCollection = 'userProfiles';

  // Authentication Settings
  static const int passwordMinLength = 6;
  static const bool requireEmailVerification = false;
  static const Duration authTimeout = Duration(seconds: 30);

  // Firestore Settings
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const bool enableOfflinePersistence = true;
  static const Duration cacheTimeout = Duration(minutes: 5);

  // Storage Settings
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'application/pdf',
  ];

  // Error Messages
  static const Map<String, String> authErrorMessages = {
    'user-not-found': 'No account found with this email address.',
    'wrong-password': 'Incorrect password. Please try again.',
    'email-already-in-use': 'An account with this email already exists.',
    'weak-password': 'Password should be at least 6 characters long.',
    'invalid-email': 'Please enter a valid email address.',
    'network-request-failed': 'Network error. Please check your connection.',
    'too-many-requests': 'Too many failed attempts. Please try again later.',
    'user-disabled': 'This account has been disabled.',
    'operation-not-allowed': 'This operation is not allowed.',
    'invalid-credential': 'The provided credentials are invalid.',
  };

  static const Map<String, String> firestoreErrorMessages = {
    'permission-denied': 'You don\'t have permission to perform this action.',
    'unavailable': 'Service temporarily unavailable. Please try again.',
    'deadline-exceeded': 'Request timeout. Please try again.',
    'resource-exhausted': 'Too many requests. Please try again later.',
    'cancelled': 'Operation was cancelled.',
    'data-loss': 'Data loss occurred. Please try again.',
    'unknown': 'An unknown error occurred. Please try again.',
  };

  // Development Settings
  static const bool enableDebugMode = kDebugMode;
  static const bool enableAnalytics = false;
  static const bool enableCrashlytics = false;
  static const bool enablePerformanceMonitoring = false;

  // UI Settings
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const int maxNoteLength = 5000;
  static const int maxNotePreviewLength = 100;

  // Validation Rules
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= passwordMinLength;
  }

  static bool isValidNoteText(String text) {
    return text.trim().isNotEmpty && text.length <= maxNoteLength;
  }

  // Helper Methods
  static String getErrorMessage(String errorCode, {bool isAuth = true}) {
    final messages = isAuth ? authErrorMessages : firestoreErrorMessages;
    return messages[errorCode] ?? 'An unexpected error occurred.';
  }

  static String truncateText(String text, {int maxLength = maxNotePreviewLength}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
