import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Chatizy Design System - Apple Glass UI Edition
/// visionOS-inspired color tokens, glass decorations, and transparent scaffolds.
class ChatizyTheme {
  // ─── Color Tokens ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A84FF); // Apple Vibrant Blue
  static const Color primaryContainer = Color(0xFF007AFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFF1C1C1E);
  static const Color primaryFixedDim = Color(0xFF2C2C2E);
  static const Color onPrimaryFixed = Color(0xFFFFFFFF);
  static const Color onPrimaryFixedVariant = Color(0xFFE5E5EA);
  static const Color inversePrimary = Color(0xFF0A84FF);

  static const Color secondary = Color(0xFF30D158); // Apple Neon Green
  static const Color secondaryContainer = Color(0xFF248A3D);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFFFFFFFF);
  static const Color secondaryFixed = Color(0xFF2C2C2E);
  static const Color secondaryFixedDim = Color(0xFF1C1C1E);

  static const Color tertiary = Color(0xFFBF5AF2); // Apple Neon Purple
  static const Color tertiaryContainer = Color(0xFF8E24AA);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFFF453A); // Apple Neon Red
  static const Color errorContainer = Color(0xFF4A1612);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFFFF453A);

  static const Color surface = Color(0x1A000000); // Very transparent black
  static const Color surfaceBright = Color(0x33FFFFFF); // Frosted highlight
  static const Color surfaceDim = Color(0x1F000000);
  static const Color surfaceContainerLowest = Color(0x0DFFFFFF); // Extremely translucent
  static const Color surfaceContainerLow = Color(0x14FFFFFF);
  static const Color surfaceContainer = Color(0x1AFFFFFF);
  static const Color surfaceContainerHigh = Color(0x26FFFFFF);
  static const Color surfaceContainerHighest = Color(0x33FFFFFF);
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFE5E5EA);
  static const Color inverseSurface = Color(0xFFFFFFFF);
  static const Color inverseOnSurface = Color(0xFF1C1C1E);
  static const Color surfaceTint = Color(0xFF0A84FF);

  static const Color outline = Color(0x4DFFFFFF); // Translucent white border
  static const Color outlineVariant = Color(0x33FFFFFF);

  static const Color background = Colors.transparent; // Transparent for mesh gradient
  static const Color onBackground = Color(0xFFFFFFFF);

  // ─── Semantic Colors ────────────────────────────────────────────────
  static const Color onlineGreen = Color(0xFF30D158);
  static const Color starYellow = Color(0xFFFFD60A);
  static const Color privacyGreen = Color(0xFF34C759);
  static const Color notificationRed = Color(0xFFFF453A);
  static const Color helpBlue = Color(0xFF0A84FF);

  // ─── Spacing ────────────────────────────────────────────────────────
  static const double unit = 8.0;
  static const double stackSm = 4.0;
  static const double stackMd = 12.0;
  static const double stackLg = 24.0;
  static const double marginPage = 16.0;
  static const double gutterBubble = 2.0;

  // ─── Border Radius ─────────────────────────────────────────────────
  static final BorderRadius radiusSm = BorderRadius.circular(6);
  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusLg = BorderRadius.circular(16);
  static final BorderRadius radiusXl = BorderRadius.circular(20);
  static final BorderRadius radiusXxl = BorderRadius.circular(24);
  static final BorderRadius radiusFull = BorderRadius.circular(9999);

  // ─── Glass Panel Decoration ─────────────────────────────────────────
  static BoxDecoration get glassPanel => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: radiusXl,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get glassPanelRounded => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: radiusLg,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ─── Theme Data ─────────────────────────────────────────────────────
  /// The existing dark/glass theme – renamed for clarity.
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.dark(
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
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: Colors.white,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: Colors.white,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.3,
          color: Colors.white,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.2,
          color: Colors.white.withValues(alpha: 0.85),
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.1,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black.withValues(alpha: 0.15),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.12),
        thickness: 0.5,
      ),
    );
  }

  // ── Keep the old getter name so existing code compiles ──
  static ThemeData get lightTheme => darkTheme;

  // ─── Light Theme ────────────────────────────────────────────────────
  // Clean, airy, Apple-inspired light appearance.
  static const Color _lightSurface = Color(0xFFF2F2F7);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF1C1C1E);
  static const Color _lightSecondaryText = Color(0xFF636366);
  static const Color _lightTertiaryText = Color(0xFF8E8E93);
  static const Color _lightSeparator = Color(0xFFD1D1D6);

  static ThemeData get actualLightTheme {
    final textTheme =
        GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: Color(0xFFD0E4FF),
        onPrimary: Colors.white,
        onPrimaryContainer: Color(0xFF001D36),
        secondary: secondary,
        secondaryContainer: Color(0xFFC8F5D0),
        onSecondary: Colors.white,
        onSecondaryContainer: Color(0xFF002106),
        tertiary: tertiary,
        tertiaryContainer: Color(0xFFF2DAFF),
        onTertiary: Colors.white,
        onTertiaryContainer: Color(0xFF29003F),
        error: error,
        errorContainer: Color(0xFFFFDAD6),
        onError: Colors.white,
        onErrorContainer: Color(0xFF410002),
        surface: _lightSurface,
        onSurface: _lightText,
        onSurfaceVariant: _lightSecondaryText,
        outline: _lightSeparator,
        outlineVariant: Color(0xFFE5E5EA),
        inverseSurface: Color(0xFF1C1C1E),
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFF82B1FF),
        surfaceTint: primary,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5,
          color: _lightText,
        ),
        displayMedium: textTheme.displayMedium?.copyWith(
          fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5,
          color: _lightText,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5,
          color: _lightText,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.4,
          color: _lightText,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4,
          color: _lightText,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3,
          color: _lightText,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: -0.3,
          color: _lightText,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: -0.2,
          color: _lightSecondaryText,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: 13, fontWeight: FontWeight.w400, letterSpacing: -0.1,
          color: _lightTertiaryText,
        ),
        labelSmall: textTheme.labelSmall?.copyWith(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0,
          color: _lightTertiaryText,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightCard.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: _lightText,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightCard.withValues(alpha: 0.9),
        selectedItemColor: primary,
        unselectedItemColor: _lightTertiaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11, fontWeight: FontWeight.w400,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightCard,
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: _lightSeparator),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: _lightSeparator),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: _lightTertiaryText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radiusXl,
          side: BorderSide(color: _lightSeparator.withValues(alpha: 0.3)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: _lightSeparator,
        thickness: 0.5,
      ),
    );
  }
}
