import 'package:flutter/material.dart';
import 'design_system.dart';

// Chip Component
enum PadelChipStyle {
  filled,
  outline,
  ghost,
}

enum PadelChipSize {
  small,
  medium,
  large,
}

class PadelChip extends StatelessWidget {
  final String label;
  final PadelChipStyle style;
  final PadelChipSize size;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isSelected;

  const PadelChip({
    super.key,
    required this.label,
    this.style = PadelChipStyle.filled,
    this.size = PadelChipSize.medium,
    this.color,
    this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? PadelColors.primary;
    final config = _getChipConfig(chipColor);
    final sizeConfig = _getSizeConfig();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PadelAnimations.fast,
        padding: EdgeInsets.symmetric(
          horizontal: sizeConfig.horizontalPadding,
          vertical: sizeConfig.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          border: config.border,
          borderRadius: BorderRadius.circular(PadelRadius.full),
          boxShadow: isSelected ? [PadelShadows.sm] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: sizeConfig.iconSize,
                color: config.foregroundColor,
              ),
              SizedBox(width: PadelSpacing.xs),
            ],
            Text(
              label,
              style: sizeConfig.textStyle.copyWith(
                color: config.foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ChipConfig _getChipConfig(Color chipColor) {
    switch (style) {
      case PadelChipStyle.filled:
        return ChipConfig(
          backgroundColor: isSelected ? chipColor : chipColor.withOpacity(0.1),
          foregroundColor: isSelected ? PadelColors.white : chipColor,
        );
      case PadelChipStyle.outline:
        return ChipConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: chipColor,
          border: Border.all(color: chipColor, width: 1.5),
        );
      case PadelChipStyle.ghost:
        return ChipConfig(
          backgroundColor: chipColor.withOpacity(0.1),
          foregroundColor: chipColor,
        );
    }
  }

  ChipSizeConfig _getSizeConfig() {
    switch (size) {
      case PadelChipSize.small:
        return ChipSizeConfig(
          horizontalPadding: PadelSpacing.sm,
          verticalPadding: PadelSpacing.xs,
          textStyle: PadelTypography.labelSmall,
          iconSize: 12,
        );
      case PadelChipSize.medium:
        return ChipSizeConfig(
          horizontalPadding: PadelSpacing.md,
          verticalPadding: PadelSpacing.sm,
          textStyle: PadelTypography.labelMedium,
          iconSize: 14,
        );
      case PadelChipSize.large:
        return ChipSizeConfig(
          horizontalPadding: PadelSpacing.lg,
          verticalPadding: PadelSpacing.md,
          textStyle: PadelTypography.labelLarge,
          iconSize: 16,
        );
    }
  }
}

class ChipConfig {
  final Color? backgroundColor;
  final Color foregroundColor;
  final Border? border;

  ChipConfig({
    this.backgroundColor,
    required this.foregroundColor,
    this.border,
  });
}

class ChipSizeConfig {
  final double horizontalPadding;
  final double verticalPadding;
  final TextStyle textStyle;
  final double iconSize;

  ChipSizeConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.textStyle,
    required this.iconSize,
  });
}

