import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'firebase_config.dart';

/// Firebase Core Service
/// Manages Firebase initialization and provides service instances
class FirebaseCore {
  static final FirebaseCore _instance = FirebaseCore._internal();
  factory FirebaseCore() => _instance;
  FirebaseCore._internal();

  // Service instances
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseStorage _storage;
  late FirebaseAnalytics _analytics;
  late FirebaseCrashlytics _crashlytics;
  late FirebasePerformance _performance;

  // State
  bool _initialized = false;
  User? _currentUser;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  FirebasePerformance get performance => _performance;
  bool get initialized => _initialized;
  User? get currentUser => _currentUser;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: 'AIzaSyCv8_icsYiJJaurd-LeIVRzbcjPTsiot_I',
          appId: '1:950062104982:web:56f92fdf93edb7546a1db7',
          messagingSenderId: '950062104982',
          projectId: 'flutter-auth-ea6f6',
        ),
      );

      // Initialize services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _storage = FirebaseStorage.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;
      _performance = FirebasePerformance.instance;

      // Configure services
      await _configureServices();

      // Set up auth state listener
      _auth.authStateChanges().listen((User? user) {
        _currentUser = user;
      });

      _initialized = true;
      
      if (kDebugMode) {
        print('🔥 Firebase initialized successfully');
      }
    } catch (error) {
      if (kDebugMode) {
        print('❌ Firebase initialization failed: $error');
      }
      rethrow;
    }
  }

  /// Configure Firebase services
  Future<void> _configureServices() async {
    // Configure Firestore
    if (FirebaseConfig.enableOfflinePersistence) {
      await _firestore.enablePersistence();
    }

    // Configure Firestore settings
    _firestore.settings = const Settings(
      persistenceEnabled: FirebaseConfig.enableOfflinePersistence,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    // Configure Crashlytics
    if (FirebaseConfig.enableCrashlytics) {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
    }

    // Configure Analytics
    if (FirebaseConfig.enableAnalytics) {
      await _analytics.setAnalyticsCollectionEnabled(true);
    }

    // Configure Performance
    if (FirebaseConfig.enablePerformanceMonitoring) {
      await _performance.setPerformanceCollectionEnabled(true);
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _currentUser != null;
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUser?.uid;
  }

  /// Get current user email
  String? getCurrentUserEmail() {
    return _currentUser?.email;
  }

  /// Wait for authentication state
  Future<User?> waitForAuth() async {
    if (_currentUser != null) return _currentUser;
    
    return _auth.authStateChanges().first;
  }

  /// Log analytics event
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    if (!FirebaseConfig.enableAnalytics) return;
    
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Analytics event failed: $error');
      }
    }
  }

  /// Log error to Crashlytics
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    if (!FirebaseConfig.enableCrashlytics) return;
    
    try {
      await _crashlytics.recordError(error, stackTrace);
    } catch (e) {
      if (kDebugMode) {
        print('Crashlytics error logging failed: $e');
      }
    }
  }

  /// Create performance trace
  HttpMetric createHttpMetric(String url, HttpMethod method) {
    return _performance.newHttpMetric(url, method);
  }

  /// Create custom trace
  Trace createTrace(String name) {
    return _performance.newTrace(name);
  }

  /// Set user properties for analytics
  Future<void> setUserProperties(Map<String, String> properties) async {
    if (!FirebaseConfig.enableAnalytics) return;
    
    for (final entry in properties.entries) {
      await _analytics.setUserProperty(
        name: entry.key,
        value: entry.value,
      );
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String userId) async {
    if (!FirebaseConfig.enableAnalytics) return;
    
    await _analytics.setUserId(id: userId);
  }

  /// Reset analytics data
  Future<void> resetAnalyticsData() async {
    if (!FirebaseConfig.enableAnalytics) return;
    
    await _analytics.resetAnalyticsData();
  }
}
