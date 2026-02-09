import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'colors.dart';

/// Semantic color resolution based on current theme brightness.
/// Usage: `context.colors.accent`, `context.colors.scaffoldBackground`, etc.
extension ThemeColorsExtension on BuildContext {
  ThemeColors get colors => ThemeColors(Theme.of(this).brightness);
}

class ThemeColors {
  final Brightness brightness;
  const ThemeColors(this.brightness);

  bool get isDark => brightness == Brightness.dark;

  // ── Scaffold / Backgrounds ──
  Color get scaffoldBackground =>
      isDark ? Colors.black : AppColors.creamPaper;
  Color get surfaceColor =>
      isDark ? const Color(0xFF0F0F0F) : Colors.white;
  Color get cardSurface =>
      isDark ? Colors.grey.shade900 : Colors.white;
  Color get dialogBackground =>
      isDark ? Colors.grey.shade900 : Colors.white;

  // ── Primary Accent ──
  Color get accent =>
      isDark ? AppColors.accentGold : AppColors.retroBurgundy;
  Color get accentSecondary =>
      isDark ? AppColors.accentGold.withOpacity(0.6) : AppColors.cherryRed;
  Color get accentMuted =>
      isDark ? AppColors.accentGold.withOpacity(0.5) : AppColors.retroBurgundy.withOpacity(0.5);
  Color get accentSubtle =>
      isDark ? AppColors.accentGold.withOpacity(0.05) : AppColors.retroBurgundy.withOpacity(0.06);

  // ── Text Hierarchy ──
  Color get textPrimary =>
      isDark ? Colors.white : AppColors.inkBlack;
  Color get textSecondary =>
      isDark ? Colors.white70 : AppColors.charcoal;
  Color get textTertiary =>
      isDark ? Colors.white54 : const Color(0xFF757575);
  Color get textMuted =>
      isDark ? Colors.white38 : const Color(0xFF9E9E9E);
  Color get textFaint =>
      isDark ? Colors.white24 : const Color(0xFFBDBDBD);
  Color get textGhost =>
      isDark ? Colors.white10 : const Color(0xFFE0E0E0);

  // ── Icons ──
  Color get iconPrimary =>
      isDark ? Colors.white : AppColors.inkBlack;
  Color get iconSecondary =>
      isDark ? Colors.white70 : AppColors.charcoal;
  Color get iconMuted =>
      isDark ? Colors.white60 : const Color(0xFF9E9E9E);
  Color get iconFaint =>
      isDark ? Colors.white38 : const Color(0xFFBDBDBD);

  // ── Borders / Dividers ──
  Color get borderSubtle =>
      isDark ? Colors.white10 : const Color(0xFFE0E0E0);
  Color get borderMuted =>
      isDark ? Colors.white24 : const Color(0xFFD0D0D0);
  Color get borderAccent =>
      isDark ? AppColors.accentGold.withOpacity(0.3) : AppColors.retroBurgundy.withOpacity(0.3);

  // ── Glass / Overlay Effects ──
  Color get glassBackground =>
      isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7);
  Color get glassBorder =>
      isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE0E0E0);
  Color get overlayDark =>
      isDark ? Colors.black54 : Colors.black26;
  Color get overlayLight =>
      isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.03);

  // ── Status Colors ──
  Color get favorite => Colors.redAccent;
  Color get success =>
      isDark ? Colors.greenAccent : const Color(0xFF2E7D32);
  Color get error => AppColors.cherryRed;

  // ── PRO Badge (gold in both themes) ──
  Color get proBadgeBackground => AppColors.accentGold;
  Color get proBadgeText => Colors.black;

  // ── Bottom Sheet / Dialog Gradients ──
  Color get sheetGradientStart =>
      isDark ? Colors.black : AppColors.creamPaper;
  Color get sheetGradientEnd =>
      isDark ? Colors.grey.shade900 : AppColors.antiqueWhite;

  // ── Shimmer / Loading ──
  Color get shimmerBase =>
      isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.04);
  Color get shimmerHighlight =>
      isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.08);

  // ── Background Gradient ──
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [const Color(0xFF0F0F0F), Colors.black]
            : [AppColors.creamPaper, AppColors.antiqueWhite],
      );
}

/// Adaptive glass container that works on both light and dark backgrounds.
/// Dark mode: frosted glass via glass_kit.
/// Light mode: solid white card with subtle shadow.
class AdaptiveGlass extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const AdaptiveGlass({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.borderWidth = 1,
    this.borderColor,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (colors.isDark) {
      return GlassContainer.clearGlass(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        borderColor: borderColor ?? Colors.transparent,
        padding: padding,
        margin: margin,
        child: child,
      );
    }
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? const Color(0xFFE8E3DA),
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
