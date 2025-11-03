import 'package:firebase_analytics/firebase_analytics.dart';
import '../firebase/firebase_service.dart';
import '../config/app_config.dart';

class AnalyticsService {
  static FirebaseAnalytics? get _analytics => FirebaseService.analytics;

  // Check if analytics is enabled
  static bool get isEnabled => _analytics != null && AppConfig.enableAnalytics;

  // Set user properties
  static Future<void> setUserId(String? userId) async {
    if (!isEnabled) return;

    try {
      await _analytics!.setUserId(id: userId);
    } catch (e) {
      print('Analytics setUserId error: $e');
    }
  }

  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
    } catch (e) {
      print('Analytics setUserProperty error: $e');
    }
  }

  // Screen tracking
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
    Map<String, Object>? parameters,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
        parameters: parameters,
      );
    } catch (e) {
      print('Analytics logScreenView error: $e');
    }
  }

  // Authentication events
  static Future<void> logLogin({String? method}) async {
    if (!isEnabled) return;

    try {
      await _analytics!.logLogin(loginMethod: method);
    } catch (e) {
      print('Analytics logLogin error: $e');
    }
  }

  static Future<void> logSignUp({String? method}) async {
    if (!isEnabled) return;

    try {
      await _analytics!.logSignUp(signUpMethod: method ?? 'unknown');
    } catch (e) {
      print('Analytics logSignUp error: $e');
    }
  }

  // Custom events
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!isEnabled) return;

    try {
      await _analytics!.logEvent(name: name, parameters: parameters);
    } catch (e) {
      print('Analytics logEvent error: $e');
    }
  }

  // Padel-specific events
  static Future<void> logCourtBooking({
    required String courtId,
    required String courtName,
    required DateTime bookingDate,
    required double price,
  }) async {
    await logEvent(
      name: 'court_booking',
      parameters: {
        'court_id': courtId,
        'court_name': courtName,
        'booking_date': bookingDate.toIso8601String(),
        'price': price,
        'currency': 'EUR',
        'environment': AppConfig.environment.name,
      },
    );
  }

  static Future<void> logMatchCreated({
    required String matchId,
    required String matchType,
    required int playersCount,
  }) async {
    await logEvent(
      name: 'match_created',
      parameters: {
        'match_id': matchId,
        'match_type': matchType,
        'players_count': playersCount,
        'environment': AppConfig.environment.name,
      },
    );
  }

  static Future<void> logMatchCompleted({
    required String matchId,
    required String winnerTeam,
    required int duration,
  }) async {
    await logEvent(
      name: 'match_completed',
      parameters: {
        'match_id': matchId,
        'winner_team': winnerTeam,
        'duration_minutes': duration,
        'environment': AppConfig.environment.name,
      },
    );
  }

  static Future<void> logTournamentJoined({
    required String tournamentId,
    required String tournamentName,
    required double entryFee,
  }) async {
    await logEvent(
      name: 'tournament_joined',
      parameters: {
        'tournament_id': tournamentId,
        'tournament_name': tournamentName,
        'entry_fee': entryFee,
        'currency': 'EUR',
        'environment': AppConfig.environment.name,
      },
    );
  }

  static Future<void> logUserSearch({
    required String searchTerm,
    required String searchType,
    int? resultsCount,
  }) async {
    await logEvent(
      name: 'search',
      parameters: {
        'search_term': searchTerm,
        'search_type': searchType,
        if (resultsCount != null) 'results_count': resultsCount,
        'environment': AppConfig.environment.name,
      },
    );
  }

  static Future<void> logAppRating({
    required int rating,
    String? feedback,
  }) async {
    await logEvent(
      name: 'app_rating',
      parameters: {
        'rating': rating,
        'has_feedback': feedback != null,
        'environment': AppConfig.environment.name,
      },
    );
  }

  // Error tracking
  static Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screen,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (screen != null) 'screen': screen,
        'environment': AppConfig.environment.name,
      },
    );
  }

  // Performance tracking
  static Future<void> logPerformance({
    required String action,
    required int durationMs,
    bool? success,
  }) async {
    await logEvent(
      name: 'performance',
      parameters: {
        'action': action,
        'duration_ms': durationMs,
        if (success != null) 'success': success,
        'environment': AppConfig.environment.name,
      },
    );
  }

  // Debug info
  static Map<String, dynamic> getDebugInfo() {
    return {
      'analytics_enabled': isEnabled,
      'config_analytics': AppConfig.enableAnalytics,
      'analytics_instance': _analytics != null,
      'environment': AppConfig.environment.name,
    };
  }
}
