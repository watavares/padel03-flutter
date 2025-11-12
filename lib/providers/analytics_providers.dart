import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

/// Analytics controller for tracking events
class AnalyticsController {
  // Auth Events
  Future<void> trackSignInAttempt(String method) async {
    await AnalyticsService.logEvent(
      name: 'sign_in_attempt',
      parameters: {'method': method},
    );
  }

  Future<void> trackSignInSuccess(String method, String userId) async {
    await AnalyticsService.logLogin(method: method);
    await AnalyticsService.setUserId(userId);
  }

  Future<void> trackSignInFailure(String method, String error) async {
    await AnalyticsService.logEvent(
      name: 'sign_in_failure',
      parameters: {
        'method': method,
        'error': error,
      },
    );
  }

  Future<void> trackRegisterAttempt(String method) async {
    await AnalyticsService.logEvent(
      name: 'register_attempt',
      parameters: {'method': method},
    );
  }

  Future<void> trackRegisterSuccess(String method, String userId) async {
    await AnalyticsService.logSignUp(method: method);
    await AnalyticsService.setUserId(userId);
  }

  Future<void> trackRegisterFailure(String method, String error) async {
    await AnalyticsService.logEvent(
      name: 'register_failure',
      parameters: {
        'method': method,
        'error': error,
      },
    );
  }

  // Onboarding Events
  Future<void> trackOnboardingStart() async {
    await AnalyticsService.logEvent(
      name: 'onboarding_start',
      parameters: {},
    );
  }

  Future<void> trackOnboardingStepComplete(String step, int stepNumber) async {
    await AnalyticsService.logEvent(
      name: 'onboarding_step_complete',
      parameters: {
        'step': step,
        'step_number': stepNumber,
      },
    );
  }

  Future<void> trackOnboardingComplete(int totalSteps, String finalSkillLevel) async {
    await AnalyticsService.logEvent(
      name: 'onboarding_complete',
      parameters: {
        'total_steps': totalSteps,
        'final_skill_level': finalSkillLevel,
      },
    );
  }

  Future<void> trackOnboardingSkipped(String step, int stepNumber) async {
    await AnalyticsService.logEvent(
      name: 'onboarding_skipped',
      parameters: {
        'step': step,
        'step_number': stepNumber,
      },
    );
  }

  // Quiz Events
  Future<void> trackQuizStart() async {
    await AnalyticsService.logEvent(
      name: 'quiz_start',
      parameters: {},
    );
  }

  Future<void> trackQuizQuestionAnswered(int questionNumber, String answer, int points) async {
    await AnalyticsService.logEvent(
      name: 'quiz_question_answered',
      parameters: {
        'question_number': questionNumber,
        'answer': answer,
        'points': points,
      },
    );
  }

  Future<void> trackQuizComplete(int totalScore, String skillLevel) async {
    await AnalyticsService.logEvent(
      name: 'quiz_complete',
      parameters: {
        'total_score': totalScore,
        'skill_level': skillLevel,
      },
    );
  }

  // App Navigation Events
  Future<void> trackScreenView(String screenName) async {
    await AnalyticsService.logScreenView(
      screenName: screenName,
    );
  }

  Future<void> trackButtonPress(String buttonName, String screenName) async {
    await AnalyticsService.logEvent(
      name: 'button_press',
      parameters: {
        'button_name': buttonName,
        'screen_name': screenName,
      },
    );
  }

  // Game/Lobby Events
  Future<void> trackLobbyView() async {
    await AnalyticsService.logEvent(
      name: 'lobby_view',
      parameters: {},
    );
  }

  Future<void> trackLobbyJoinAttempt(String lobbyId, String skillLevel) async {
    await AnalyticsService.logEvent(
      name: 'lobby_join_attempt',
      parameters: {
        'lobby_id': lobbyId,
        'user_skill_level': skillLevel,
      },
    );
  }

  Future<void> trackLobbyCreateAttempt() async {
    await AnalyticsService.logEvent(
      name: 'lobby_create_attempt',
      parameters: {},
    );
  }

  // Assessment Events
  Future<void> trackQuickAssessmentStart() async {
    await AnalyticsService.logEvent(
      name: 'quick_assessment_start',
      parameters: {},
    );
  }

  Future<void> trackQuickAssessmentComplete(int score, String newSkillLevel, String previousSkillLevel) async {
    await AnalyticsService.logEvent(
      name: 'quick_assessment_complete',
      parameters: {
        'score': score,
        'new_skill_level': newSkillLevel,
        'previous_skill_level': previousSkillLevel,
      },
    );
  }

  // Error Events
  Future<void> trackError(String errorType, String errorMessage, String? context) async {
    await AnalyticsService.logEvent(
      name: 'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'context': context ?? 'unknown',
      },
    );
  }

  // User Behavior Events
  Future<void> trackFeatureUsage(String featureName, Map<String, dynamic>? parameters) async {
    await AnalyticsService.logEvent(
      name: 'feature_usage',
      parameters: {
        'feature_name': featureName,
        ...?parameters,
      },
    );
  }

  Future<void> trackUserRetention(int daysSinceInstall) async {
    await AnalyticsService.logEvent(
      name: 'user_retention',
      parameters: {
        'days_since_install': daysSinceInstall,
      },
    );
  }

  // Set user properties
  Future<void> setUserProperties({
    required String userId,
    String? skillLevel,
    String? city,
    String? country,
    bool? hasCompletedOnboarding,
  }) async {
    await AnalyticsService.setUserId(userId);
    
    if (skillLevel != null) {
      await AnalyticsService.setUserProperty(
        name: 'skill_level',
        value: skillLevel,
      );
    }
    
    if (city != null) {
      await AnalyticsService.setUserProperty(
        name: 'city',
        value: city,
      );
    }
    
    if (country != null) {
      await AnalyticsService.setUserProperty(
        name: 'country',
        value: country,
      );
    }
    
    if (hasCompletedOnboarding != null) {
      await AnalyticsService.setUserProperty(
        name: 'completed_onboarding',
        value: hasCompletedOnboarding.toString(),
      );
    }
  }
}

/// Analytics controller provider
final analyticsControllerProvider = Provider<AnalyticsController>((ref) {
  return AnalyticsController();
});