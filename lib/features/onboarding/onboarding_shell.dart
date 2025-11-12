import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/step_indicator.dart';
import '../../design_system/design_system.dart';
// import '../../models/onboarding_models.dart'; // Commented out for now
import 'location_step.dart';
import 'quiz_step.dart';
import 'availability_step.dart';
import 'avatar_step.dart';
import 'done_step.dart';

// Simple onboarding state for now
class SimpleOnboardingState {
  final int currentStep;
  final bool isCompleted;
  final bool isSkipped;
  final Map<String, dynamic>? locationData;
  final Map<String, dynamic>? quizData;
  final Map<String, dynamic>? availabilityData;
  final Map<String, dynamic>? profileData;

  const SimpleOnboardingState({
    this.currentStep = 0,
    this.isCompleted = false,
    this.isSkipped = false,
    this.locationData,
    this.quizData,
    this.availabilityData,
    this.profileData,
  });

  SimpleOnboardingState copyWith({
    int? currentStep,
    bool? isCompleted,
    bool? isSkipped,
    Map<String, dynamic>? locationData,
    Map<String, dynamic>? quizData,
    Map<String, dynamic>? availabilityData,
    Map<String, dynamic>? profileData,
  }) {
    return SimpleOnboardingState(
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      isSkipped: isSkipped ?? this.isSkipped,
      locationData: locationData ?? this.locationData,
      quizData: quizData ?? this.quizData,
      availabilityData: availabilityData ?? this.availabilityData,
      profileData: profileData ?? this.profileData,
    );
  }
}

class OnboardingShell extends StatefulWidget {
  const OnboardingShell({super.key});

  @override
  State<OnboardingShell> createState() => _OnboardingShellState();
}

class _OnboardingShellState extends State<OnboardingShell> {
  SimpleOnboardingState onboardingState = const SimpleOnboardingState();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: PadelColors.grey50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onboardingState.currentStep > 0 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: PadelColors.primary),
              onPressed: () {
                HapticFeedback.lightImpact();
                _previousStep();
              },
            )
          : null,
        actions: [
          if (onboardingState.currentStep < 4) // Allow skip except on done step
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _showSkipDialog(context);
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: PadelColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(PadelSpacing.lg),
              child: StepIndicator(
                currentStep: onboardingState.currentStep,
                totalSteps: 5,
                stepLabels: const [
                  'Location',
                  'Skill Level',
                  'Availability',
                  'Profile',
                  'Done'
                ],
              ),
            ),
            
            // Content area
            Expanded(
              child: AnimatedSwitcher(
                duration: PadelAnimations.normal,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    )),
                    child: child,
                  );
                },
                child: _buildCurrentStep(onboardingState.currentStep),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (onboardingState.currentStep < 4) {
      setState(() {
        onboardingState = onboardingState.copyWith(currentStep: onboardingState.currentStep + 1);
      });
    }
  }

  void _previousStep() {
    if (onboardingState.currentStep > 0) {
      setState(() {
        onboardingState = onboardingState.copyWith(currentStep: onboardingState.currentStep - 1);
      });
    }
  }

  void _skipOnboarding() {
    setState(() {
      onboardingState = onboardingState.copyWith(
        isCompleted: false,
        isSkipped: true,
      );
    });
    // Navigate to main app
    // TODO: Implement navigation to main app
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 0:
        return LocationStep(key: const ValueKey('location'), onNext: _nextStep);
      case 1:
        return QuizStep(key: const ValueKey('quiz'), onNext: _nextStep);
      case 2:
        return AvailabilityStep(key: const ValueKey('availability'), onNext: _nextStep);
      case 3:
        return AvatarStep(key: const ValueKey('avatar'), onNext: _nextStep);
      case 4:
        return const DoneStep(key: ValueKey('done'));
      default:
        return LocationStep(key: const ValueKey('location'), onNext: _nextStep);
    }
  }

  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PadelRadius.lg),
        ),
        title: const Text(
          'Skip Onboarding?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: PadelColors.textPrimary,
          ),
        ),
        content: const Text(
          'You can complete your profile later, but you\'ll need to set your skill level before joining any games.',
          style: TextStyle(
            fontSize: 16,
            color: PadelColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Continue Setup',
              style: TextStyle(
                color: PadelColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
              _skipOnboarding();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PadelColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(PadelRadius.md),
              ),
            ),
            child: const Text(
              'Skip for Now',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}