import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';

// Modern Animated Card Component
class PadelModernCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool enableHover;
  final BorderRadius? borderRadius;

  const PadelModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.enableHover = true,
    this.borderRadius,
  });

  @override
  State<PadelModernCard> createState() => _PadelModernCardState();
}

class _PadelModernCardState extends State<PadelModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PadelAnimations.cardHover,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PadelAnimations.smoothOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverStart() {
    if (!widget.enableHover) return;
    setState(() => _isHovered = true);
    _controller.forward();
  }

  void _onHoverEnd() {
    if (!widget.enableHover) return;
    setState(() => _isHovered = false);
    _controller.reverse();
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverStart(),
      onExit: (_) => _onHoverEnd(),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) => _onTapUp(),
        onTapCancel: _onTapCancel,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _isPressed ? 0.98 : _scaleAnimation.value,
              child: AnimatedContainer(
                duration: PadelAnimations.fast,
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? Colors.white,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(PadelRadius.lg),
                  boxShadow: _isHovered 
                    ? PadelShadows.cardHover 
                    : PadelShadows.card,
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(PadelRadius.lg),
                  child: Padding(
                    padding: widget.padding ?? const EdgeInsets.all(PadelSpacing.lg),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Modern Animated Button
class PadelModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PadelButtonStyle style;
  final PadelButtonSize size;
  final bool isLoading;
  final double? width;

  const PadelModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = PadelButtonStyle.primary,
    this.size = PadelButtonSize.medium,
    this.isLoading = false,
    this.width,
  });

  @override
  State<PadelModernButton> createState() => _PadelModernButtonState();
}

class _PadelModernButtonState extends State<PadelModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PadelAnimations.buttonPress,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PadelAnimations.buttonCurve,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  void _onTapUp() {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getButtonConfig();
    
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _onTapDown() : null,
      onTapUp: widget.onPressed != null ? (_) => _onTapUp() : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: config.height,
              decoration: BoxDecoration(
                gradient: config.gradient,
                borderRadius: BorderRadius.circular(config.borderRadius),
                boxShadow: widget.onPressed != null ? PadelShadows.button : null,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(config.borderRadius),
                child: Stack(
                  children: [
                    // Ripple effect
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(config.borderRadius),
                          color: Colors.white.withOpacity(
                            0.2 * _rippleAnimation.value,
                          ),
                        ),
                      ),
                    ),
                    // Button content
                    Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  config.textColor,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: config.textColor,
                                    size: config.iconSize,
                                  ),
                                  SizedBox(width: config.spacing),
                                ],
                                Text(
                                  widget.text,
                                  style: config.textStyle.copyWith(
                                    color: config.textColor,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.style) {
      case PadelButtonStyle.primary:
        return _ButtonConfig(
          gradient: PadelColors.primaryGradient,
          textColor: Colors.white,
          textStyle: _getTextStyle(),
          height: _getHeight(),
          borderRadius: PadelRadius.lg,
          iconSize: _getIconSize(),
          spacing: PadelSpacing.sm,
        );
      case PadelButtonStyle.secondary:
        return _ButtonConfig(
          gradient: LinearGradient(
            colors: [PadelColors.secondary, PadelColors.secondary],
          ),
          textColor: Colors.white,
          textStyle: _getTextStyle(),
          height: _getHeight(),
          borderRadius: PadelRadius.lg,
          iconSize: _getIconSize(),
          spacing: PadelSpacing.sm,
        );
      case PadelButtonStyle.outline:
        return _ButtonConfig(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.transparent],
          ),
          textColor: PadelColors.primary,
          textStyle: _getTextStyle(),
          height: _getHeight(),
          borderRadius: PadelRadius.lg,
          iconSize: _getIconSize(),
          spacing: PadelSpacing.sm,
        );
      case PadelButtonStyle.ghost:
        return _ButtonConfig(
          gradient: LinearGradient(
            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
          ),
          textColor: Colors.white,
          textStyle: _getTextStyle(),
          height: _getHeight(),
          borderRadius: PadelRadius.lg,
          iconSize: _getIconSize(),
          spacing: PadelSpacing.sm,
        );
      case PadelButtonStyle.accent:
        return _ButtonConfig(
          gradient: PadelColors.accentGradient,
          textColor: Colors.black,
          textStyle: _getTextStyle(),
          height: _getHeight(),
          borderRadius: PadelRadius.lg,
          iconSize: _getIconSize(),
          spacing: PadelSpacing.sm,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case PadelButtonSize.small:
        return PadelTypography.labelMedium;
      case PadelButtonSize.medium:
        return PadelTypography.labelLarge;
      case PadelButtonSize.large:
        return PadelTypography.h6;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case PadelButtonSize.small:
        return 36;
      case PadelButtonSize.medium:
        return 48;
      case PadelButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case PadelButtonSize.small:
        return 16;
      case PadelButtonSize.medium:
        return 20;
      case PadelButtonSize.large:
        return 24;
    }
  }
}

