import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_system.dart';

// ACCESSIBILITY FIX: Comprehensive theme system with dark mode support
class PadelTheme {
  
  // LIGHT THEME - Primary app theme
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // COLOR SCHEME: Proper Material 3 integration com cores originais
    colorScheme: const ColorScheme.light(
      primary: PadelColors.primary,
      primaryContainer: PadelColors.primaryLight,
      secondary: PadelColors.secondary,
      secondaryContainer: PadelColors.secondaryLight,
      tertiary: PadelColors.accent, // Usar accent original vibrante
      tertiaryContainer: PadelColors.accentLight,
      surface: PadelColors.surface,
      surfaceVariant: PadelColors.surfaceVariant,
      background: PadelColors.background,
      error: PadelColors.error,
      onPrimary: PadelColors.textOnPrimary,
      onSecondary: PadelColors.textOnPrimary,
      onTertiary: PadelColors.textOnAccent, // Preto sobre lime
      onSurface: PadelColors.textPrimary,
      onBackground: PadelColors.textPrimary,
      onError: PadelColors.white,
      outline: PadelColors.grey300,
      outlineVariant: PadelColors.grey200,
    ),
    
    // TYPOGRAPHY: Consistent font system
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      displayLarge: PadelTypography.h1,
      displayMedium: PadelTypography.h2,
      displaySmall: PadelTypography.h3,
      headlineLarge: PadelTypography.h4,
      headlineMedium: PadelTypography.h5,
      headlineSmall: PadelTypography.h6,
      titleLarge: PadelTypography.h5,
      titleMedium: PadelTypography.h6,
      titleSmall: PadelTypography.labelLarge,
      bodyLarge: PadelTypography.bodyLarge,
      bodyMedium: PadelTypography.bodyMedium,
      bodySmall: PadelTypography.bodySmall,
      labelLarge: PadelTypography.labelLarge,
      labelMedium: PadelTypography.labelMedium,
      labelSmall: PadelTypography.labelSmall,
    ),
    
    // APP BAR: Consistent header styling
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: PadelTypography.h5,
      foregroundColor: PadelColors.textPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
    // BUTTONS: Standardized with proper touch targets
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PadelColors.primary,
        foregroundColor: PadelColors.textOnPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PadelRadius.button),
        ),
        minimumSize: const Size(0, PadelSpacing.buttonHeightMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: PadelSpacing.md,
          vertical: PadelSpacing.sm,
        ),
        textStyle: PadelTypography.buttonMedium,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: PadelColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PadelRadius.button),
        ),
        minimumSize: const Size(0, PadelSpacing.buttonHeightMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: PadelSpacing.md,
          vertical: PadelSpacing.sm,
        ),
        textStyle: PadelTypography.buttonMedium,
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PadelColors.primary,
        side: const BorderSide(color: PadelColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PadelRadius.button),
        ),
        minimumSize: const Size(0, PadelSpacing.buttonHeightMedium),
        padding: const EdgeInsets.symmetric(
          horizontal: PadelSpacing.md,
          vertical: PadelSpacing.sm,
        ),
        textStyle: PadelTypography.buttonMedium,
      ),
    ),
    
    // CARDS: Consistent elevation and styling
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PadelRadius.card),
      ),
      clipBehavior: Clip.antiAlias,
      color: PadelColors.surface,
    ),
    
    // INPUT FIELDS: Proper styling and accessibility
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PadelColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PadelRadius.input),
        borderSide: const BorderSide(color: PadelColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PadelRadius.input),
        borderSide: const BorderSide(color: PadelColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PadelRadius.input),
        borderSide: const BorderSide(color: PadelColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(PadelRadius.input),
        borderSide: const BorderSide(color: PadelColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: PadelSpacing.md,
        vertical: PadelSpacing.md,
      ),
      labelStyle: PadelTypography.bodyMedium,
      hintStyle: PadelTypography.bodyMedium.copyWith(
        color: PadelColors.textTertiary,
      ),
    ),
    
    // FLOATING ACTION BUTTON: Consistent with brand
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PadelColors.primary,
      foregroundColor: PadelColors.textOnPrimary,
      elevation: 8,
      shape: CircleBorder(),
    ),
    
    // NAVIGATION: Bottom nav styling
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: PadelColors.surface,
      selectedItemColor: PadelColors.primary,
      unselectedItemColor: PadelColors.textTertiary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: PadelTypography.labelSmall,
      unselectedLabelStyle: PadelTypography.labelSmall,
    ),
    
    // CHIPS: Filter and choice chips
    chipTheme: ChipThemeData(
      backgroundColor: PadelColors.surfaceVariant,
      selectedColor: PadelColors.primary,
      labelStyle: PadelTypography.labelMedium,
      padding: const EdgeInsets.symmetric(
        horizontal: PadelSpacing.sm,
        vertical: PadelSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PadelRadius.badge),
      ),
    ),
    
    // DIVIDERS: Subtle separation
    dividerTheme: const DividerThemeData(
      color: PadelColors.grey200,
      thickness: 1,
      space: 1,
    ),
  );
  
  // DARK THEME - Enhanced accessibility for night usage
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: const ColorScheme.dark(
      primary: PadelColors.secondaryLight,
      primaryContainer: PadelColors.primaryDark,
      secondary: PadelColors.accent,
      secondaryContainer: PadelColors.accentDark,
      tertiary: PadelColors.accent,
      tertiaryContainer: PadelColors.accentDark, // Usar accentDark que existe
      surface: Color(0xFF121212),
      surfaceVariant: Color(0xFF1E1E1E),
      background: Color(0xFF000000),
      error: Color(0xFFCF6679),
      onPrimary: PadelColors.textOnPrimary,
      onSecondary: PadelColors.black, // Preto sobre accent
      onTertiary: PadelColors.black, // Preto sobre accent
      onSurface: Color(0xFFE1E1E1),
      onBackground: Color(0xFFE1E1E1),
      onError: Color(0xFF000000),
      outline: Color(0xFF404040),
      outlineVariant: Color(0xFF2A2A2A),
    ),
    
    fontFamily: 'Inter',
    textTheme: TextTheme(
      displayLarge: PadelTypography.h1.copyWith(color: const Color(0xFFE1E1E1)),
      displayMedium: PadelTypography.h2.copyWith(color: const Color(0xFFE1E1E1)),
      displaySmall: PadelTypography.h3.copyWith(color: const Color(0xFFE1E1E1)),
      headlineLarge: PadelTypography.h4.copyWith(color: const Color(0xFFE1E1E1)),
      headlineMedium: PadelTypography.h5.copyWith(color: const Color(0xFFE1E1E1)),
      headlineSmall: PadelTypography.h6.copyWith(color: const Color(0xFFE1E1E1)),
      titleLarge: PadelTypography.h5.copyWith(color: const Color(0xFFE1E1E1)),
      titleMedium: PadelTypography.h6.copyWith(color: const Color(0xFFE1E1E1)),
      titleSmall: PadelTypography.labelLarge.copyWith(color: const Color(0xFFE1E1E1)),
      bodyLarge: PadelTypography.bodyLarge.copyWith(color: const Color(0xFFE1E1E1)),
      bodyMedium: PadelTypography.bodyMedium.copyWith(color: const Color(0xFFE1E1E1)),
      bodySmall: PadelTypography.bodySmall.copyWith(color: const Color(0xFF9E9E9E)),
      labelLarge: PadelTypography.labelLarge.copyWith(color: const Color(0xFFE1E1E1)),
      labelMedium: PadelTypography.labelMedium.copyWith(color: const Color(0xFFE1E1E1)),
      labelSmall: PadelTypography.labelSmall.copyWith(color: const Color(0xFF9E9E9E)),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFFE1E1E1),
      ),
      foregroundColor: Color(0xFFE1E1E1),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
  );
  
  // MOTION: Consistent animation curves and durations
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;
}

// ACCESSIBILITY: Helper extension for responsive text
extension ResponsiveText on TextStyle {
  TextStyle responsive(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.4);
    
    return copyWith(
      fontSize: (fontSize ?? 14) * scaleFactor,
      height: height != null ? height! / scaleFactor : null,
    );
  }
}

// CONTRAST: Helper methods for dynamic color selection
extension AdaptiveColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  Color get adaptiveAccent => PadelColors.accent; // Sempre usar a cor original vibrante
    
  Color get adaptiveAccentText => isDarkMode 
    ? PadelColors.accent 
    : PadelColors.primary; // Usar primary para contraste em modo claro
}