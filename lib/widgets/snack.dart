import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Snackbar helper for showing messages
class AppSnack {
  /// Show success message
  static void success(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
      icon: Icons.check_circle_outline,
    );
  }

  /// Show error message
  static void error(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
      icon: Icons.error_outline,
    );
  }

  /// Show info message
  static void info(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.info,
      icon: Icons.info_outline,
    );
  }

  /// Show warning message
  static void warning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.warning,
      icon: Icons.warning_outlined,
    );
  }

  /// Show custom snackbar
  static void custom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: backgroundColor ?? AppColors.grey800,
      textColor: textColor,
      icon: icon,
      duration: duration,
      action: action,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    
    // Clear any existing snackbars
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? AppColors.white,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: textColor ?? AppColors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration ?? const Duration(seconds: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.lg),
      action: action,
    );

    messenger.showSnackBar(snackBar);
  }
}

/// Toast-like overlay message
class AppToast {
  static OverlayEntry? _overlayEntry;

  /// Show toast message
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    ToastPosition position = ToastPosition.bottom,
  }) {
    _removeToast();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        backgroundColor: backgroundColor ?? AppColors.grey800.withOpacity(0.9),
        textColor: textColor ?? AppColors.white,
        icon: icon,
        position: position,
      ),
    );

    overlay.insert(_overlayEntry!);

    // Auto remove after duration
    Future.delayed(duration, _removeToast);
  }

  static void _removeToast() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

enum ToastPosition { top, center, bottom }

class _ToastWidget extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final ToastPosition position;

  const _ToastWidget({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.position,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    double topPosition;
    switch (widget.position) {
      case ToastPosition.top:
        topPosition = size.height * 0.1;
        break;
      case ToastPosition.center:
        topPosition = size.height * 0.45;
        break;
      case ToastPosition.bottom:
        topPosition = size.height * 0.8;
        break;
    }

    return Positioned(
      top: topPosition,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: Opacity(
              opacity: _animation.value,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.large,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.textColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Flexible(
                        child: Text(
                          widget.message,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                            color: widget.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loading overlay
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;

  /// Show loading overlay
  static void show(
    BuildContext context, {
    String? message,
    Color? backgroundColor,
  }) {
    _removeLoading();

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(
        message: message,
        backgroundColor: backgroundColor ?? AppColors.grey900.withOpacity(0.5),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  /// Hide loading overlay
  static void hide() {
    _removeLoading();
  }

  static void _removeLoading() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _LoadingWidget extends StatelessWidget {
  final String? message;
  final Color backgroundColor;

  const _LoadingWidget({
    this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.large,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  message!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}