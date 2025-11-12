import 'package:flutter/material.dart';

/// App Color Palette
class AppColors {
  // Primary Blue Palette
  static const Color deepBlue = Color(0xFF0B2A4A);
  static const Color primaryBlue = Color(0xFF0A84FF);
  static const Color skyBlue = Color(0xFF77B3FF);
  
  // Accent Colors (used sparingly)
  static const Color lime = Color(0xFFC6FF00);
  static const Color supportYellow = Color(0xFF5D7A0B);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
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
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = primaryBlue;
  
  // Text Colors
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey600;
  static const Color textTertiary = grey400;
  static const Color textOnPrimary = white;
  static const Color textOnAccent = deepBlue;
}

/// App Spacing System
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 64.0;
}

/// App Border Radius System
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double round = 100.0;
}

/// App Shadow System
class AppShadows {
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4.0,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16.0,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x1A0A84FF),
      blurRadius: 8.0,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12.0,
      offset: Offset(0, 6),
    ),
  ];
}

/// App Typography System
class AppTypography {
  static const String fontFamily = 'SF Pro Display';
  
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
    height: 1.35,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
    height: 1.45,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.25,
  );
  
  // Buttons
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.25,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.25,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.3,
  );
}

/// App Animation Durations
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Duration pageTransition = Duration(milliseconds: 250);
}

/// Main App Theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        secondary: AppColors.lime,
        tertiary: AppColors.skyBlue,
        surface: AppColors.white,
        background: AppColors.grey50,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnAccent,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.h5,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        shadowColor: AppColors.grey900.withOpacity(0.1),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.grey200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        labelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          side: const BorderSide(color: AppColors.primaryBlue),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.buttonMedium,
        ),
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        elevation: 8,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.grey200,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: AppColors.grey50,
    );
  }
}