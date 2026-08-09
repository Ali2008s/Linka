import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0F0F12);
  static const Color surfaceDark = Color(0xFF17171C);
  static const Color cardFill = Color(0xFF141417);
  static const Color cardBorder = Color(0xFF26262C);
  static const Color cardBorderFocused = Color(0xFFE11D74);
  
  static const Color primaryOrange = Color(0xFFE11D74);
  static const Color primaryOrangeHover = Color(0xFFF43F5E);
  
  static const Color buttonDark = Color(0xFF1C1C22);
  static const Color buttonDarkBorder = Color(0xFF282830);
  
  static const Color buttonDisabled = Color(0xFF1A1A20);
  static const Color textDisabled = Color(0xFF52525C);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94949E);
  static const Color textMuted = Color(0xFF62626C);
  
  static const Color focusBlue = Color(0xFF1B73E8);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE11D74), Color(0xFFF43F5E)],
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1C1C22), Color(0xFF141417)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Box shadows
  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: const Color(0xFFE11D74).withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get inputFocusGlow => [
        BoxShadow(
          color: const Color(0xFFE11D74).withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 0),
        ),
      ];
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryOrange,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    );
  }
}
