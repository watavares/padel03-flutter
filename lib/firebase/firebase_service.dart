import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_config.dart';
import '../config/app_config.dart';

class FirebaseService {
  static FirebaseApp? _app;
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;
  static FirebaseAnalytics? _analytics;

  static Future<void> initializeFirebase() async {
    try {
      _app = await Firebase.initializeApp(
        options: FirebaseConfig.currentPlatform,
      );

      _auth = FirebaseAuth.instanceFor(app: _app!);
      _firestore = FirebaseFirestore.instanceFor(app: _app!);
      _storage = FirebaseStorage.instanceFor(app: _app!);

      if (AppConfig.enableAnalytics) {
        _analytics = FirebaseAnalytics.instanceFor(app: _app!);
        // Enable analytics collection
        await _analytics!.setAnalyticsCollectionEnabled(true);
      }

      // Configure Firestore settings
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      print(
        'Firebase initialized for ${AppConfig.environment.name} environment',
      );
    } catch (e) {
      print('Error initializing Firebase: $e');
      rethrow;
    }
  }

  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception(
        'Firebase not initialized. Call initializeFirebase() first.',
      );
    }
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception(
        'Firebase not initialized. Call initializeFirebase() first.',
      );
    }
    return _firestore!;
  }

  static FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception(
        'Firebase not initialized. Call initializeFirebase() first.',
      );
    }
    return _storage!;
  }

  static FirebaseAnalytics? get analytics {
    return _analytics;
  }

  static String get currentEnvironment => AppConfig.environment.name;

  static bool get isInitialized => _app != null;
}
