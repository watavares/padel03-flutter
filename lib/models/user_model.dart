import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// User skill levels
enum SkillLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

extension SkillLevelExtension on SkillLevel {
  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case SkillLevel.beginner:
        return 'New to padel or less than 6 months playing';
      case SkillLevel.intermediate:
        return '6 months to 2 years, comfortable with basic shots';
      case SkillLevel.advanced:
        return '2+ years, excellent technique and strategy';
    }
  }
}

/// Location data model
@freezed
class UserLocation with _$UserLocation {
  const factory UserLocation({
    required double lat,
    required double lng,
    required String city,
    required String country,
    @Default('auto') String source, // 'auto' or 'manual'
  }) = _UserLocation;

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);
}

/// Skill assessment data
@freezed
class UserSkill with _$UserSkill {
  const UserSkill._();
  
  const factory UserSkill({
    int? quizScore, // 5-25 range
    SkillLevel? computedLevel, // Derived from quiz score
    SkillLevel? userOverrideLevel, // Manual override
  }) = _UserSkill;

  factory UserSkill.fromJson(Map<String, dynamic> json) =>
      _$UserSkillFromJson(json);

  /// Get the effective skill level (override takes precedence)
  SkillLevel? get effectiveLevel => userOverrideLevel ?? computedLevel;

  /// Check if skill assessment is complete
  bool get isComplete => quizScore != null && computedLevel != null;
}

/// Onboarding progress tracking
@freezed
class OnboardingProgress with _$OnboardingProgress {
  const OnboardingProgress._();
  
  const factory OnboardingProgress({
    @Default(false) bool completed,
    @Default(false) bool quizCompleted,
    @Default(false) bool availabilityProvided,
  }) = _OnboardingProgress;

  factory OnboardingProgress.fromJson(Map<String, dynamic> json) =>
      _$OnboardingProgressFromJson(json);
      
  /// Check if onboarding is complete
  bool get isCompleted => completed;
}

/// Time availability window
@freezed
class TimeWindow with _$TimeWindow {
  const factory TimeWindow({
    required String startTime, // HH:mm format
    required String endTime, // HH:mm format
  }) = _TimeWindow;

  factory TimeWindow.fromJson(Map<String, dynamic> json) =>
      _$TimeWindowFromJson(json);
}

/// User availability for each day
@freezed
class DayAvailability with _$DayAvailability {
  const factory DayAvailability({
    @Default(false) bool isAvailable,
    @Default([]) List<TimeWindow> timeWindows,
  }) = _DayAvailability;

  factory DayAvailability.fromJson(Map<String, dynamic> json) =>
      _$DayAvailabilityFromJson(json);
}

/// Weekly availability schedule
@freezed
class WeeklyAvailability with _$WeeklyAvailability {
  const factory WeeklyAvailability({
    @Default(DayAvailability()) DayAvailability monday,
    @Default(DayAvailability()) DayAvailability tuesday,
    @Default(DayAvailability()) DayAvailability wednesday,
    @Default(DayAvailability()) DayAvailability thursday,
    @Default(DayAvailability()) DayAvailability friday,
    @Default(DayAvailability()) DayAvailability saturday,
    @Default(DayAvailability()) DayAvailability sunday,
  }) = _WeeklyAvailability;

  factory WeeklyAvailability.fromJson(Map<String, dynamic> json) =>
      _$WeeklyAvailabilityFromJson(json);
}

extension WeeklyAvailabilityExtension on WeeklyAvailability {
  /// Get availability for a specific day (0 = Monday, 6 = Sunday)
  DayAvailability getDay(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return monday;
      case 1:
        return tuesday;
      case 2:
        return wednesday;
      case 3:
        return thursday;
      case 4:
        return friday;
      case 5:
        return saturday;
      case 6:
        return sunday;
      default:
        throw ArgumentError('Invalid day index: $dayIndex');
    }
  }
}

/// Main user model
@freezed
class UserModel with _$UserModel {
  const UserModel._();
  
  const factory UserModel({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    UserLocation? location,
    @Default(UserSkill()) UserSkill skill,
    @Default(OnboardingProgress()) OnboardingProgress onboarding,
    WeeklyAvailability? availability,
    double? reliabilityPct, // 0-100 percentage
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Create a new user with default values
  factory UserModel.newUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Check if user can join lobbies (needs completed quiz)
  bool get canJoinLobbies => skill.effectiveLevel != null;

  /// Get display name or fallback
  String get displayNameOrEmail => displayName ?? email.split('@').first;

  /// Check if onboarding is fully complete
  bool get hasCompletedOnboarding => onboarding.isCompleted;

  /// Update timestamp helper
  UserModel withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }
}

/// Timestamp converter for Firestore
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.tryParse(json);
    }
    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    return object != null ? Timestamp.fromDate(object) : null;
  }
}