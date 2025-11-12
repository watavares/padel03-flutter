import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Radio card widget for quiz questions and selections
class RadioCard<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String title;
  final String? subtitle;
  final ValueChanged<T?>? onChanged;
  final bool isSelected;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool showRadio;

  const RadioCard({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.onChanged,
    this.leading,
    this.trailing,
    this.padding,
    this.showRadio = true,
  }) : isSelected = value == groupValue;

  /// Constructor for quiz options
  const RadioCard.quiz({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.onChanged,
    this.leading,
    this.trailing,
    this.padding,
  }) : isSelected = value == groupValue,
       showRadio = true;

  /// Constructor for selection cards without radio button
  const RadioCard.selection({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.onChanged,
    this.leading,
    this.trailing,
    this.padding,
  }) : isSelected = value == groupValue,
       showRadio = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppAnimations.fast,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChanged != null ? () {
            HapticFeedback.selectionClick();
            onChanged!(value);
          } : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: AppAnimations.fast,
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withOpacity(0.08) : AppColors.white,
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.grey200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: isSelected ? AppShadows.medium : AppShadows.small,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.md),
                ],
                if (showRadio) ...[
                  AnimatedContainer(
                    duration: AppAnimations.fast,
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.primaryBlue : AppColors.white,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 12,
                            color: AppColors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: isSelected 
                                ? AppColors.primaryBlue.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Specialized radio card for skill level selection
class SkillLevelCard extends StatelessWidget {
  final String level;
  final String description;
  final String? selectedLevel;
  final ValueChanged<String?>? onChanged;
  final IconData icon;
  final Color iconColor;

  const SkillLevelCard({
    super.key,
    required this.level,
    required this.description,
    required this.selectedLevel,
    required this.onChanged,
    required this.icon,
    required this.iconColor,
  });

  bool get isSelected => level == selectedLevel;

  @override
  Widget build(BuildContext context) {
    return RadioCard<String>(
      value: level,
      groupValue: selectedLevel,
      title: level,
      subtitle: description,
      onChanged: onChanged,
      showRadio: false,
      leading: AnimatedContainer(
        duration: AppAnimations.fast,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected 
              ? iconColor.withOpacity(0.2)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(
          icon,
          color: isSelected ? iconColor : AppColors.grey400,
          size: 24,
        ),
      ),
      trailing: AnimatedContainer(
        duration: AppAnimations.fast,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.grey300,
            width: 2,
          ),
          color: isSelected ? AppColors.primaryBlue : AppColors.white,
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                size: 16,
                color: AppColors.white,
              )
            : null,
      ),
    );
  }
}

/// Toggle card for availability or settings
class ToggleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData? icon;
  final Color? iconColor;

  const ToggleCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onChanged != null ? () {
            HapticFeedback.selectionClick();
            onChanged!(!value);
          } : null,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: value ? AppColors.primaryBlue : AppColors.grey200,
                width: value ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: AppShadows.small,
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: iconColor ?? (value ? AppColors.primaryBlue : AppColors.grey400),
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: value ? AppColors.primaryBlue : AppColors.textPrimary,
                          fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle!,
                          style: AppTypography.bodySmall.copyWith(
                            color: value 
                                ? AppColors.primaryBlue.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: AppAnimations.fast,
                  width: 52,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: value ? AppColors.primaryBlue : AppColors.grey300,
                  ),
                  child: AnimatedAlign(
                    duration: AppAnimations.fast,
                    alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: AppShadows.small,
                      ),
                      child: value
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.primaryBlue,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}