import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import 'onboarding_providers.dart';

/// App state enum to determine which screen to show
enum AppState {
  loading,
  unauthenticated,
  onboarding,
  authenticated,
}

/// Main app state provider that determines which screen to show
final appStateProvider = Provider<AppState>((ref) {
  final authState = ref.watch(authStateProvider);
  final needsOnboarding = ref.watch(needsOnboardingProvider);
  
  return authState.when(
    data: (user) {
      if (user == null) {
        return AppState.unauthenticated;
      } else if (needsOnboarding) {
        return AppState.onboarding;
      } else {
        return AppState.authenticated;
      }
    },
    loading: () => AppState.loading,
    error: (_, __) => AppState.unauthenticated,
  );
});

/// Loading state provider - combines all loading states
final isLoadingProvider = Provider<bool>((ref) {
  final authController = ref.watch(authControllerProvider);
  final onboardingController = ref.watch(onboardingControllerProvider);
  
  return authController.isLoading || 
         authController.isSigningOut || 
         onboardingController.isLoading;
});

/// Error message provider - gets the most recent error
final errorMessageProvider = Provider<String?>((ref) {
  final authController = ref.watch(authControllerProvider);
  final onboardingController = ref.watch(onboardingControllerProvider);
  
  // Return the first non-null error
  return authController.error ?? onboardingController.error;
});