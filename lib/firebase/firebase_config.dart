import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'firebase_options_dev.dart' as dev_options;
import 'firebase_options_staging.dart' as staging_options;
import 'firebase_options_prod.dart' as prod_options;

class FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    switch (AppConfig.environment) {
      case Environment.dev:
        return _getDevFirebaseOptions();
      case Environment.staging:
        return _getStagingFirebaseOptions();
      case Environment.prod:
        return _getProdFirebaseOptions();
    }
  }

  // Development Firebase Options
  static FirebaseOptions _getDevFirebaseOptions() {
    if (kIsWeb) {
      return dev_options.DefaultFirebaseOptions.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return dev_options.DefaultFirebaseOptions.android;
      case TargetPlatform.iOS:
        return dev_options.DefaultFirebaseOptions.ios;
      case TargetPlatform.macOS:
        return dev_options.DefaultFirebaseOptions.macos;
      case TargetPlatform.windows:
        return dev_options.DefaultFirebaseOptions.windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux platform not supported for Firebase');
      default:
        throw UnsupportedError('Platform not supported for Firebase');
    }
  }

  // Staging Firebase Options  
  static FirebaseOptions _getStagingFirebaseOptions() {
    if (kIsWeb) {
      return staging_options.DefaultFirebaseOptions.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return staging_options.DefaultFirebaseOptions.android;
      case TargetPlatform.iOS:
        return staging_options.DefaultFirebaseOptions.ios;
      case TargetPlatform.macOS:
        return staging_options.DefaultFirebaseOptions.macos;
      case TargetPlatform.windows:
        return staging_options.DefaultFirebaseOptions.windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux platform not supported for Firebase');
      default:
        throw UnsupportedError('Platform not supported for Firebase');
    }
  }

  // Production Firebase Options
  static FirebaseOptions _getProdFirebaseOptions() {
    if (kIsWeb) {
      return prod_options.DefaultFirebaseOptions.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return prod_options.DefaultFirebaseOptions.android;
      case TargetPlatform.iOS:
        return prod_options.DefaultFirebaseOptions.ios;
      case TargetPlatform.macOS:
        return prod_options.DefaultFirebaseOptions.macos;
      case TargetPlatform.windows:
        return prod_options.DefaultFirebaseOptions.windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux platform not supported for Firebase');
      default:
        throw UnsupportedError('Platform not supported for Firebase');
    }
  }
}