class _ButtonConfig {
  final Gradient gradient;
  final Color textColor;
  final TextStyle textStyle;
  final double height;
  final double borderRadius;
  final double iconSize;
  final double spacing;

  _ButtonConfig({
    required this.gradient,
    required this.textColor,
    required this.textStyle,
    required this.height,
    required this.borderRadius,
    required this.iconSize,
    required this.spacing,
  });
}

// XP Gain Animation Widget
class PadelXPGainAnimation extends StatefulWidget {
  final int xpGained;
  final VoidCallback? onComplete;

  const PadelXPGainAnimation({
    super.key,
    required this.xpGained,
    this.onComplete,
  });

  @override
  State<PadelXPGainAnimation> createState() => _PadelXPGainAnimationState();
}

class _PadelXPGainAnimationState extends State<PadelXPGainAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PadelAnimations.xpGain,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PadelAnimations.bounceIn,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PadelAnimations.smoothOut,
    ));

    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    await _controller.reverse();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: PadelSpacing.lg,
                  vertical: PadelSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: PadelColors.accentGradient,
                  borderRadius: BorderRadius.circular(PadelRadius.xl),
                  boxShadow: PadelShadows.floating,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.black,
                      size: 24,
                    ),
                    const SizedBox(width: PadelSpacing.sm),
                    Text(
                      '+${widget.xpGained} XP',
                      style: PadelTypography.h6.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Rank Up Animation Widget
class PadelRankUpAnimation extends StatefulWidget {
  final int newRank;
  final VoidCallback? onComplete;

  const PadelRankUpAnimation({
    super.key,
    required this.newRank,
    this.onComplete,
  });

  @override
  State<PadelRankUpAnimation> createState() => _PadelRankUpAnimationState();
}

class _PadelRankUpAnimationState extends State<PadelRankUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PadelAnimations.rankUp,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: PadelAnimations.spring,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    HapticFeedback.heavyImpact();
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    await _controller.reverse();
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    PadelColors.accent.withOpacity(_glowAnimation.value),
                    PadelColors.primary.withOpacity(_glowAnimation.value * 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: PadelColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: PadelColors.accent.withOpacity(0.5 * _glowAnimation.value),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: PadelSpacing.xs),
                      Text(
                        'RANK ${widget.newRank}',
                        style: PadelTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Modern Toggle Switch
class PadelModernToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? subtitle;

  const PadelModernToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
  });

  @override
  State<PadelModernToggle> createState() => _PadelModernToggleState();
}

class _PadelModernToggleState extends State<PadelModernToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: PadelAnimations.normal,
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: PadelColors.grey300,
      end: PadelColors.accent,
    ).animate(_controller);

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PadelModernToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged(!widget.value);
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: PadelTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: PadelSpacing.xs),
                  Text(
                    widget.subtitle!,
                    style: PadelTypography.caption.copyWith(
                      color: PadelColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: PadelSpacing.md),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  color: _colorAnimation.value,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_colorAnimation.value ?? PadelColors.grey300)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: PadelAnimations.normal,
                      curve: PadelAnimations.smoothOut,
                      left: widget.value ? 28 : 4,
                      top: 4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}