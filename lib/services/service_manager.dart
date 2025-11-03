import '../firebase/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/analytics_service.dart';
import '../config/app_config.dart';

class ServiceManager {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Initialize all Firebase services
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize Firebase
      await FirebaseService.initializeFirebase();

      // Set up Analytics user properties
      if (AppConfig.enableAnalytics) {
        await AnalyticsService.setUserProperty(
          name: 'environment',
          value: AppConfig.environment.name,
        );

        await AnalyticsService.setUserProperty(
          name: 'app_version',
          value: '1.0.0', // You can get this from package_info_plus
        );
      }

      // Log app start
      await AnalyticsService.logEvent(
        name: 'app_start',
        parameters: {
          'environment': AppConfig.environment.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _initialized = true;
      print('🚀 ServiceManager: All services initialized successfully');
    } catch (e) {
      print('❌ ServiceManager: Failed to initialize services: $e');
      rethrow;
    }
  }

  /// Get service status for debugging
  static Map<String, dynamic> getServiceStatus() {
    return {
      'service_manager_initialized': _initialized,
      'firebase_initialized': FirebaseService.isInitialized,
      'current_environment': AppConfig.environment.name,
      'analytics_enabled': AppConfig.enableAnalytics,
      'crashlytics_enabled': AppConfig.enableCrashlytics,
      'current_user': AuthService.currentUser?.uid,
      'analytics_debug': AnalyticsService.getDebugInfo(),
      'firestore_environment': FirestoreService.currentEnvironment,
    };
  }

  /// Clean up services (call on app termination)
  static Future<void> dispose() async {
    try {
      // Log app end
      await AnalyticsService.logEvent(
        name: 'app_end',
        parameters: {
          'environment': AppConfig.environment.name,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _initialized = false;
      print('🛑 ServiceManager: Services disposed');
    } catch (e) {
      print('❌ ServiceManager: Error disposing services: $e');
    }
  }
}
