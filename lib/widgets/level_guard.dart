import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../models/user_model.dart';

/// LevelGuard - Route guard that prevents access to certain features
/// until user completes their skill level assessment
class LevelGuard extends StatelessWidget {
  final Widget child;
  final UserModel? user;
  final VoidCallback? onCompleteLevel;
  final String? customMessage;
  final String? customTitle;
  
  const LevelGuard({
    super.key,
    required this.child,
    this.user,
    this.onCompleteLevel,
    this.customMessage,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Check if user has completed skill level assessment
    final hasSkillLevel = user?.skill.effectiveLevel != null;
    final hasCompletedOnboarding = user?.onboarding.isCompleted ?? false;
    
    // If user has skill level or onboarding is complete, show protected content
    if (hasSkillLevel || hasCompletedOnboarding) {
      return child;
    }
    
    // Otherwise, show the level requirement modal/screen
    return _LevelRequiredScreen(
      onCompleteLevel: onCompleteLevel,
      customMessage: customMessage,
      customTitle: customTitle,
    );
  }
}

class _LevelRequiredScreen extends StatelessWidget {
  final VoidCallback? onCompleteLevel;
  final String? customMessage;
  final String? customTitle;
  
  const _LevelRequiredScreen({
    this.onCompleteLevel,
    this.customMessage,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Use GoRouter instead of Navigator to avoid popping off the stack
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const Spacer(),
                ],
              ),
              
              const Spacer(),
              
              // Main content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: const Icon(
                        Icons.sports_tennis,
                        size: 40,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    
                    // Title
                    Text(
                      customTitle ?? 'Set Your Skill Level',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Message
                    Text(
                      customMessage ?? 
                      'To join games and connect with other players, you need to complete your skill level assessment. This helps us match you with players of similar abilities.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    
                    // Benefits list
                    _buildBenefitItem(
                      icon: Icons.groups,
                      title: 'Better Matches',
                      description: 'Play with people at your level',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBenefitItem(
                      icon: Icons.trending_up,
                      title: 'Track Progress',
                      description: 'Monitor your improvement over time',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildBenefitItem(
                      icon: Icons.emoji_events,
                      title: 'Fair Competition',
                      description: 'Enjoy competitive and balanced games',
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Action buttons
              Column(
                children: [
                  PrimaryButton(
                    text: 'Complete Skill Assessment',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _handleCompleteLevel(context);
                    },
                    isLoading: false,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    ),
                    child: const Text(
                      'Maybe Later',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleCompleteLevel(BuildContext context) {
    if (onCompleteLevel != null) {
      onCompleteLevel!();
    } else {
      // Default behavior: navigate to quiz/onboarding
      // TODO: Implement navigation to quiz step
      _showQuizBottomSheet(context);
    }
  }

  void _showQuizBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _QuickLevelAssessmentSheet(),
    );
  }
}

/// Quick level assessment modal for immediate use
class _QuickLevelAssessmentSheet extends StatefulWidget {
  const _QuickLevelAssessmentSheet();

  @override
  State<_QuickLevelAssessmentSheet> createState() => _QuickLevelAssessmentSheetState();
}

class _QuickLevelAssessmentSheetState extends State<_QuickLevelAssessmentSheet> {
  SkillLevel? _selectedLevel;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Header
            const Text(
              'Quick Level Assessment',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Choose the level that best describes your current skill:',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxxl),
            
            // Level options
            Expanded(
              child: Column(
                children: SkillLevel.values.map((level) {
                  final isSelected = _selectedLevel == level;
                  
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedLevel = level;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppColors.primaryBlue.withOpacity(0.05)
                          : Colors.transparent,
                        border: Border.all(
                          color: isSelected 
                            ? AppColors.primaryBlue 
                            : AppColors.grey200,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected 
                                ? AppColors.primaryBlue 
                                : AppColors.grey100,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              _getLevelIcon(level),
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level.displayName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected 
                                      ? AppColors.primaryBlue 
                                      : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: 'Save Level',
                    onPressed: _selectedLevel != null ? _saveLevelAndProceed : null,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  IconData _getLevelIcon(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Icons.star_outline;
      case SkillLevel.intermediate:
        return Icons.star_half;
      case SkillLevel.advanced:
        return Icons.star;
    }
  }

  Future<void> _saveLevelAndProceed() async {
    if (_selectedLevel == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      HapticFeedback.lightImpact();
      
      // TODO: Save skill level to user document
      print('Saving skill level: ${_selectedLevel!.name}');
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        Navigator.of(context).pop();
        // TODO: Navigate back or refresh state
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}