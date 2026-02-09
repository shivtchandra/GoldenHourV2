import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';

/// 6-step feature tutorial shown after first login
class FeatureTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const FeatureTutorialOverlay({super.key, required this.onComplete});

  @override
  State<FeatureTutorialOverlay> createState() => _FeatureTutorialOverlayState();

  /// Check if tutorial should be shown
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompletedTutorial = prefs.getBool('has_completed_tutorial') ?? false;
    final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
    return hasCompletedOnboarding && !hasCompletedTutorial;
  }

  /// Mark tutorial as completed
  static Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_tutorial', true);
  }
}

class _FeatureTutorialOverlayState extends State<FeatureTutorialOverlay> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    TutorialStep(
      icon: Icons.camera_rounded,
      title: 'THE CAMERA',
      subtitle: 'CAPTURE',
      description: 'Your main canvas. Tap the hero card to start shooting with your loaded film.',
      tip: 'Switch films to change the look',
    ),
    TutorialStep(
      icon: Icons.auto_awesome_motion_rounded,
      title: 'FILM LENSES',
      subtitle: 'EXPLORE',
      description: 'Your collection of classic film stocks. Each one has a unique character and personality.',
      tip: 'Favorite films appear on your home',
    ),
    TutorialStep(
      icon: Icons.auto_awesome_rounded,
      title: 'PRESETS',
      subtitle: 'ONE-TAP MAGIC',
      description: 'Instant editing styles. 68+ presets from cinematic to vintage, moody to bright.',
      tip: 'Apply presets in-camera or while editing',
    ),
    TutorialStep(
      icon: Icons.auto_fix_high_rounded,
      title: 'DEVELOP',
      subtitle: 'THE DARKROOM',
      description: 'Edit your captures with precision. Adjust exposure, color, grain, and more.',
      tip: 'Your photos are saved to your gallery',
    ),
    TutorialStep(
      icon: Icons.collections_rounded,
      title: 'GALLERY',
      subtitle: 'YOUR MEMORIES',
      description: 'All your captures, organized by film and date. Swipe through your masterpieces.',
      tip: 'Long press to share or delete',
    ),
    TutorialStep(
      icon: Icons.favorite_rounded,
      title: 'FAVORITES',
      subtitle: 'YOUR TOOLKIT',
      description: 'We\'ve added films and presets based on your style. Heart more to build your collection.',
      tip: 'Access favorites from your home screen',
    ),
  ];

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeTutorial();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _completeTutorial() async {
    await FeatureTutorialOverlay.markComplete();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    final step = _steps[_currentStep];

    return Material(
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              // Header with skip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP ${_currentStep + 1} OF ${_steps.length}',
                    style: AppTypography.monoSmall.copyWith(
                      color: tc.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  TextButton(
                    onPressed: _completeTutorial,
                    child: Text(
                      'SKIP',
                      style: AppTypography.labelMedium.copyWith(
                        color: tc.textFaint,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),

              // Progress dots
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  final isActive = index == _currentStep;
                  final isPast = index < _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isActive
                          ? tc.accent
                          : isPast
                              ? tc.accent.withValues(alpha: 0.5)
                              : tc.borderSubtle,
                    ),
                  );
                }),
              ),

              const Spacer(flex: 1),

              // Icon with glow
              FadeIn(
                key: ValueKey(_currentStep),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        tc.accent.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: tc.accent.withValues(alpha: 0.2),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    step.icon,
                    size: 70,
                    color: tc.accent,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Content
              FadeInUp(
                key: ValueKey('title_$_currentStep'),
                child: Text(
                  step.subtitle,
                  style: AppTypography.monoSmall.copyWith(
                    color: tc.accent,
                    letterSpacing: 4,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              FadeInUp(
                key: ValueKey('main_$_currentStep'),
                delay: const Duration(milliseconds: 100),
                child: Text(
                  step.title,
                  style: GoogleFonts.cinzel(
                    fontSize: 32,
                    color: tc.textPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              FadeInUp(
                key: ValueKey('desc_$_currentStep'),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  step.description,
                  style: AppTypography.bodyLarge.copyWith(
                    color: tc.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),

              // Tip box
              FadeInUp(
                key: ValueKey('tip_$_currentStep'),
                delay: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tc.accent.withValues(alpha: 0.3)),
                    color: tc.accent.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: tc.accent, size: 18),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          step.tip,
                          style: AppTypography.bodySmall.copyWith(
                            color: tc.accent,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: _buildSecondaryButton(
                        label: 'BACK',
                        onPressed: _prevStep,
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentStep > 0 ? 2 : 1,
                    child: _buildPrimaryButton(
                      label: _currentStep < _steps.length - 1 ? 'NEXT' : 'START SHOOTING',
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    final tc = context.colors;
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: tc.accent,
          foregroundColor: Colors.black,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 8,
          shadowColor: tc.accent.withValues(alpha: 0.4),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 14,
            letterSpacing: 3,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, VoidCallback? onPressed}) {
    final tc = context.colors;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: tc.borderSubtle),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: tc.textSecondary,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class TutorialStep {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final String tip;

  const TutorialStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tip,
  });
}
