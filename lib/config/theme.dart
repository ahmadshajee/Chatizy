import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chatizy Design System
/// Extracted from the native communication system design spec and HTML mockups.
/// Uses Inter font, M3-inspired color tokens, and warm beige backgrounds.
class ChatizyTheme {
  // ─── Color Tokens ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF0058BC);
  static const Color primaryContainer = Color(0xFF0070EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryFixedDim = Color(0xFFADC6FF);
  static const Color onPrimaryFixed = Color(0xFF001A41);
  static const Color onPrimaryFixedVariant = Color(0xFF004493);
  static const Color inversePrimary = Color(0xFFADC6FF);

  static const Color secondary = Color(0xFF006E28);
  static const Color secondaryContainer = Color(0xFF6FFB85);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF00732A);
  static const Color secondaryFixed = Color(0xFF72FE88);
  static const Color secondaryFixedDim = Color(0xFF53E16F);

  static const Color tertiary = Color(0xFF8A2BB9);
  static const Color tertiaryContainer = Color(0xFFA649D5);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color surface = Color(0xFFF9F6F0); // Warm beige
  static const Color surfaceBright = Color(0xFFFAF9FE);
  static const Color surfaceDim = Color(0xFFDAD9DF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F3F8);
  static const Color surfaceContainer = Color(0xFFEEEDF3);
  static const Color surfaceContainerHigh = Color(0xFFE9E7ED);
  static const Color surfaceContainerHighest = Color(0xFFE3E2E7);
  static const Color onSurface = Color(0xFF1A1B1F);
  static const Color onSurfaceVariant = Color(0xFF414755);
  static const Color inverseSurface = Color(0xFF2F3034);
  static const Color inverseOnSurface = Color(0xFFF1F0F5);
  static const Color surfaceTint = Color(0xFF005BC1);

  static const Color outline = Color(0xFF717786);
  static const Color outlineVariant = Color(0xFFC1C6D7);

  static const Color background = Color(0xFFF9F6F0); // Warm beige
  static const Color onBackground = Color(0xFF1A1B1F);

  // ─── Semantic Colors ────────────────────────────────────────────────
  static const Color onlineGreen = Color(0xFF34C759);
  static const Color starYellow = Color(0xFFFFCC00);
  static const Color privacyGreen = Color(0xFF4CD964);
  static const Color notificationRed = Color(0xFFFF3B30);
  static const Color helpBlue = Color(0xFF007AFF);

  // ─── Spacing ────────────────────────────────────────────────────────
  static const double unit = 8.0;
  static const double stackSm = 4.0;
  static const double stackMd = 12.0;
  static const double stackLg = 24.0;
  static const double marginPage = 16.0;
  static const double gutterBubble = 2.0;

  // ─── Border Radius ─────────────────────────────────────────────────
  static final BorderRadius radiusSm = BorderRadius.circular(4);
  static final BorderRadius radiusMd = BorderRadius.circular(8);
  static final BorderRadius radiusLg = BorderRadius.circular(12);
  static final BorderRadius radiusXl = BorderRadius.circular(16);
  static final BorderRadius radiusXxl = BorderRadius.circular(20);
  static final BorderRadius radiusFull = BorderRadius.circular(9999);

  // ─── Glass Panel Decoration ─────────────────────────────────────────
  static BoxDecoration get glassPanel => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: radiusXl,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get glassPanelRounded => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: radiusLg,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // ─── Theme Data ─────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimary: onPrimary,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        onSecondary: onSecondary,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiary: onTertiary,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        errorContainer: errorContainer,
        onError: onError,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        inverseSurface: inverseSurface,
        onInverseSurface: inverseOnSurface,
        inversePrimary: inversePrimary,
        surfaceTint: surfaceTint,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 41 / 34,
          color: onSurface,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 37 / 30,
          color: onSurface,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 34 / 28,
          color: onSurface,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          height: 28 / 22,
          color: onSurface,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 25 / 20,
          color: onSurface,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          height: 22 / 17,
          color: onSurface,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
          height: 22 / 17,
          color: onSurface,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          height: 21 / 16,
          color: onSurface,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
          height: 18 / 13,
          color: onSurfaceVariant,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 16 / 12,
          color: onSurfaceVariant,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: primary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface.withValues(alpha: 0.8),
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: radiusXxl,
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusXxl,
          borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusXxl,
          borderSide: BorderSide(color: primary.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 17,
          color: outlineVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusXxl),
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outlineVariant.withValues(alpha: 0.5),
        thickness: 0.5,
      ),
    );
  }
}
