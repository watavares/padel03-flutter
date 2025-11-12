import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🎨 Clean Light Theme for PadelArena App
/// 
/// A comprehensive Material 3 theme focused on:
/// - High readability and accessible contrast
/// - Minimal use of primary color (#31B6F9) for CTAs and selections
/// - Neutral backgrounds with soft greys for text and dividers
/// - Consistent border radius and spacing throughout
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Core color palette
  static const Color _primaryBlue = Color(0xFF31B6F9);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _surfaceGrey = Color(0xFFF7F8FA);
  static const Color _primaryText = Color(0xFF222222);
  static const Color _secondaryText = Color(0xFF666666);
  static const Color _disabledText = Color(0xFF9AA0A6);
  static const Color _outline = Color(0xFFE6E8EB);
  static const Color _success = Color(0xFF10B981);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _error = Color(0xFFEF4444);
  static const Color _chipBackground = Color(0xFFF2F4F7);
  static const Color _tooltipBackground = Color(0xFF222222);

  // Consistent border radius
  static const BorderRadius _defaultRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius _cardRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius _buttonRadius = BorderRadius.all(Radius.circular(14));
  static const BorderRadius _tooltipRadius = BorderRadius.all(Radius.circular(8));

  /// Main light theme for the application
  static ThemeData get lightTheme {
    // Create base color scheme from primary color
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
    ).copyWith(
      // Override specific colors for our clean design
      primary: _primaryBlue,
      onPrimary: _white,
      background: _white,
      onBackground: _primaryText,
      surface: _white,
      onSurface: _primaryText,
      surfaceVariant: _surfaceGrey,
      onSurfaceVariant: _secondaryText,
      outline: _outline,
      error: _error,
      onError: _white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      
      // Typography with improved readability
      textTheme: _buildTextTheme(),
      
      // App Bar Theme - Flat white design
      appBarTheme: const AppBarTheme(
        backgroundColor: _white,
        foregroundColor: _primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _white,
        elevation: 0,
        height: 64,
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(
              color: _primaryBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
          }
          return const TextStyle(
            color: _secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: _primaryBlue, size: 24);
          }
          return const IconThemeData(color: _secondaryText, size: 24);
        }),
        indicatorColor: _primaryBlue.withOpacity(0.1),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _white,
        elevation: 0,
        selectedItemColor: _primaryBlue,
        unselectedItemColor: _secondaryText,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: _white,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: _buttonRadius),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryText,
          backgroundColor: Colors.transparent,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: _buttonRadius),
          side: const BorderSide(color: _outline, width: 1),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          overlayColor: _primaryBlue.withOpacity(0.08),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryBlue,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: const RoundedRectangleBorder(borderRadius: _defaultRadius),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          overlayColor: _primaryBlue.withOpacity(0.1),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: _outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: _outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: _primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: _error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: _defaultRadius,
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        hintStyle: const TextStyle(
          color: _disabledText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: _secondaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: const TextStyle(
          color: _primaryBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: _white,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
        margin: EdgeInsets.zero,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        dense: false,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        subtitleTextStyle: TextStyle(
          color: _secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          color: _disabledText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        iconColor: _disabledText,
        tileColor: Colors.transparent,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _outline,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _chipBackground,
        deleteIconColor: _secondaryText,
        disabledColor: _outline,
        selectedColor: _primaryBlue,
        secondarySelectedColor: _primaryBlue.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: _white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.light,
        shape: const RoundedRectangleBorder(borderRadius: _defaultRadius),
      ),

      // SnackBar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _tooltipBackground,
        contentTextStyle: TextStyle(
          color: _white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        actionTextColor: _primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: _defaultRadius),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: _white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
        titleTextStyle: TextStyle(
          color: _primaryText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        contentTextStyle: TextStyle(
          color: _secondaryText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
      ),

      // Tooltip Theme
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: _tooltipBackground,
          borderRadius: _tooltipRadius,
        ),
        textStyle: TextStyle(
          color: _white,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: EdgeInsets.all(8),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _white;
          }
          return _disabledText;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryBlue;
          }
          return _outline;
        }),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryBlue.withOpacity(0.1);
          }
          return _disabledText.withOpacity(0.1);
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryBlue;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(_white),
        overlayColor: MaterialStateProperty.all(_primaryBlue.withOpacity(0.1)),
        side: const BorderSide(color: _outline, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return _primaryBlue;
          }
          return _outline;
        }),
        overlayColor: MaterialStateProperty.all(_primaryBlue.withOpacity(0.1)),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryBlue,
        foregroundColor: _white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Page Transitions (Material 3 default)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      // Scrollbar Theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(_disabledText.withOpacity(0.3)),
        trackColor: MaterialStateProperty.all(_outline.withOpacity(0.2)),
        radius: const Radius.circular(8),
        thickness: MaterialStateProperty.all(6),
        minThumbLength: 48,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: _primaryBlue,
        unselectedLabelColor: _secondaryText,
        indicatorColor: _primaryBlue,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _disabledText,
        size: 24,
      ),

      primaryIconTheme: const IconThemeData(
        color: _white,
        size: 24,
      ),

      // Splash and highlight colors
      splashColor: _primaryBlue.withOpacity(0.1),
      highlightColor: _primaryBlue.withOpacity(0.05),
      hoverColor: _primaryBlue.withOpacity(0.04),
      focusColor: _primaryBlue.withOpacity(0.1),
    );
  }

  /// Custom text theme with improved readability
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Display styles (largest)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: _primaryText,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _primaryText,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _primaryText,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _primaryText,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _primaryText,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _primaryText,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: _primaryText,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: _primaryText,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _primaryText,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _primaryText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: _primaryText,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: _secondaryText,
      ),

      // Label styles (buttons, chips, etc.)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _primaryText,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _primaryText,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _primaryText,
      ),
    );
  }

  /// Semantic colors for specific use cases
  static const Color successColor = _success;
  static const Color warningColor = _warning;
  static const Color errorColor = _error;
  static const Color primaryColor = _primaryBlue;
  static const Color backgroundWhite = _white;
  static const Color surfaceGrey = _surfaceGrey;
  static const Color textPrimary = _primaryText;
  static const Color textSecondary = _secondaryText;
  static const Color textDisabled = _disabledText;
  static const Color borderOutline = _outline;
}