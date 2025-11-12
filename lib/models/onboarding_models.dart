import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_models.freezed.dart';
part 'onboarding_models.g.dart';

/// Onboarding step identifier
enum OnboardingStep {
  location,
  quiz,
  availability,
  avatar,
  done,
}

extension OnboardingStepExtension on OnboardingStep {
  String get title {
    switch (this) {
      case OnboardingStep.location:
        return 'Your Location';
      case OnboardingStep.quiz:
        return 'Skill Level';
      case OnboardingStep.availability:
        return 'Availability';
      case OnboardingStep.avatar:
        return 'Profile Photo';
      case OnboardingStep.done:
        return 'Welcome!';
    }
  }

  String get subtitle {
    switch (this) {
      case OnboardingStep.location:
        return 'Find nearby courts and players';
      case OnboardingStep.quiz:
        return 'Quick skill assessment for fair matches';
      case OnboardingStep.availability:
        return 'When do you prefer to play?';
      case OnboardingStep.avatar:
        return 'Add a profile photo';
      case OnboardingStep.done:
        return 'You\'re all set!';
    }
  }

  int get stepNumber {
    switch (this) {
      case OnboardingStep.location:
        return 1;
      case OnboardingStep.quiz:
        return 2;
      case OnboardingStep.availability:
        return 3;
      case OnboardingStep.avatar:
        return 4;
      case OnboardingStep.done:
        return 5;
    }
  }

  bool get isSkippable {
    switch (this) {
      case OnboardingStep.location:
        return false; // Location is required
      case OnboardingStep.quiz:
        return true; // Quiz can be skipped
      case OnboardingStep.availability:
        return true; // Availability is optional
      case OnboardingStep.avatar:
        return true; // Avatar is optional
      case OnboardingStep.done:
        return false; // Final step
    }
  }
}

/// Quiz question model
@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    required String question,
    required String description,
    required List<QuizOption> options,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}

/// Quiz option model
@freezed
class QuizOption with _$QuizOption {
  const factory QuizOption({
    required String text,
    required int score, // 1-5 scale
  }) = _QuizOption;

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      _$QuizOptionFromJson(json);
}

/// Quiz response model
@freezed
class QuizResponse with _$QuizResponse {
  const factory QuizResponse({
    required String questionId,
    required int selectedScore,
    required String selectedText,
  }) = _QuizResponse;

  factory QuizResponse.fromJson(Map<String, dynamic> json) =>
      _$QuizResponseFromJson(json);
}

/// Complete quiz result
@freezed
class QuizResult with _$QuizResult {
  const QuizResult._();
  
  const factory QuizResult({
    required List<QuizResponse> responses,
    required int totalScore,
    required String computedLevel,
    required DateTime completedAt,
  }) = _QuizResult;

  factory QuizResult.fromJson(Map<String, dynamic> json) =>
      _$QuizResultFromJson(json);

  /// Get percentage score (0-100)
  double get percentageScore => (totalScore / 25.0) * 100;

  /// Get level description
  String get levelDescription {
    switch (computedLevel) {
      case 'beginner':
        return 'You\'re just getting started! Focus on basic shots and court positioning.';
      case 'intermediate':
        return 'You have solid fundamentals! Work on strategy and advanced techniques.';
      case 'advanced':
        return 'Excellent skills! You\'re ready for competitive matches.';
      default:
        return 'Level assessment complete.';
    }
  }
}

/// Onboarding state management
@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();
  
  const factory OnboardingState({
    @Default(0) int currentStep,
    @Default(false) bool isLoading,
    @Default(false) bool isCompleted,
    @Default(false) bool isSkipped,
    Map<String, dynamic>? locationData,
    Map<String, dynamic>? quizData,
    Map<String, dynamic>? availabilityData,
    Map<String, dynamic>? profileData,
  }) = _OnboardingState;

  factory OnboardingState.fromJson(Map<String, dynamic> json) =>
      _$OnboardingStateFromJson(json);

  /// Check if current step is complete
  bool get isCurrentStepComplete {
    switch (currentStep) {
      case 0: // OnboardingStep.location
        return locationData != null;
      case 1: // OnboardingStep.quiz
        return quizData != null; // Complete only if quiz is taken
      case 2: // OnboardingStep.availability
        return true; // Always considered complete (optional)
      case 3: // OnboardingStep.avatar
        return true; // Always considered complete (optional)
      case 4: // OnboardingStep.done
        return true;
      default:
        return false;
    }
  }

  /// Check if user can proceed to next step
  bool get canProceed {
    switch (currentStep) {
      case 0: // OnboardingStep.location
        return locationData != null;
      case 1: // OnboardingStep.quiz
        return true; // Can proceed even if skipped
      case 2: // OnboardingStep.availability
        return true; // Optional step
      case 3: // OnboardingStep.avatar
        return true; // Optional step
      case 4: // OnboardingStep.done
        return true;
      default:
        return false;
    }
  }

  /// Get next step
  OnboardingStep? get nextStep {
    switch (currentStep) {
      case 0: // OnboardingStep.location
        return OnboardingStep.quiz;
      case 1: // OnboardingStep.quiz
        return OnboardingStep.availability;
      case 2: // OnboardingStep.availability
        return OnboardingStep.avatar;
      case 3: // OnboardingStep.avatar
        return OnboardingStep.done;
      case 4: // OnboardingStep.done
        return null;
      default:
        return null;
    }
  }

  /// Get previous step
  OnboardingStep? get previousStep {
    switch (currentStep) {
      case 0: // OnboardingStep.location
        return null;
      case 1: // OnboardingStep.quiz
        return OnboardingStep.location;
      case 2: // OnboardingStep.availability
        return OnboardingStep.quiz;
      case 3: // OnboardingStep.avatar
        return OnboardingStep.availability;
      case 4: // OnboardingStep.done
        return OnboardingStep.avatar;
      default:
        return null;
    }
  }

  /// Calculate progress percentage (0.0 to 1.0)
  double get progress {
    switch (currentStep) {
      case 0: // OnboardingStep.location
        return 0.2;
      case 1: // OnboardingStep.quiz
        return 0.4;
      case 2: // OnboardingStep.availability
        return 0.6;
      case 3: // OnboardingStep.avatar
        return 0.8;
      case 4: // OnboardingStep.done
        return 1.0;
      default:
        return 0.0;
    }
  }

  /// Total number of steps
  static const int totalSteps = 4; // Excluding done step
}