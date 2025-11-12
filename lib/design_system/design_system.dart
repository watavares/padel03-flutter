import 'package:flutter/material.dart';

// PadelArena Enhanced Design System - Energetic & Athletic Brand
// Clean, community-driven, sporty feel with micro-interactions

// Colors
class PadelColors {
  // Primary Brand Colors - CLEAN MINIMAL DESIGN
  static const Color primary = Color(0xFF1FB0F9); // Bright Blue - main color
  static const Color secondary = Color(0xFF64B5F6); // Light Blue variant
  static const Color accent = Color(0xFF1FB0F9); // Same as primary for consistency

  // Enhanced Brand Variations
  static const Color primaryLight = Color(0xFF4DC4FB);
  static const Color primaryDark = Color(0xFF0E8FD1);
  static const Color secondaryLight = Color(0xFF90CAF9);
  static const Color secondaryDark = Color(0xFF42A5F5);
  static const Color accentDark = Color(0xFF0E8FD1);
  static const Color accentLight = Color(0xFF4DC4FB);

  // Semantic Colors - cores funcionais
  static const Color success = Color(0xFF10B981); // Verde vibrante
  static const Color warning = Color(0xFFF59E0B); // Laranja vibrante
  static const Color error = Color(0xFFEF4444); // Vermelho vibrante
  static const Color info = secondary;

  // Neutral Colors - sistema cinza suave
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Text Colors - mantendo legibilidade
  static const Color textPrimary = grey900; // Escuro para boa legibilidade
  static const Color textSecondary = grey600; // Cinza médio
  static const Color textTertiary = grey500; // Cinza claro
  static const Color textOnPrimary = white;
  static const Color textOnAccent = white; // White text on blue for contrast

  // Background Colors
  static const Color background = grey50;
  static const Color surface = white;
  static const Color surfaceVariant = grey100;

  // VISUAL CONSISTENCY FIX: Standardized gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment(-0.7, -0.7), // 135 degrees - consistent angle
    end: Alignment(0.7, 0.7),
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment(-0.7, -0.7), // 135 degrees  
    end: Alignment(0.7, 0.7),
    colors: [primary, primaryDark], // Clean blue gradient
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment(-0.7, -0.7),
    end: Alignment(0.7, 0.7),
    colors: [success, Color(0xFF22C55E)],
  );

  // SHADOW CONSISTENCY FIX: Standardized elevation system
  static const List<BoxShadow> elevationNone = [];
  
  static const List<BoxShadow> elevationLow = [
    BoxShadow(
      color: Color(0x0D000000), // 5% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevationMedium = [
    BoxShadow(
      color: Color(0x14000000), // 8% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A000000), // 4% opacity
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> elevationHigh = [
    BoxShadow(
      color: Color(0x1A000000), // 10% opacity
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0F000000), // 6% opacity
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  // INTERACTION FEEDBACK: Enhanced glow effects
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x401FB0F9), // Primary with 25% opacity - updated to new blue
      blurRadius: 20,
      offset: Offset(0, 0),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> accentGlow = [
    BoxShadow(
      color: Color(0x401FB0F9), // Primary blue with 25% opacity
      blurRadius: 16,
      offset: Offset(0, 0),
      spreadRadius: 0,
    ),
  ];

  // ACCESSIBILITY: Smart color selection methods
  static Color getContrastText(Color backgroundColor) {
    // Calculate luminance and return appropriate text color
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? grey900 : white;
  }

  static Color getAccentColor({required bool onLightBackground}) {
    return accent; // Usar sempre a cor original vibrante
  }

  static Color getAccentTextColor({required bool onLightBackground}) {
    return onLightBackground ? black : accent; // Preto para contraste, lime para fundos escuros
  }
}

// Typography - ACCESSIBILITY ENHANCED
class PadelTypography {
  static const String _poppins = 'Poppins';
  static const String _inter = 'Inter';

  // HIERARCHY FIX: Clear size differentiation and proper line heights
  // Headings (Poppins Bold) - Mobile optimized
  static const TextStyle h1 = TextStyle(
    fontFamily: _poppins,
    fontSize: 28, // Reduced from 32 for mobile
    fontWeight: FontWeight.bold,
    height: 1.3, // Improved readability
    letterSpacing: -0.5,
    color: PadelColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _poppins,
    fontSize: 24, // Reduced from 28
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
    color: PadelColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _poppins,
    fontSize: 20, // Reduced from 24
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: -0.2,
    color: PadelColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _poppins,
    fontSize: 18, // Reduced from 20
    fontWeight: FontWeight.bold,
    height: 1.4,
    color: PadelColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontFamily: _poppins,
    fontSize: 16, // Reduced from 18
    fontWeight: FontWeight.w700, // Increased weight for clarity
    height: 1.5,
    color: PadelColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontFamily: _poppins,
    fontSize: 14, // Reduced from 16
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: PadelColors.textPrimary,
  );

  // READABILITY FIX: Body text with proper line heights
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Changed from normal for consistency
    height: 1.6, // Optimal for reading
    color: PadelColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6, // Improved from 1.5
    color: PadelColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5, // Improved from 1.4
    color: PadelColors.textSecondary,
  );

  // INTERACTION FIX: Labels with proper weights
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: PadelColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: PadelColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _inter,
    fontSize: 11, // Increased from 10 for accessibility
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.2,
    color: PadelColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _inter,
    fontSize: 12, // Increased from 11 for accessibility
    fontWeight: FontWeight.w400,
    height: 1.4, // Improved from 1.3
    color: PadelColors.textSecondary,
  );

  // ACCESSIBILITY: Button text styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );
}

