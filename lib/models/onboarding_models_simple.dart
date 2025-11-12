import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_models_simple.freezed.dart';
part 'onboarding_models_simple.g.dart';

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
        return 'Set your location to find nearby courts';
      case OnboardingStep.quiz:
        return 'Take a quick quiz to determine your level';
      case OnboardingStep.availability:
        return 'When do you like to play?';
      case OnboardingStep.avatar:
        return 'Add a profile photo';
      case OnboardingStep.done:
        return 'You\'re ready to play!';
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
        return false; // Required
      case OnboardingStep.quiz:
        return true; // Can skip during onboarding
      case OnboardingStep.availability:
        return true; // Optional
      case OnboardingStep.avatar:
        return true; // Optional
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
    required List<QuizOption> options,
    required String category,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}

/// Quiz option model
@freezed
class QuizOption with _$QuizOption {
  const factory QuizOption({
    required String text,
    required String description,
    required int score,
  }) = _QuizOption;

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      _$QuizOptionFromJson(json);
}

/// Quiz response model
@freezed
class QuizResponse with _$QuizResponse {
  const factory QuizResponse({
    required String questionId,
    required int selectedOptionIndex,
    required int selectedScore,
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
}