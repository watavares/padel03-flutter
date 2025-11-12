// PadelArena Animated Components
// Micro-interactions, transitions, and animated UI elements
// Designed for energetic, sporty feel with <300ms interactions

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';

// =============================================================================
// ANIMATED LOBBY CARD - Hover/tap elevation + scale (1.05)
// =============================================================================
class AnimatedLobbyCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final bool isJoined;

  const AnimatedLobbyCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.isJoined = false,
  });

  @override
  State<AnimatedLobbyCard> createState() => _AnimatedLobbyCardState();
}

class _AnimatedLobbyCardState extends State<AnimatedLobbyCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _elevationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
    _elevationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    _scaleController.reverse();
    _elevationController.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _elevationAnimation]),
      builder: (context, child) {
        return Container(
          margin: widget.margin,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * (_elevationAnimation.value / 4)),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// ANIMATED JOIN BUTTON - Compress → loading pulse → expand to "Joined"
// =============================================================================
class AnimatedJoinButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isJoined;
  final String? loadingText;

  const AnimatedJoinButton({
    super.key,
    this.onPressed,
    this.isJoined = false,
    this.loadingText,
  });

  @override
  State<AnimatedJoinButton> createState() => _AnimatedJoinButtonState();
}

class _AnimatedJoinButtonState extends State<AnimatedJoinButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _loadingController;
  late AnimationController _successController;
  late Animation<double> _pressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _successScale;

  bool _isLoading = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    _successScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    // Repeat loading pulse
    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isLoading) {
        _loadingController.reverse();
      } else if (status == AnimationStatus.dismissed && _isLoading) {
        _loadingController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pressController.dispose();
    _loadingController.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (_isLoading || widget.isJoined) return;

    // Step 1: Compress button
    HapticFeedback.mediumImpact();
    await _pressController.forward();
    await _pressController.reverse();

    // Step 2: Loading state with pulse
    setState(() => _isLoading = true);
    _loadingController.forward();

    // Simulate network call
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
    
    await Future.delayed(const Duration(milliseconds: 1500));

    // Step 3: Success animation
    setState(() {
      _isLoading = false;
      _showSuccess = true;
    });
    _loadingController.stop();
    _successController.forward();

    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isJoined || _showSuccess) {
      return AnimatedBuilder(
        animation: _successScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _successScale.value,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: PadelColors.success, // Use solid success color instead of gradient
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: PadelColors.success.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Joined',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pressAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isLoading 
              ? _pulseAnimation.value 
              : _pressAnimation.value,
          child: GestureDetector(
            onTap: _handlePress,
            child: Container(
              height: 56, // Increased height for better touch target
              decoration: BoxDecoration(
                gradient: PadelColors.primaryGradient, // Use primary gradient instead of accent
                borderRadius: BorderRadius.circular(16), // More rounded corners
                boxShadow: _isLoading 
                    ? [
                        BoxShadow(
                          color: PadelColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: PadelColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: _isLoading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Joining...',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.sports_tennis,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Join Match',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: 16,
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

// =============================================================================
// STAGGERED FADE-IN ANIMATION - For loading lobby cards (60ms stagger)
// =============================================================================
class StaggeredFadeInList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration animationDuration;

  const StaggeredFadeInList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<StaggeredFadeInList> createState() => _StaggeredFadeInListState();
}

class _StaggeredFadeInListState extends State<StaggeredFadeInList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = [];
    _fadeAnimations = [];
    _slideAnimations = [];

    for (int i = 0; i < widget.children.length; i++) {
      final controller = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );
      _controllers.add(controller);

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
      _fadeAnimations.add(fadeAnimation);

      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
      _slideAnimations.add(slideAnimation);

      // Start animation with stagger
      Future.delayed(widget.staggerDelay * i, () {
        if (mounted) controller.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimations[index], _slideAnimations[index]]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

// =============================================================================
// AVATAR POP-IN ANIMATION - For when players join (bounce effect)
// =============================================================================
class AnimatedAvatarSlot extends StatefulWidget {
  final String? imageUrl;
  final String? initial;
  final bool isEmpty;
  final VoidCallback? onTap;
  final int? level;

  const AnimatedAvatarSlot({
    super.key,
    this.imageUrl,
    this.initial,
    this.isEmpty = true,
    this.onTap,
    this.level,
  });

  @override
  State<AnimatedAvatarSlot> createState() => _AnimatedAvatarSlotState();
}

class _AnimatedAvatarSlotState extends State<AnimatedAvatarSlot>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
    ));

    if (!widget.isEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _popController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedAvatarSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEmpty && !widget.isEmpty) {
      _popController.forward();
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmpty) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: PadelColors.grey200,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: PadelColors.primary,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: const Icon(
            Icons.add,
            color: PadelColors.primary,
            size: 24,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: PadelColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: PadelColors.elevationMedium,
                ),
                child: widget.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          widget.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          widget.initial ?? '?',
                          style: PadelTypography.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              if (widget.level != null)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: PadelColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.level}',
                        style: PadelTypography.caption.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// SLIDE TRANSITION ANIMATIONS - For navigation between screens
// =============================================================================
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideUpRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        );
}

class SlideLeftRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Duration duration;

  SlideLeftRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            );
          },
        );
}