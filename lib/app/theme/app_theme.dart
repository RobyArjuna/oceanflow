import 'package:flutter/material.dart';

/// OceanFlow brand color tokens.
/// Designed for a maritime enterprise context: deep ocean blues, steel grays,
/// operational amber warnings, and success greens.
abstract final class OceanColors {
  // === PRIMARY: Deep Ocean ===
  static const primary = Color(0xFF0A84FF);
  static const primaryDark = Color(0xFF0066CC);
  static const primaryLight = Color(0xFF4DA6FF);

  // === SURFACE / BACKGROUND ===
  static const backgroundDark = Color(0xFF0D1117);
  static const surfaceDark = Color(0xFF161B22);
  static const surfaceElevated = Color(0xFF1C2433);
  static const cardDark = Color(0xFF1E2B3C);

  static const backgroundLight = Color(0xFFF4F7FB);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const cardLight = Color(0xFFFFFFFF);

  // === ACCENT ===
  static const teal = Color(0xFF00BCD4);
  static const tealDark = Color(0xFF00838F);

  // === STATUS COLORS ===
  static const pending = Color(0xFF9E9E9E);
  static const loaded = Color(0xFF42A5F5);
  static const atPort = Color(0xFFAB47BC);
  static const sailing = Color(0xFF0A84FF);
  static const arrived = Color(0xFF26C6DA);
  static const delivered = Color(0xFF66BB6A);

  // === SEMANTIC ===
  static const error = Color(0xFFFF453A);
  static const warning = Color(0xFFFF9F0A);
  static const success = Color(0xFF32D74B);
  static const info = Color(0xFF0A84FF);

  // === NEUTRAL ===
  static const grey50 = Color(0xFFF8FAFC);
  static const grey100 = Color(0xFFF1F5F9);
  static const grey200 = Color(0xFFE2E8F0);
  static const grey400 = Color(0xFF94A3B8);
  static const grey600 = Color(0xFF475569);
  static const grey800 = Color(0xFF1E293B);
  static const grey900 = Color(0xFF0F172A);
}

/// Centralized Material 3 theme builder for OceanFlow.
abstract final class AppTheme {
  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: OceanColors.primary,
      onPrimary: Colors.white,
      primaryContainer: OceanColors.primaryDark,
      onPrimaryContainer: Colors.white,
      secondary: OceanColors.teal,
      onSecondary: Colors.white,
      error: OceanColors.error,
      onError: Colors.white,
      surface: OceanColors.surfaceDark,
      onSurface: const Color(0xFFE2E8F0),
      surfaceContainerHighest: OceanColors.cardDark,
      outline: const Color(0xFF2D3748),
      outlineVariant: const Color(0xFF1A2332),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: OceanColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD6EAFF),
      onPrimaryContainer: OceanColors.primaryDark,
      secondary: OceanColors.teal,
      onSecondary: Colors.white,
      error: OceanColors.error,
      onError: Colors.white,
      surface: OceanColors.surfaceLight,
      onSurface: const Color(0xFF1E293B),
      surfaceContainerHighest: OceanColors.grey100,
      outline: OceanColors.grey200,
      outlineVariant: OceanColors.grey100,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? OceanColors.backgroundDark : OceanColors.backgroundLight,

      // Typography
      textTheme: TextTheme(
          displayLarge: TextStyle(
            color: isDark ? Colors.white : OceanColors.grey900,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            color: isDark ? Colors.white : OceanColors.grey900,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            color: isDark ? const Color(0xFFE2E8F0) : OceanColors.grey800,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: isDark ? const Color(0xFFCBD5E1) : OceanColors.grey600,
          ),
          bodyMedium: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : OceanColors.grey600,
            fontSize: 14,
          ),
          labelLarge: TextStyle(
            color: isDark ? Colors.white : OceanColors.grey900,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? OceanColors.surfaceDark : OceanColors.surfaceLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : OceanColors.grey900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFE2E8F0) : OceanColors.grey800,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? OceanColors.cardDark : OceanColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isDark ? const Color(0xFF2D3748) : OceanColors.grey200,
            width: 1,
          ),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? OceanColors.surfaceElevated : OceanColors.grey100,
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? OceanColors.surfaceElevated : OceanColors.grey50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2D3748) : OceanColors.grey200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2D3748) : OceanColors.grey200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: OceanColors.primary,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OceanColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor:
            isDark ? OceanColors.surfaceDark : OceanColors.surfaceLight,
        indicatorColor: OceanColors.primary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: OceanColors.primary, size: 24);
          }
          return IconThemeData(
            color: isDark ? OceanColors.grey400 : OceanColors.grey600,
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? OceanColors.primary
                : (isDark ? OceanColors.grey400 : OceanColors.grey600),
          );
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF2D3748) : OceanColors.grey200,
        thickness: 1,
        space: 1,
      ),

      // FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: OceanColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
    );
  }
}
