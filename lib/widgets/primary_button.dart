import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Primary button widget with consistent styling
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final Size? minimumSize;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.minimumSize,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryBlue,
        foregroundColor: textColor ?? AppColors.textOnPrimary,
        padding: padding ?? const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        minimumSize: minimumSize ?? const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        elevation: 0,
        shadowColor: AppColors.primaryBlue.withOpacity(0.3),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              HapticFeedback.lightImpact();
              return AppColors.white.withOpacity(0.1);
            }
            return null;
          },
        ),
      ),
      child: AnimatedSwitcher(
        duration: AppAnimations.fast,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.textOnPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTypography.buttonMedium.copyWith(
                        color: textColor ?? AppColors.textOnPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary button with outline styling
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        minimumSize: const Size(120, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        side: BorderSide(
          color: borderColor ?? AppColors.primaryBlue,
          width: 1.5,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              HapticFeedback.lightImpact();
              return AppColors.primaryBlue.withOpacity(0.05);
            }
            return null;
          },
        ),
      ),
      child: AnimatedSwitcher(
        duration: AppAnimations.fast,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? AppColors.primaryBlue,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: AppTypography.buttonMedium.copyWith(
                      color: textColor ?? AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
      ),
    );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Text button with consistent styling
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final bool isExpanded;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              HapticFeedback.lightImpact();
              return AppColors.primaryBlue.withOpacity(0.05);
            }
            return null;
          },
        ),
      ),
      child: Text(
        text,
        style: AppTypography.buttonMedium.copyWith(
          color: textColor ?? AppColors.primaryBlue,
        ),
      ),
    );

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}