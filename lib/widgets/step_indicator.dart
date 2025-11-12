import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Step indicator widget for onboarding progress
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final double? height;
  final bool showLabels;
  final bool showStepNumbers;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.height,
    this.showLabels = false,
    this.showStepNumbers = true,
  });

  @override
  Widget build(BuildContext context) {
    final activeCol = activeColor ?? AppColors.primaryBlue;
    final inactiveCol = inactiveColor ?? AppColors.grey300;
    final completedCol = completedColor ?? AppColors.success;

    return Column(
      children: [
        // Step indicators
        Container(
          height: height ?? 4,
          child: Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < totalSteps - 1 ? AppSpacing.xs : 0,
                  ),
                  child: AnimatedContainer(
                    duration: AppAnimations.medium,
                    height: height ?? 4,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? completedCol 
                          : isActive 
                              ? activeCol 
                              : inactiveCol,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        
        // Step numbers (optional)
        if (showStepNumbers) ...[
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              
              return AnimatedContainer(
                duration: AppAnimations.medium,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted 
                      ? completedCol 
                      : isActive 
                          ? activeCol 
                          : inactiveCol,
                  border: !isCompleted && !isActive
                      ? Border.all(color: inactiveCol, width: 2)
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.white,
                        )
                      : Text(
                          '${index + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: isActive ? AppColors.white : AppColors.grey500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
        
        // Step labels (optional)
        if (showLabels && stepLabels != null) ...[
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;
              final label = stepLabels!.length > index ? stepLabels![index] : '';
              
              return Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: isCompleted 
                        ? completedCol 
                        : isActive 
                            ? activeCol 
                            : AppColors.textTertiary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Linear progress indicator with custom styling
class LinearStepProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final BorderRadius? borderRadius;
  final String? label;

  const LinearStepProgress({
    super.key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 8,
    this.borderRadius,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.grey200;
    final progressCol = progressColor ?? AppColors.primaryBlue;
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.sm);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: AnimatedContainer(
              duration: AppAnimations.medium,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: progressCol,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: progressCol.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular step indicator
class CircularStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const CircularStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.size = 12,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeCol = activeColor ?? AppColors.primaryBlue;
    final inactiveCol = inactiveColor ?? AppColors.grey300;
    final completedCol = completedColor ?? AppColors.success;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        
        return AnimatedContainer(
          duration: AppAnimations.fast,
          margin: EdgeInsets.only(
            right: index < totalSteps - 1 ? AppSpacing.sm : 0,
          ),
          width: isActive ? size * 1.5 : size,
          height: size,
          decoration: BoxDecoration(
            color: isCompleted 
                ? completedCol 
                : isActive 
                    ? activeCol 
                    : inactiveCol,
            borderRadius: BorderRadius.circular(size / 2),
          ),
        );
      }),
    );
  }
}

/// Breadcrumb-style step indicator
class BreadcrumbStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> stepNames;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const BreadcrumbStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepNames,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final activeCol = activeColor ?? AppColors.primaryBlue;
    final inactiveCol = inactiveColor ?? AppColors.grey400;
    final completedCol = completedColor ?? AppColors.success;

    return Wrap(
      children: List.generate(stepNames.length, (index) {
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final stepName = stepNames[index];
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: AppAnimations.fast,
              style: AppTypography.bodyMedium.copyWith(
                color: isCompleted 
                    ? completedCol 
                    : isActive 
                        ? activeCol 
                        : inactiveCol,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(stepName),
            ),
            if (index < stepNames.length - 1) ...[
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: inactiveCol,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ],
        );
      }),
    );
  }
}