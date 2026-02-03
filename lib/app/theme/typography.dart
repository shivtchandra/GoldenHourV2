import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Golden Hour Typography System
/// Primary: Warbler Deck (or Serif alternative like DM Serif Display)
/// Secondary: DM Sans
/// Accent: Cutive Mono or JetBrains Mono
class AppTypography {
  AppTypography._();

  // --- HEADLINES (Chunky Serif) ---
  
  // Dramatic Greeting, Hero Text
  static TextStyle get displayLarge => GoogleFonts.cinzel(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        height: 1.1,
      );

  // Screen Titles (Home, Gallery)
  static TextStyle get displayMedium => GoogleFonts.cinzel(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      );

  // Section Headers
  static TextStyle get headlineLarge => GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headlineMedium => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      );

  // --- BODY (Clean Sans for premium readability) ---

  // Standard Body Text
  static TextStyle get bodyLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      );

  // --- LABELS & BUTTONS ---

  static TextStyle get labelLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.0,
      );

  static TextStyle get labelMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      );

  // --- ACCENT / ELEGANT ---

  static TextStyle get scriptLarge => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        color: AppColors.retroBurgundy,
        height: 1.2,
      );

  static TextStyle get scriptMedium => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        color: AppColors.retroBurgundy,
      );

  // Technical info
  static TextStyle get monoMedium => GoogleFonts.spaceMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.retroBurgundy,
      );
      
  static TextStyle get monoSmall => GoogleFonts.spaceMono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.retroBurgundy,
      );
      
  // COMPATIBILITY
  static TextStyle get displaySmall => GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      );
  
  static TextStyle get labelSmall => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      );
}
