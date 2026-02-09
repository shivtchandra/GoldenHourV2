import 'package:flutter/material.dart';

/// App color palette for GoldenHour - Retro-Modern Film Photography Studio
class AppColors {
  AppColors._();

  // Retro Vibe Theme
  static const Color creamPaper = Color(0xFFF9F5F0); // Main background
  static const Color antiqueWhite = Color(0xFFF0EAD6);
  
  static const Color retroBurgundy = Color(0xFF800020); // Accent 1 (Icons, Buttons)
  static const Color cherryRed = Color(0xFFD9381E); // Accent 2 (Stickers)
  static const Color fadedDenim = Color(0xFF5B9BD5); // Accent 3
  static const Color retroTeal = Color(0xFF008080);
  
  static const Color inkBlack = Color(0xFF2A2A2A); // Text
  static const Color charcoal = Color(0xFF36454F);

  // Legacy/Mapped Aliases
  static const Color primaryBlack = inkBlack;
  static const Color warmGold = retroBurgundy; // Mapping gold -> burgundy for primary actions
  static const Color darkroom = inkBlack;
  static const Color cardBackground = Colors.white; // Stickers are white
  static const Color divider = Color(0xFFE0E0E0);
  static const Color textPrimary = inkBlack;
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = cherryRed;
  
  static const Color cardBackgroundLight = Colors.white;
  static const Color textPrimaryDark = inkBlack;
  static const Color accentFilmRed = cherryRed;
  static const Color accentGold = Color(0xFFD4AF37); // Royal Gold
  static const Color gold = accentGold;

  // Gradients
  static const Gradient retroPaperGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [creamPaper, antiqueWhite],
  );

  static const Gradient darkroomGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [creamPaper, antiqueWhite],
  );
}
