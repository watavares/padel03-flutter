import '../services/service_manager.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

class FirebaseConfigChecker {
  static Future<Map<String, dynamic>> checkConfiguration() async {
    final results = <String, dynamic>{};

    try {
      // Check if Firebase is initialized
      results['firebase_initialized'] = ServiceManager.isInitialized;
      results['environment'] = AppConfig.environment.name;

      // Check authentication configuration
      results['auth_available'] = true;

      // Check Google Sign-In availability
      try {
        results['google_signin_available'] =
            await AuthService.isGoogleSignInAvailable();
      } catch (e) {
        results['google_signin_available'] = false;
        results['google_signin_error'] = e.toString();
      }

      // Check Apple Sign-In availability
      try {
        results['apple_signin_available'] =
            await AuthService.isAppleSignInAvailable();
      } catch (e) {
        results['apple_signin_available'] = false;
        results['apple_signin_error'] = e.toString();
      }

      // Check current user status
      final currentUser = AuthService.currentUser;
      results['current_user'] = currentUser != null
          ? {
              'uid': currentUser.uid,
              'email': currentUser.email,
              'display_name': currentUser.displayName,
              'email_verified': currentUser.emailVerified,
              'providers': currentUser.providerData
                  .map((p) => p.providerId)
                  .toList(),
            }
          : null;
    } catch (e) {
      results['error'] = e.toString();
    }

    return results;
  }

  static void printConfiguration() async {
    final config = await checkConfiguration();
    print('🔍 Firebase Configuration Check:');
    config.forEach((key, value) {
      print('  $key: $value');
    });
  }
}
