enum Environment { dev, staging, prod }

class AppConfig {
  static Environment _environment = Environment.dev;

  static Environment get environment => _environment;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static String get appName {
    switch (_environment) {
      case Environment.dev:
        return 'Padel03 Dev';
      case Environment.staging:
        return 'Padel03 Staging';
      case Environment.prod:
        return 'Padel03';
    }
  }

  static String get bundleId {
    switch (_environment) {
      case Environment.dev:
        return 'com.example.flutter_padel03.dev';
      case Environment.staging:
        return 'com.example.flutter_padel03.staging';
      case Environment.prod:
        return 'com.example.flutter_padel03';
    }
  }

  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://api-dev.padel03.com';
      case Environment.staging:
        return 'https://api-staging.padel03.com';
      case Environment.prod:
        return 'https://api.padel03.com';
    }
  }

  static bool get enableAnalytics {
    switch (_environment) {
      case Environment.dev:
        return false;
      case Environment.staging:
        return true;
      case Environment.prod:
        return true;
    }
  }

  static bool get enableCrashlytics {
    switch (_environment) {
      case Environment.dev:
        return false;
      case Environment.staging:
        return true;
      case Environment.prod:
        return true;
    }
  }
}
