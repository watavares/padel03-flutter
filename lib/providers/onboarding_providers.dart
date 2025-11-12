import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/location_service.dart';
import 'auth_providers.dart';
import 'analytics_providers.dart';

/// Onboarding state for managing the flow
class OnboardingState {
  final int currentStep;
  final bool isLoading;
  final bool isCompleted;
  final bool isSkipped;
  final String? error;
  final Map<String, dynamic>? locationData;
  final Map<String, dynamic>? quizData;
  final Map<String, dynamic>? availabilityData;
  final Map<String, dynamic>? profileData;

  const OnboardingState({
    this.currentStep = 0,
    this.isLoading = false,
    this.isCompleted = false,
    this.isSkipped = false,
    this.error,
    this.locationData,
    this.quizData,
    this.availabilityData,
    this.profileData,
  });

  OnboardingState copyWith({
    int? currentStep,
    bool? isLoading,
    bool? isCompleted,
    bool? isSkipped,
    String? error,
    Map<String, dynamic>? locationData,
    Map<String, dynamic>? quizData,
    Map<String, dynamic>? availabilityData,
    Map<String, dynamic>? profileData,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      error: error ?? this.error,
      locationData: locationData ?? this.locationData,
      quizData: quizData ?? this.quizData,
      availabilityData: availabilityData ?? this.availabilityData,
      profileData: profileData ?? this.profileData,
    );
  }

  bool get canProceedFromCurrentStep {
    switch (currentStep) {
      case 0: // Location
        return locationData != null;
      case 1: // Quiz (skippable)
        return true;
      case 2: // Availability (optional)
        return true;
      case 3: // Profile
        return profileData != null;
      case 4: // Done
        return true;
      default:
        return false;
    }
  }
}

/// Onboarding controller provider
final onboardingControllerProvider = StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController(ref);
});

/// Onboarding controller
class OnboardingController extends StateNotifier<OnboardingState> {
  final Ref ref;

  OnboardingController(this.ref) : super(const OnboardingState());

  /// Move to next step
  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Update location data
  void updateLocationData(Map<String, dynamic> data) {
    state = state.copyWith(locationData: data);
  }

  /// Update quiz data
  void updateQuizData(Map<String, dynamic> data) {
    state = state.copyWith(quizData: data);
  }

  /// Update availability data
  void updateAvailabilityData(Map<String, dynamic> data) {
    state = state.copyWith(availabilityData: data);
  }

  /// Update profile data
  void updateProfileData(Map<String, dynamic> data) {
    state = state.copyWith(profileData: data);
  }

  /// Skip onboarding
  Future<void> skipOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = ref.read(currentFirebaseUserProvider);
      if (user != null) {
        // Mark onboarding as skipped but not completed
        await UserService.updateUserFields(user.uid, {
          'onboarding.completed': false,
          'updatedAt': DateTime.now(),
        });
      }
      
      state = state.copyWith(
        isLoading: false,
        isSkipped: true,
        currentStep: 4, // Jump to done
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = ref.read(currentFirebaseUserProvider);
      if (user == null) throw Exception('No authenticated user');

      // Prepare update data
      final Map<String, dynamic> updateData = {
        'onboarding.completed': true,
        'updatedAt': DateTime.now(),
      };

      // Add location data if provided
      if (state.locationData != null) {
        final locationData = state.locationData!;
        if (locationData['isCurrentLocation'] == true) {
          // Get current location
          try {
            final userLocation = await LocationService.getUserLocation();
            updateData['location'] = userLocation.toJson();
          } catch (e) {
            // Fallback to manual location
            updateData['location'] = {
              'lat': 0.0,
              'lng': 0.0,
              'city': locationData['location'] ?? 'Unknown City',
              'country': 'Unknown Country',
              'source': 'manual',
            };
          }
        } else {
          // Manual location
          final parts = (locationData['location'] as String? ?? '').split(', ');
          updateData['location'] = {
            'lat': 0.0,
            'lng': 0.0,
            'city': parts.isNotEmpty ? parts[0] : 'Unknown City',
            'country': parts.length > 1 ? parts[1] : 'Unknown Country',
            'source': 'manual',
          };
        }
      }

      // Add quiz data if provided
      if (state.quizData != null && state.quizData!['isSkipped'] != true) {
        final quizData = state.quizData!;
        final skillLevel = quizData['skillLevel'] as String?;
        
        if (skillLevel != null) {
          SkillLevel? level;
          switch (skillLevel) {
            case 'beginner':
              level = SkillLevel.beginner;
              break;
            case 'intermediate':
              level = SkillLevel.intermediate;
              break;
            case 'advanced':
              level = SkillLevel.advanced;
              break;
          }
          
          if (level != null) {
            updateData['skill.computedLevel'] = level.name;
            updateData['skill.quizScore'] = quizData['score'];
            updateData['onboarding.quizCompleted'] = true;
          }
        }
      }

      // Add availability data if provided
      if (state.availabilityData != null) {
        updateData['availability'] = state.availabilityData!['availability'];
        updateData['onboarding.availabilityProvided'] = true;
      }

      // Add profile data if provided
      if (state.profileData != null) {
        final profileData = state.profileData!;
        if (profileData['name'] != null) {
          updateData['displayName'] = profileData['name'];
        }
        // Note: Avatar would typically be uploaded to Storage, simplified here
      }

      print('🔵 Completing onboarding with data: $updateData');
      
      // Update user document
      await UserService.updateUserFields(user.uid, updateData);
      
      print('✅ Onboarding completed successfully in Firestore');
      
      state = state.copyWith(
        isLoading: false,
        isCompleted: true,
        currentStep: 4,
      );
    } catch (e) {
      print('❌ Error completing onboarding: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Reset onboarding state
  void reset() {
    state = const OnboardingState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider to check if user needs onboarding
final needsOnboardingProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return false;
      return !user.hasCompletedOnboarding;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider to check if user can join lobbies (has skill level)
final canJoinLobbiesProvider = Provider<bool>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  
  return userAsync.when(
    data: (user) {
      if (user == null) return false;
      return user.canJoinLobbies;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});