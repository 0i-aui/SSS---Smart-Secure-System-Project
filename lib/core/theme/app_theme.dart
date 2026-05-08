// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Background layers
  static const Color bgDeep = Color(0xFF050A0F);
  static const Color bgCard = Color(0xFF0A1520);
  static const Color bgSurface = Color(0xFF0F1E2E);
  static const Color bgElevated = Color(0xFF142436);

  // Neon blue accents
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonBlueDim = Color(0xFF0099BB);
  static const Color neonBlueGlow = Color(0x4000D4FF);
  static const Color accentCyan = Color(0xFF00FFE5);

  // Alert colors
  static const Color alertRed = Color(0xFFFF2D2D);
  static const Color alertRedGlow = Color(0x55FF2D2D);
  static const Color alertOrange = Color(0xFFFF6B00);
  static const Color alertOrangeGlow = Color(0x55FF6B00);

  // Status colors
  static const Color statusGreen = Color(0xFF00FF88);
  static const Color statusGreenGlow = Color(0x4400FF88);
  static const Color statusYellow = Color(0xFFFFD600);

  // Text
  static const Color textPrimary = Color(0xFFE8F4FF);
  static const Color textSecondary = Color(0xFF7BA3C0);
  static const Color textMuted = Color(0xFF3D6A8A);

  // Borders
  static const Color borderSubtle = Color(0xFF1A3550);
  static const Color borderActive = Color(0xFF00D4FF);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonBlue,
        secondary: AppColors.accentCyan,
        surface: AppColors.bgCard,
        error: AppColors.alertRed,
      ),
      textTheme: GoogleFonts.rajdhaniTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
          titleMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          labelSmall: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.rajdhani(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
        ),
        iconTheme: const IconThemeData(color: AppColors.neonBlue),
      ),
      cardTheme: CardTheme(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.neonBlue,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.neonBlue;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.neonBlueGlow;
          }
          return AppColors.bgSurface;
        }),
      ),
    );
  }
}