// CONSISTENCY FIX: Standardized spacing scale
class PadelSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
  
  // TOUCH TARGET FIX: Minimum sizes for accessibility
  static const double minTouchTarget = 44.0; // iOS/Android minimum
  static const double buttonHeightSmall = 40.0;
  static const double buttonHeightMedium = 48.0;
  static const double buttonHeightLarge = 56.0;
  
  // CONTENT SPACING: Consistent content margins
  static const double pageHorizontal = 20.0;
  static const double cardPadding = 16.0;
  static const double sectionSpacing = 32.0;
}

// VISUAL CONSISTENCY FIX: Standardized border radius
class PadelRadius {
  static const double sm = 8.0;
  static const double md = 12.0; // Standard for buttons and cards
  static const double lg = 16.0; // Standard for modal containers
  static const double xl = 20.0; // Large cards and sheets
  static const double xxl = 24.0; // Bottom sheets and overlays
  static const double full = 999.0; // Pills and badges
  
  // COMPONENT-SPECIFIC: Clear usage guidelines
  static const double button = md; // 12px
  static const double card = lg; // 16px
  static const double modal = xl; // 20px
  static const double sheet = xxl; // 24px
  static const double input = md; // 12px
  static const double badge = full; // Pill shape
}

// Shadows
class PadelShadows {
  static const BoxShadow sm = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 4,
    offset: Offset(0, 1),
  );

  static const BoxShadow md = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow lg = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow xl = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Enhanced modern shadows
  static List<BoxShadow> get card => [
    BoxShadow(
      color: PadelColors.primary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardHover => [
    BoxShadow(
      color: PadelColors.primary.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get button => [
    BoxShadow(
      color: PadelColors.primary.withOpacity(0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get floating => [
    BoxShadow(
      color: PadelColors.accent.withOpacity(0.3),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: 0,
    ),
  ];
}

// Animations
class PadelAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xpGain = Duration(milliseconds: 800);
  static const Duration rankUp = Duration(milliseconds: 1200);
  static const Duration cardHover = Duration(milliseconds: 150);
  static const Duration buttonPress = Duration(milliseconds: 100);

  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.bounceOut;
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve smoothOut = Curves.easeOutCubic;
  static const Curve spring = Curves.elasticInOut;
  static const Curve buttonCurve = Curves.easeInOutQuart;
}

// Button Styles
enum PadelButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
  accent,
}

enum PadelButtonSize {
  small,
  medium,
  large,
}

class PadelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PadelButtonStyle style;
  final PadelButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const PadelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = PadelButtonStyle.primary,
    this.size = PadelButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  State<PadelButton> createState() => _PadelButtonState();
}

class _PadelButtonState extends State<PadelButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: PadelAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: PadelAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();
    final sizeConfig = _getSizeConfig();

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.isExpanded ? double.infinity : null,
            height: sizeConfig.height,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonConfig.backgroundColor,
                foregroundColor: buttonConfig.foregroundColor,
                side: buttonConfig.borderSide,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PadelRadius.md),
                ),
                elevation: buttonConfig.elevation,
                padding: EdgeInsets.symmetric(
                  horizontal: sizeConfig.horizontalPadding,
                  vertical: sizeConfig.verticalPadding,
                ),
              ),
              child: widget.isLoading
                  ? SizedBox(
                      width: sizeConfig.iconSize,
                      height: sizeConfig.iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          buttonConfig.foregroundColor!,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: sizeConfig.iconSize),
                          SizedBox(width: PadelSpacing.sm),
                        ],
                        Text(
                          widget.text,
                          style: sizeConfig.textStyle.copyWith(
                            color: buttonConfig.foregroundColor,
                            fontWeight: FontWeight.w600,
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

  ButtonConfig _getButtonConfig() {
    switch (widget.style) {
      case PadelButtonStyle.primary:
        return ButtonConfig(
          backgroundColor: PadelColors.primary,
          foregroundColor: PadelColors.textOnPrimary,
          elevation: 2,
        );
      case PadelButtonStyle.secondary:
        return ButtonConfig(
          backgroundColor: PadelColors.secondary,
          foregroundColor: PadelColors.textOnPrimary,
          elevation: 2,
        );
      case PadelButtonStyle.outline:
        return ButtonConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: PadelColors.primary,
          borderSide: BorderSide(color: PadelColors.primary, width: 1.5),
          elevation: 0,
        );
      case PadelButtonStyle.ghost:
        return ButtonConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: PadelColors.primary,
          elevation: 0,
        );
      case PadelButtonStyle.accent:
        return ButtonConfig(
          backgroundColor: PadelColors.accent,
          foregroundColor: PadelColors.textOnAccent,
          elevation: 3,
        );
    }
  }

  SizeConfig _getSizeConfig() {
    switch (widget.size) {
      case PadelButtonSize.small:
        return SizeConfig(
          height: 36,
          horizontalPadding: PadelSpacing.md,
          verticalPadding: PadelSpacing.sm,
          textStyle: PadelTypography.labelMedium,
          iconSize: 16,
        );
      case PadelButtonSize.medium:
        return SizeConfig(
          height: 44,
          horizontalPadding: PadelSpacing.lg,
          verticalPadding: PadelSpacing.md,
          textStyle: PadelTypography.labelLarge,
          iconSize: 18,
        );
      case PadelButtonSize.large:
        return SizeConfig(
          height: 52,
          horizontalPadding: PadelSpacing.xl,
          verticalPadding: PadelSpacing.lg,
          textStyle: PadelTypography.h6,
          iconSize: 20,
        );
    }
  }
}

