import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// App theme configuration for GoldenHour - High-end 'Royal' Aesthetic
class AppTheme {
  AppTheme._();

  static const double _defaultRadius = 20.0;

  /// Dark theme - The primary 'Royal' look
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.gold,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: _defaultRadius,
        elevatedButtonSchemeColor: SchemeColor.primary,
        elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsBorderSchemeColor: SchemeColor.primary,
        segmentedButtonSchemeColor: SchemeColor.primary,
        segmentedButtonBorderSchemeColor: SchemeColor.primary,
        sliderValueTinted: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBackgroundAlpha: 31,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedBorderWidth: 1.0,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        fabUseShape: true,
        fabAlwaysCircular: true,
        fabSchemeColor: SchemeColor.tertiary,
        cardRadius: _defaultRadius,
        popupMenuRadius: 12.0,
        popupMenuElevation: 8.0,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        appBarScrolledUnderElevation: 4.0,
        drawerElevation: 1.0,
        drawerIndicatorSchemeColor: SchemeColor.primary,
        bottomSheetRadius: _defaultRadius,
        bottomSheetElevation: 10.0,
        bottomSheetModalElevation: 20.0,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationBarElevation: 0.0,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationRailUseIndicator: true,
        navigationRailIndicatorSchemeColor: SchemeColor.primary,
        navigationRailIndicatorOpacity: 1.00,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.manrope().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        displayMedium: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ).copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: const Color(0xFFD4AF37), // Metallic Gold
        ),
      ),
    );
  }

  /// Light theme - Cheerful retro-vintage aesthetic
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: AppColors.retroBurgundy,
        primaryContainer: Color(0xFFFFDAD6),
        secondary: AppColors.cherryRed,
        secondaryContainer: Color(0xFFFFDAD6),
        tertiary: AppColors.fadedDenim,
        tertiaryContainer: Color(0xFFD6E4FF),
        appBarColor: AppColors.creamPaper,
        error: AppColors.cherryRed,
      ),
      scaffoldBackground: AppColors.creamPaper,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 4,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        useTextTheme: true,
        useM2StyleDividerInM3: true,
        defaultRadius: _defaultRadius,
        elevatedButtonSchemeColor: SchemeColor.primary,
        elevatedButtonSecondarySchemeColor: SchemeColor.onPrimary,
        outlinedButtonOutlineSchemeColor: SchemeColor.primary,
        toggleButtonsBorderSchemeColor: SchemeColor.primary,
        segmentedButtonSchemeColor: SchemeColor.primary,
        segmentedButtonBorderSchemeColor: SchemeColor.primary,
        sliderValueTinted: true,
        inputDecoratorSchemeColor: SchemeColor.primary,
        inputDecoratorBackgroundAlpha: 21,
        inputDecoratorUnfocusedHasBorder: false,
        inputDecoratorFocusedBorderWidth: 1.0,
        inputDecoratorPrefixIconSchemeColor: SchemeColor.primary,
        fabUseShape: true,
        fabAlwaysCircular: true,
        fabSchemeColor: SchemeColor.tertiary,
        cardRadius: _defaultRadius,
        popupMenuRadius: 12.0,
        popupMenuElevation: 8.0,
        alignedDropdown: true,
        useInputDecoratorThemeInDialogs: true,
        appBarScrolledUnderElevation: 4.0,
        drawerElevation: 1.0,
        drawerIndicatorSchemeColor: SchemeColor.primary,
        bottomSheetRadius: _defaultRadius,
        bottomSheetElevation: 10.0,
        bottomSheetModalElevation: 20.0,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationBarElevation: 0.0,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailSelectedIconSchemeColor: SchemeColor.onPrimary,
        navigationRailUseIndicator: true,
        navigationRailIndicatorSchemeColor: SchemeColor.primary,
        navigationRailIndicatorOpacity: 1.00,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.manrope().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cinzel(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        displayMedium: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    ).copyWith(
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.creamPaper,
        foregroundColor: AppColors.inkBlack,
        titleTextStyle: GoogleFonts.cinzel(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: AppColors.retroBurgundy,
        ),
      ),
    );
  }
}