// Card Component
class PadelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final double? borderRadius;
  final Border? border;

  const PadelCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? PadelColors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? PadelRadius.md),
        border: border,
        boxShadow: elevation != null && elevation! > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation! * 2,
                  offset: Offset(0, elevation! / 2),
                ),
              ]
            : [PadelShadows.sm],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? PadelRadius.md),
          child: Padding(
            padding: padding ?? EdgeInsets.all(PadelSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Badge Component
enum PadelBadgeStyle {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
}

class PadelBadge extends StatelessWidget {
  final String text;
  final PadelBadgeStyle style;
  final bool isLarge;

  const PadelBadge({
    super.key,
    required this.text,
    this.style = PadelBadgeStyle.primary,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? PadelSpacing.md : PadelSpacing.sm,
        vertical: isLarge ? PadelSpacing.sm : PadelSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(PadelRadius.sm),
      ),
      child: Text(
        text.toUpperCase(),
        style: (isLarge ? PadelTypography.labelMedium : PadelTypography.labelSmall)
            .copyWith(
          color: config.foregroundColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  BadgeConfig _getBadgeConfig() {
    switch (style) {
      case PadelBadgeStyle.primary:
        return BadgeConfig(
          backgroundColor: PadelColors.primary,
          foregroundColor: PadelColors.white,
        );
      case PadelBadgeStyle.secondary:
        return BadgeConfig(
          backgroundColor: PadelColors.secondary,
          foregroundColor: PadelColors.white,
        );
      case PadelBadgeStyle.success:
        return BadgeConfig(
          backgroundColor: PadelColors.success,
          foregroundColor: PadelColors.white,
        );
      case PadelBadgeStyle.warning:
        return BadgeConfig(
          backgroundColor: PadelColors.warning,
          foregroundColor: PadelColors.white,
        );
      case PadelBadgeStyle.error:
        return BadgeConfig(
          backgroundColor: PadelColors.error,
          foregroundColor: PadelColors.white,
        );
      case PadelBadgeStyle.info:
        return BadgeConfig(
          backgroundColor: PadelColors.info,
          foregroundColor: PadelColors.white,
        );
    }
  }
}

class BadgeConfig {
  final Color backgroundColor;
  final Color foregroundColor;

  BadgeConfig({
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

// XP Progress Bar
class PadelXPProgressBar extends StatefulWidget {
  final int currentXP;
  final int maxXP;
  final String label;
  final bool showAnimation;

  const PadelXPProgressBar({
    super.key,
    required this.currentXP,
    required this.maxXP,
    this.label = 'XP',
    this.showAnimation = true,
  });

  @override
  State<PadelXPProgressBar> createState() => _PadelXPProgressBarState();
}

class _PadelXPProgressBarState extends State<PadelXPProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: PadelAnimations.slow,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentXP / widget.maxXP,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: PadelAnimations.easeOut,
    ));

    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: PadelTypography.labelMedium.copyWith(
                color: PadelColors.textSecondary,
              ),
            ),
            Text(
              '${widget.currentXP} / ${widget.maxXP}',
              style: PadelTypography.labelMedium.copyWith(
                color: PadelColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: PadelSpacing.sm),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: PadelColors.grey200,
            borderRadius: BorderRadius.circular(PadelRadius.sm),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: PadelColors.accentGradient,
                    borderRadius: BorderRadius.circular(PadelRadius.sm),
                    boxShadow: [
                      BoxShadow(
                        color: PadelColors.accent.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Match Card Component
class PadelMatchCard extends StatelessWidget {
  final String time;
  final String club;
  final String levelRange;
  final String status;
  final int currentPlayers;
  final int maxPlayers;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final bool isJoined;

  const PadelMatchCard({
    super.key,
    required this.time,
    required this.club,
    required this.levelRange,
    required this.status,
    required this.currentPlayers,
    required this.maxPlayers,
    this.onJoin,
    this.onLeave,
    this.isJoined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = currentPlayers >= maxPlayers;

    return PadelCard(
      onTap: isJoined ? onLeave : (isFull ? null : onJoin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: PadelTypography.h6.copyWith(
                  color: PadelColors.primary,
                ),
              ),
              PadelBadge(
                text: status,
                style: _getBadgeStyle(status),
              ),
            ],
          ),
          SizedBox(height: PadelSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: PadelColors.textSecondary,
              ),
              SizedBox(width: PadelSpacing.xs),
              Expanded(
                child: Text(
                  club,
                  style: PadelTypography.bodyMedium.copyWith(
                    color: PadelColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: PadelSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 16,
                color: PadelColors.textSecondary,
              ),
              SizedBox(width: PadelSpacing.xs),
              Text(
                'Level $levelRange',
                style: PadelTypography.bodyMedium.copyWith(
                  color: PadelColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: PadelSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: PadelColors.textSecondary,
                  ),
                  SizedBox(width: PadelSpacing.xs),
                  Text(
                    '$currentPlayers/$maxPlayers players',
                    style: PadelTypography.bodySmall.copyWith(
                      color: PadelColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!isFull || isJoined)
                PadelButton(
                  text: isJoined ? 'Leave' : 'Join',
                  style: isJoined
                      ? PadelButtonStyle.outline
                      : PadelButtonStyle.accent,
                  size: PadelButtonSize.small,
                  onPressed: isJoined ? onLeave : onJoin,
                ),
            ],
          ),
        ],
      ),
    );
  }

  PadelBadgeStyle _getBadgeStyle(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return PadelBadgeStyle.success;
      case 'full':
        return PadelBadgeStyle.secondary;
      case 'in progress':
        return PadelBadgeStyle.warning;
      case 'completed':
        return PadelBadgeStyle.primary;
      default:
        return PadelBadgeStyle.info;
    }
  }
}

// Player Card Component
class PadelPlayerCard extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final int rank;
  final int elo;
  final String level;
  final VoidCallback? onChallenge;
  final VoidCallback? onViewProfile;
  final bool isCurrentUser;

  const PadelPlayerCard({
    super.key,
    required this.name,
    this.photoUrl,
    required this.rank,
    required this.elo,
    required this.level,
    this.onChallenge,
    this.onViewProfile,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(rank);

    return PadelCard(
      onTap: onViewProfile,
      border: isCurrentUser
          ? Border.all(color: PadelColors.accent, width: 2)
          : null,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: rankColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: PadelSpacing.md),
          CircleAvatar(
            radius: 24,
            backgroundColor: PadelColors.grey200,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Icon(
                    Icons.person,
                    color: PadelColors.grey600,
                    size: 24,
                  )
                : null,
          ),
          SizedBox(width: PadelSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#$rank',
                      style: PadelTypography.labelLarge.copyWith(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: PadelSpacing.sm),
                    Expanded(
                      child: Text(
                        name,
                        style: PadelTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: PadelSpacing.xs),
                Row(
                  children: [
                    Text(
                      '$elo ELO',
                      style: PadelTypography.bodySmall.copyWith(
                        color: PadelColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: PadelSpacing.sm),
                    PadelChip(
                      label: level,
                      size: PadelChipSize.small,
                      style: PadelChipStyle.ghost,
                      color: PadelColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!isCurrentUser && onChallenge != null)
            PadelButton(
              text: 'Challenge',
              style: PadelButtonStyle.outline,
              size: PadelButtonSize.small,
              onPressed: onChallenge,
            ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) {
      switch (rank) {
        case 1:
          return PadelColors.accent; // Gold
        case 2:
          return PadelColors.secondary; // Silver
        case 3:
          return PadelColors.primary; // Bronze
        default:
          return PadelColors.grey400;
      }
    }
    return PadelColors.grey400;
  }
}