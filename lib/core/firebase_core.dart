import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_config.dart';
import '../firebase_options.dart';

/// Firebase Core Service
/// Manages Firebase initialization and provides service instances
class FirebaseCore {
  static final FirebaseCore _instance = FirebaseCore._internal();
  factory FirebaseCore() => _instance;
  FirebaseCore._internal();

  // Service instances
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;

  // State
  bool _initialized = false;
  User? _currentUser;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  bool get initialized => _initialized;
  User? get currentUser => _currentUser;

  /// Initialize Firebase
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize services
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;

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
      try {
        await _firestore.enablePersistence();
      } catch (e) {
        if (kDebugMode) {
          print('Firestore persistence failed: $e');
        }
      }
    }

    // Configure Firestore settings
    _firestore.settings = const Settings(
      persistenceEnabled: FirebaseConfig.enableOfflinePersistence,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
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
}