class ButtonConfig {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderSide? borderSide;
  final double elevation;

  ButtonConfig({
    this.backgroundColor,
    this.foregroundColor,
    this.borderSide,
    this.elevation = 0,
  });
}

class SizeConfig {
  final double height;
  final double horizontalPadding;
  final double verticalPadding;
  final TextStyle textStyle;
  final double iconSize;

  SizeConfig({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.textStyle,
    required this.iconSize,
  });
}

// Input Field Component
class PadelTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool enabled;
  final int? maxLines;

  const PadelTextField({
    super.key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<PadelTextField> createState() => _PadelTextFieldState();
}

class _PadelTextFieldState extends State<PadelTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: PadelTypography.labelMedium.copyWith(
              color: _isFocused ? PadelColors.primary : PadelColors.textSecondary,
            ),
          ),
          SizedBox(height: PadelSpacing.sm),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(PadelRadius.md),
            boxShadow: _isFocused ? [PadelShadows.sm] : null,
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            style: PadelTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: PadelTypography.bodyMedium.copyWith(
                color: PadelColors.grey400,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused ? PadelColors.primary : PadelColors.grey400,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? GestureDetector(
                      onTap: widget.onSuffixTap,
                      child: Icon(
                        widget.suffixIcon,
                        color: _isFocused ? PadelColors.primary : PadelColors.grey400,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: widget.enabled ? PadelColors.white : PadelColors.grey50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PadelRadius.md),
                borderSide: BorderSide(color: PadelColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PadelRadius.md),
                borderSide: BorderSide(color: PadelColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PadelRadius.md),
                borderSide: BorderSide(color: PadelColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(PadelRadius.md),
                borderSide: BorderSide(color: PadelColors.error),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: PadelSpacing.md,
                vertical: PadelSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Smart Accent Text Widget for Automatic Visibility
class PadelAccentText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool isDarkBackground;
  final bool isBold;

  const PadelAccentText(
    this.text, {
    super.key,
    this.style,
    this.isDarkBackground = false,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isDarkBackground 
        ? PadelColors.accent 
        : (isBold ? PadelColors.primary : PadelColors.textSecondary); // Usar cores existentes
        
    return Text(
      text,
      style: (style ?? PadelTypography.bodyMedium).copyWith(
        color: textColor,
      ),
    );
  }
}

// Smart Accent Icon for Automatic Visibility  
class PadelAccentIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final bool isDarkBackground;

  const PadelAccentIcon(
    this.icon, {
    super.key,
    this.size,
    this.isDarkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isDarkBackground 
        ? PadelColors.accent 
        : PadelColors.primary; // Usar cor primária para ícones
        
    return Icon(
      icon,
      color: iconColor,
      size: size,
    );
  }
}