import 'package:flutter/material.dart';

/// Senior-accessibility design tokens for SunSafe Check-In.
///
/// All senior-facing surfaces must meet WCAG AA contrast (4.5:1 minimum)
/// and use touch targets of at least [kSeniorMinTouchTarget] logical pixels.
class AppColors {
  AppColors._();

  // High-contrast senior palette (tested ≥ 4.5:1 on white / dark backgrounds)
  static const Color seniorBackground = Color(0xFF0D1117);
  static const Color seniorSurface = Color(0xFF1A2332);
  static const Color seniorPrimary = Color(0xFFFFD54F); // warm sun yellow
  static const Color seniorOnPrimary = Color(0xFF1A1200);
  static const Color seniorSuccess = Color(0xFF4CAF50);
  static const Color seniorOnSuccess = Color(0xFF0A1F0A);
  static const Color seniorError = Color(0xFFFF5252);
  static const Color seniorOnError = Color(0xFF1A0000);
  static const Color seniorTextPrimary = Color(0xFFFFFFFF);
  static const Color seniorTextSecondary = Color(0xFFB0BEC5);

  // Caregiver palette — still accessible, slightly denser information density
  static const Color caregiverBackground = Color(0xFFF5F7FA);
  static const Color caregiverSurface = Color(0xFFFFFFFF);
  static const Color caregiverPrimary = Color(0xFF1565C0);
  static const Color caregiverOnPrimary = Color(0xFFFFFFFF);
  static const Color caregiverAccent = Color(0xFFFF8F00);
  static const Color caregiverTextPrimary = Color(0xFF1A1A2E);
  static const Color caregiverTextSecondary = Color(0xFF546E7A);
}

/// Minimum tap target for senior-facing controls (72 × 72 logical px).
const double kSeniorMinTouchTarget = 72.0;

/// Minimum body font size on senior screens (22 pt).
const double kSeniorMinFontSize = 22.0;

/// Minimum headline font size on senior screens (28 pt).
const double kSeniorHeadlineFontSize = 28.0;

/// Primary check-in button height — extra large for easy targeting.
const double kSeniorCheckInButtonHeight = 120.0;

class AppTheme {
  AppTheme._();

  /// Builds the high-contrast theme used on Senior screens.
  static ThemeData seniorTheme({TextScaler? textScaler}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.seniorBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.seniorPrimary,
        onPrimary: AppColors.seniorOnPrimary,
        secondary: AppColors.seniorSuccess,
        onSecondary: AppColors.seniorOnSuccess,
        error: AppColors.seniorError,
        onError: AppColors.seniorOnError,
        surface: AppColors.seniorSurface,
        onSurface: AppColors.seniorTextPrimary,
      ),
    );

    return base.copyWith(
      textTheme: _seniorTextTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, kSeniorCheckInButtonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          textStyle: const TextStyle(
            fontSize: kSeniorHeadlineFontSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(kSeniorMinTouchTarget, kSeniorMinTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(
            fontSize: kSeniorMinFontSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(kSeniorMinTouchTarget, kSeniorMinTouchTarget),
          iconSize: 36,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.seniorSurface,
        foregroundColor: AppColors.seniorTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: kSeniorHeadlineFontSize,
          fontWeight: FontWeight.w800,
          color: AppColors.seniorTextPrimary,
        ),
      ),
    );
  }

  /// Builds the caregiver dashboard theme.
  static ThemeData caregiverTheme({TextScaler? textScaler}) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.caregiverBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.caregiverPrimary,
        onPrimary: AppColors.caregiverOnPrimary,
        secondary: AppColors.caregiverAccent,
        surface: AppColors.caregiverSurface,
        onSurface: AppColors.caregiverTextPrimary,
      ),
    );

    return base.copyWith(
      textTheme: _caregiverTextTheme(base.textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.caregiverSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static TextTheme _seniorTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        color: AppColors.seniorTextPrimary,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.seniorTextPrimary,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: kSeniorHeadlineFontSize,
        fontWeight: FontWeight.w800,
        color: AppColors.seniorTextPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.seniorTextPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: kSeniorMinFontSize,
        fontWeight: FontWeight.w600,
        color: AppColors.seniorTextPrimary,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: kSeniorMinFontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.seniorTextSecondary,
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: kSeniorMinFontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.seniorTextPrimary,
      ),
    );
  }

  static TextTheme _caregiverTextTheme(TextTheme base) {
    return base.copyWith(
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.caregiverTextPrimary,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.caregiverTextPrimary,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        color: AppColors.caregiverTextPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        color: AppColors.caregiverTextSecondary,
      ),
    );
  }
}

/// Wraps a subtree with a clamped [MediaQuery.textScaler] so system font
/// scaling never shrinks senior text below readable sizes.
class SeniorAccessibleScope extends StatelessWidget {
  const SeniorAccessibleScope({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 2.0,
  });

  final Widget child;
  final double minScale;
  final double maxScale;

  @override
  Widget build(BuildContext context) {
    final currentScaler = MediaQuery.textScalerOf(context);
    final clampedScaler = currentScaler.clamp(
      minScaleFactor: minScale,
      maxScaleFactor: maxScale,
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: clampedScaler),
      child: child,
    );
  }
}
