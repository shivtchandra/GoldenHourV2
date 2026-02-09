import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../camera/data/repositories/camera_repository.dart';
import '../../../camera/providers/settings_provider.dart';
import '../../../user/providers/user_profile_provider.dart';
import '../../../user/data/models/user_profile.dart';
import '../../../user/data/models/toolkit_item.dart';
import '../../../presets/data/repositories/preset_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  final bool showSkipToLogin;

  const OnboardingScreen({super.key, this.showSkipToLogin = false});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _grainController;

  // Total pages: Welcome, Why Film, Era, Subjects, Workflow, Format, Toolkit, Ready
  static const int _totalPages = 8;

  @override
  void initState() {
    super.initState();
    _grainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _grainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      body: Stack(
        children: [
          // Animated film grain overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _grainController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FilmGrainPainter(
                    opacity: 0.03,
                    seed: DateTime.now().millisecondsSinceEpoch,
                  ),
                );
              },
            ),
          ),

          // Background Glows - Darkroom aesthetic
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF3333).withValues(alpha: 0.08), // Red safelight
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.retroBurgundy.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Page Content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(), // Controlled navigation
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildWelcomePage(),        // 0: Cinematic intro
              _buildWhyFilmPage(),        // 1: Emotional connection
              _buildEraPage(),            // 2: Aesthetic era
              _buildSubjectsPage(),       // 3: What do you shoot
              _buildWorkflowPage(),       // 4: How you work
              _buildFormatPage(),         // 5: Aspect ratio
              _buildToolkitPage(),        // 6: Recommended films
              _buildReadyPage(),          // 7: Launch
            ],
          ),

          // Progress indicator
          if (_currentPage > 0 && _currentPage < _totalPages - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: _buildProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final tc = context.colors;
    // Exclude welcome and ready pages from progress
    final progress = (_currentPage) / (_totalPages - 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalPages - 2, (index) {
              final isActive = index < _currentPage;
              final isCurrent = index == _currentPage - 1;
              return Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    color: isCurrent
                        ? tc.accent
                        : isActive
                            ? tc.accent.withValues(alpha: 0.5)
                            : tc.borderSubtle,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PAGE 0: WELCOME - THE DARKROOM AWAITS
  // ============================================
  Widget _buildWelcomePage() {
    final tc = context.colors;
    return FadeIn(
      duration: const Duration(seconds: 2),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Darkroom glow animation
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF3333).withValues(alpha: 0.3),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: AdaptiveGlass(
                  width: 160,
                  height: 160,
                  borderRadius: BorderRadius.circular(80),
                  borderColor: tc.accent.withValues(alpha: 0.4),
                  child: Icon(
                    Icons.camera_rounded,
                    size: 70,
                    color: tc.accent,
                  ),
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 600.ms)
                  .then()
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    duration: 4.seconds,
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05),
                  ),

              const Spacer(flex: 1),

              // Opening text sequence
              FadeInUp(
                delay: 1000.ms,
                child: Text(
                  'THE DARKROOM AWAITS',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    letterSpacing: 6,
                    color: tc.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              FadeInUp(
                delay: 1500.ms,
                child: SizedBox(
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [tc.accent, AppColors.cherryRed],
                      ).createShader(bounds),
                      child: Text(
                        'GOLDENHOUR',
                        style: GoogleFonts.cinzel(
                          fontSize: 42,
                          letterSpacing: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FadeInUp(
                delay: 2000.ms,
                child: Text(
                  'Where light becomes memory',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: tc.textSecondary.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 3),

              FadeInUp(
                delay: 2500.ms,
                child: _buildPrimaryButton(
                  label: 'ENTER THE DARKROOM',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _nextPage();
                  },
                ),
              ),

              const SizedBox(height: 20),

              FadeIn(
                delay: 3000.ms,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'SKIP SETUP →',
                        style: AppTypography.labelMedium.copyWith(
                          color: tc.textFaint,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (widget.showSkipToLogin) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'ALREADY HAVE AN ACCOUNT? LOGIN',
                          style: AppTypography.labelMedium.copyWith(
                            color: tc.accent,
                            letterSpacing: 2,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // PAGE 1: WHY FILM - EMOTIONAL CONNECTION
  // ============================================
  Widget _buildWhyFilmPage() {
    final tc = context.colors;
    final onboarding = ref.watch(onboardingProvider);

    final options = [
      {
        'id': 'warmth',
        'icon': Icons.wb_sunny_rounded,
        'title': 'THE WARMTH',
        'description': 'Digital feels cold. I want photos that feel like sunlight.',
        'color': const Color(0xFFFFB347),
      },
      {
        'id': 'imperfection',
        'icon': Icons.grain_rounded,
        'title': 'THE IMPERFECTION',
        'description': 'Grain, light leaks, happy accidents — that\'s where magic lives.',
        'color': const Color(0xFFE57373),
      },
      {
        'id': 'ritual',
        'icon': Icons.hourglass_bottom_rounded,
        'title': 'THE RITUAL',
        'description': 'Slow down. Be intentional. Every frame counts.',
        'color': const Color(0xFF81D4FA),
      },
      {
        'id': 'nostalgia',
        'icon': Icons.auto_awesome_rounded,
        'title': 'THE NOSTALGIA',
        'description': 'I want my photos to feel like memories, not screenshots.',
        'color': const Color(0xFFCE93D8),
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'WHAT DRAWS YOU\nTO FILM?',
                style: GoogleFonts.cinzel(
                  fontSize: 26,
                  color: tc.textPrimary,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: 100.ms,
              child: Text(
                'Help us understand your soul.',
                style: AppTypography.bodyMedium.copyWith(
                  color: tc.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = onboarding.whyFilm == option['id'];

                  return FadeInLeft(
                    delay: (index * 100).ms,
                    child: _buildEmotionCard(
                      icon: option['icon'] as IconData,
                      title: option['title'] as String,
                      description: option['description'] as String,
                      color: option['color'] as Color,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(onboardingProvider.notifier).setWhyFilm(option['id'] as String);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildNavigationButtons(
              canContinue: onboarding.whyFilm != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final tc = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : tc.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withValues(alpha: 0.1) : tc.cardSurface,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color.withValues(alpha: 0.2) : tc.overlayLight,
              ),
              child: Icon(icon, color: isSelected ? color : tc.textFaint, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? color : tc.textPrimary,
                      letterSpacing: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: tc.textSecondary,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PAGE 2: ERA - TIME PERIOD AESTHETIC
  // ============================================
  Widget _buildEraPage() {
    final tc = context.colors;
    final onboarding = ref.watch(onboardingProvider);

    final eras = [
      {
        'id': '70s',
        'title': '1970s',
        'subtitle': 'POLAROID DREAMS',
        'description': 'Faded memories & sun-bleached nostalgia',
        'gradient': [const Color(0xFFFFE4B5), const Color(0xFFDEB887)],
      },
      {
        'id': '80s',
        'title': '1980s',
        'subtitle': 'NEON NIGHTS',
        'description': 'Film grain meets urban glow',
        'gradient': [const Color(0xFFFF69B4), const Color(0xFF9370DB)],
      },
      {
        'id': '90s',
        'title': '1990s',
        'subtitle': 'GOLDEN HOUR',
        'description': 'Disposable camera magic & everyday beauty',
        'gradient': [const Color(0xFFF4C542), const Color(0xFFFF8C00)],
      },
      {
        'id': '2000s',
        'title': '2000s',
        'subtitle': 'INDIE FILM',
        'description': 'Cross-processed & music video aesthetic',
        'gradient': [const Color(0xFF00CED1), const Color(0xFF20B2AA)],
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'YOUR ERA',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: tc.textPrimary,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: 100.ms,
              child: Text(
                'What decade speaks to your soul?',
                style: AppTypography.bodyMedium.copyWith(
                  color: tc.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: eras.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final era = eras[index];
                  final isSelected = onboarding.favoriteEra == era['id'];

                  return FadeInLeft(
                    delay: (index * 100).ms,
                    child: _buildEraCard(
                      title: era['title'] as String,
                      subtitle: era['subtitle'] as String,
                      description: era['description'] as String,
                      gradient: era['gradient'] as List<Color>,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(onboardingProvider.notifier).setFavoriteEra(era['id'] as String);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildNavigationButtons(
              canContinue: onboarding.favoriteEra != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEraCard({
    required String title,
    required String subtitle,
    required String description,
    required List<Color> gradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final tc = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? gradient[0] : tc.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          gradient: isSelected
              ? LinearGradient(
                  colors: [gradient[0].withValues(alpha: 0.15), gradient[1].withValues(alpha: 0.05)],
                )
              : null,
          color: isSelected ? null : tc.cardSurface,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Era badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected ? gradient : [tc.overlayLight, tc.overlayLight],
                  ),
                ),
                child: Center(
                  child: Text(
                    title.substring(2, 4),
                    style: GoogleFonts.spaceMono(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : tc.textFaint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      subtitle,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected ? gradient[0] : tc.textPrimary,
                        letterSpacing: 2,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.bodySmall.copyWith(
                        color: tc.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: gradient[0], size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // PAGE 3: SUBJECTS - WHAT DO YOU SHOOT
  // ============================================
  Widget _buildSubjectsPage() {
    final tc = context.colors;
    final onboarding = ref.watch(onboardingProvider);

    final subjects = [
      {'id': 'portraits', 'icon': Icons.face_rounded, 'label': 'PORTRAITS', 'sub': 'The people in your life'},
      {'id': 'streets', 'icon': Icons.location_city_rounded, 'label': 'STREETS', 'sub': 'Urban stories unfolding'},
      {'id': 'landscapes', 'icon': Icons.landscape_rounded, 'label': 'LANDSCAPES', 'sub': 'Where the horizon calls'},
      {'id': 'nightlife', 'icon': Icons.nightlife_rounded, 'label': 'NIGHTLIFE', 'sub': 'When the city glows'},
      {'id': 'moments', 'icon': Icons.celebration_rounded, 'label': 'MOMENTS', 'sub': 'Parties, friends, chaos'},
      {'id': 'experimental', 'icon': Icons.science_rounded, 'label': 'EXPERIMENTAL', 'sub': 'Rules are meant to break'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'YOUR SUBJECTS',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: tc.textPrimary,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: 100.ms,
              child: Text(
                'What do you love to capture? (Select all that apply)',
                style: AppTypography.bodyMedium.copyWith(color: tc.textMuted),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isSelected = onboarding.subjects.contains(subject['id']);

                  return FadeInUp(
                    delay: (index * 80).ms,
                    child: _buildSubjectCard(
                      icon: subject['icon'] as IconData,
                      label: subject['label'] as String,
                      sub: subject['sub'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(onboardingProvider.notifier).toggleSubject(subject['id'] as String);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildNavigationButtons(
              canContinue: onboarding.subjects.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard({
    required IconData icon,
    required String label,
    required String sub,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final tc = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? tc.accent : tc.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? tc.accent.withValues(alpha: 0.1) : tc.cardSurface,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 36,
                    color: isSelected ? tc.accent : tc.textFaint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: AppTypography.labelMedium.copyWith(
                      color: isSelected ? tc.accent : tc.textPrimary,
                      letterSpacing: 1,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    style: AppTypography.bodySmall.copyWith(
                      color: tc.textFaint,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.check_circle_rounded, color: tc.accent, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PAGE 4: WORKFLOW
  // ============================================
  Widget _buildWorkflowPage() {
    final tc = context.colors;
    final onboarding = ref.watch(onboardingProvider);

    final workflows = [
      {
        'id': 'camera_explorer',
        'icon': Icons.auto_awesome_motion_rounded,
        'title': 'THE EXPLORER',
        'subtitle': 'HANDS-ON RITUAL',
        'description': 'You want to feel every dial. Adjust. Experiment.\nThe process is the art.',
      },
      {
        'id': 'quick_presets',
        'icon': Icons.bolt_rounded,
        'title': 'THE MOMENT HUNTER',
        'subtitle': 'INSTANT MAGIC',
        'description': 'Life moves fast. You need to be faster.\nPoint. Shoot. Magic.',
      },
      {
        'id': 'balanced',
        'icon': Icons.balance_rounded,
        'title': 'THE BALANCED',
        'subtitle': 'FLEXIBLE ARTIST',
        'description': 'Sometimes you explore. Sometimes you capture.\nYou want both worlds.',
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'YOUR RITUAL',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: tc.textPrimary,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: 100.ms,
              child: Text(
                'How do you want to create?',
                style: AppTypography.bodyMedium.copyWith(color: tc.textMuted),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: workflows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final workflow = workflows[index];
                  final isSelected = onboarding.workflow == workflow['id'];

                  return FadeInLeft(
                    delay: (index * 120).ms,
                    child: _buildWorkflowCard(
                      icon: workflow['icon'] as IconData,
                      title: workflow['title'] as String,
                      subtitle: workflow['subtitle'] as String,
                      description: workflow['description'] as String,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(onboardingProvider.notifier).setWorkflow(workflow['id'] as String);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildNavigationButtons(canContinue: true),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final tc = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? tc.accent : tc.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? tc.accent.withValues(alpha: 0.08) : tc.cardSurface,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? tc.accent.withValues(alpha: 0.2) : tc.overlayLight,
              ),
              child: Icon(icon, color: isSelected ? tc.accent : tc.textFaint, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? tc.accent : tc.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.monoSmall.copyWith(
                      color: isSelected ? tc.accentMuted : tc.textFaint,
                      fontSize: 9,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: tc.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: tc.accent, size: 24),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PAGE 5: FORMAT
  // ============================================
  Widget _buildFormatPage() {
    final tc = context.colors;
    final onboarding = ref.watch(onboardingProvider);

    final formats = [
      {
        'id': '3:4',
        'label': 'PORTRAIT',
        'sub': 'The classic 35mm frame. How Cartier-Bresson saw the world.',
        'w': 45.0,
        'h': 60.0,
      },
      {
        'id': '1:1',
        'label': 'SQUARE',
        'sub': 'Medium format magic. The Hasselblad dream.',
        'w': 55.0,
        'h': 55.0,
      },
      {
        'id': '16:9',
        'label': 'CINEMA',
        'sub': 'Anamorphic. Cinematic. Every shot tells a story.',
        'w': 70.0,
        'h': 40.0,
      },
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'YOUR FRAME',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: tc.textPrimary,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: 100.ms,
              child: Text(
                'How do you see the world?',
                style: AppTypography.bodyMedium.copyWith(color: tc.textMuted),
              ),
            ),

            const SizedBox(height: 48),

            ...formats.asMap().entries.map((entry) {
              final index = entry.key;
              final format = entry.value;
              final isSelected = onboarding.aspectRatio == format['id'];

              return FadeInLeft(
                delay: (index * 150).ms,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildFormatCard(
                    id: format['id'] as String,
                    label: format['label'] as String,
                    sub: format['sub'] as String,
                    width: format['w'] as double,
                    height: format['h'] as double,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(onboardingProvider.notifier).setAspectRatio(format['id'] as String);
                    },
                  ),
                ),
              );
            }),

            const Spacer(),

            _buildNavigationButtons(canContinue: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard({
    required String id,
    required String label,
    required String sub,
    required double width,
    required double height,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final tc = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? tc.accent : tc.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? tc.accent.withValues(alpha: 0.08) : tc.cardSurface,
        ),
        child: Row(
          children: [
            // Aspect ratio visual
            Container(
              width: 80,
              height: 70,
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? tc.accent : tc.textFaint,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  color: isSelected ? tc.accent.withValues(alpha: 0.1) : null,
                ),
                child: isSelected
                    ? Icon(Icons.crop_rounded, color: tc.accent, size: 20)
                    : null,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        id,
                        style: GoogleFonts.spaceMono(
                          color: isSelected ? tc.accent : tc.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? tc.accent : tc.textSecondary,
                          letterSpacing: 2,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    sub,
                    style: AppTypography.bodySmall.copyWith(
                      color: tc.textMuted,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: tc.accent, size: 22),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PAGE 6: TOOLKIT - RECOMMENDED FILMS & PRESETS
  // ============================================
  Widget _buildToolkitPage() {
    final tc = context.colors;
    final onboarding = ref.watch(onboardingProvider);
    final recommendedItems = _getRecommendedToolkit(onboarding);

    // Update toolkit in onboarding data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cameraIds = recommendedItems
          .where((item) => item.type == ToolkitItemType.camera)
          .map((c) => c.originalId)
          .toList();
      if (cameraIds.join(',') != onboarding.toolkitCameraIds.join(',')) {
        ref.read(onboardingProvider.notifier).setToolkitCameras(cameraIds);
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 60, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'YOUR TOOLKIT',
                style: GoogleFonts.cinzel(
                  fontSize: 26,
                  color: tc.textPrimary,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            FadeInDown(
              delay: 100.ms,
              child: Text(
                'Films & presets curated for your creative soul...',
                style: AppTypography.bodyMedium.copyWith(
                  color: tc.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 32),

            Expanded(
              child: ListView.separated(
                itemCount: recommendedItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = recommendedItems[index];
                  final matchReason = _getToolkitMatchReason(item, onboarding);

                  return FadeInLeft(
                    delay: (index * 80).ms,
                    child: _buildToolkitCard(item, matchReason),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            _buildNavigationButtons(canContinue: true),
          ],
        ),
      ),
    );
  }

  Widget _buildToolkitCard(ToolkitItem item, String matchReason) {
    final tc = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.accentColor.withValues(alpha: 0.3)),
        color: tc.cardSurface,
      ),
      child: Row(
        children: [
          // Icon based on type
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.accentColor.withValues(alpha: 0.3),
                  item.accentColor.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Icon(
              item.icon,
              size: 24,
              color: item.accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name.toUpperCase(),
                        style: AppTypography.labelMedium.copyWith(
                          color: tc.textPrimary,
                          letterSpacing: 1,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.typeLabel,
                        style: AppTypography.monoSmall.copyWith(
                          color: item.accentColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  matchReason,
                  style: AppTypography.bodySmall.copyWith(
                    color: tc.textSecondary,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: tc.textGhost, size: 18),
        ],
      ),
    );
  }

  String _getToolkitMatchReason(ToolkitItem item, OnboardingData data) {
    // Personalized match reasons for cameras
    if (item.type == ToolkitItemType.camera) {
      if (data.favoriteEra == '70s' && item.category?.toLowerCase().contains('instant') == true) {
        return 'Perfect for your 70s Polaroid dreams';
      }
      if (data.favoriteEra == '80s' && item.id.contains('cinestill')) {
        return 'Captures those neon nights you love';
      }
      if (data.favoriteEra == '90s' && item.id.contains('gold')) {
        return 'The essence of 90s golden hour';
      }
      if (data.subjects.contains('portraits') && item.id.contains('portra')) {
        return 'The portrait master for beautiful skin tones';
      }
      if (data.subjects.contains('landscapes') && item.id.contains('velvia')) {
        return 'Legendary for breathtaking landscapes';
      }
      if (data.whyFilm == 'imperfection' && item.id.contains('lomo')) {
        return 'Embraces the beautiful imperfections';
      }
      if (data.whyFilm == 'warmth' && item.pipeline.temperature > 0) {
        return 'Warm tones for that sunlit feeling';
      }
    }

    // Personalized match reasons for presets
    if (item.type == ToolkitItemType.preset) {
      if (data.favoriteEra == '70s' && item.id.contains('70s')) {
        return 'Captures that 70s aesthetic you love';
      }
      if (data.favoriteEra == '80s' && (item.id.contains('neon') || item.id.contains('80s'))) {
        return 'Perfect for your neon dreams';
      }
      if (data.favoriteEra == '90s' && (item.id.contains('disposable') || item.id.contains('gold'))) {
        return 'That 90s disposable camera magic';
      }
      if (data.subjects.contains('portraits') && item.id.contains('portrait')) {
        return 'Makes your portraits glow';
      }
      if (data.subjects.contains('nightlife') && (item.id.contains('night') || item.id.contains('neon'))) {
        return 'Perfect for after-dark adventures';
      }
      if (data.subjects.contains('landscapes') && item.id.contains('velvia')) {
        return 'Makes landscapes pop with color';
      }
      if (data.whyFilm == 'nostalgia' && (item.id.contains('vintage') || item.id.contains('faded'))) {
        return 'Instant nostalgia in every edit';
      }
      if (data.whyFilm == 'imperfection' && item.id.contains('grunge')) {
        return 'Embraces raw, gritty imperfection';
      }
      if (data.workflow == 'quick_presets') {
        return 'One-tap magic for the moment hunter';
      }
    }

    return item.description;
  }

  // ============================================
  // PAGE 7: READY - LAUNCH
  // ============================================
  Widget _buildReadyPage() {
    final tc = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          children: [
            const Spacer(flex: 2),

            // Camera shutter animation
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: tc.accent.withValues(alpha: 0.4),
                    blurRadius: 50,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: tc.accent, width: 3),
                    ),
                  ),
                  // Inner shutter blades (simplified)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tc.accent.withValues(alpha: 0.1),
                      border: Border.all(color: tc.accent.withValues(alpha: 0.5), width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 50,
                      color: tc.accent,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 1.seconds)
                .then()
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 2.seconds,
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                ),

            const Spacer(flex: 1),

            FadeInUp(
              delay: 500.ms,
              child: Text(
                'YOUR DARKROOM\nIS READY',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: tc.textPrimary,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            FadeInUp(
              delay: 700.ms,
              child: Text(
                'Your films are loaded.\nNow go make memories.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  color: tc.textSecondary,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 2),

            FadeInUp(
              delay: 1000.ms,
              child: _buildPrimaryButton(
                label: '📸  START SHOOTING',
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  _finishOnboarding();
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Get recommended toolkit items (cameras + presets) based on user preferences
  List<ToolkitItem> _getRecommendedToolkit(OnboardingData data) {
    final allCameras = CameraRepository.getAllCameras();
    final allPresets = PresetRepository.getAllPresets();

    List<String> recommendedCameraIds = [];
    List<String> recommendedPresetIds = [];

    // Base camera recommendations by workflow
    if (data.workflow == 'camera_explorer') {
      recommendedCameraIds = ['kodak_portra_400', 'kodak_trix_400', 'cinestill_800t'];
      recommendedPresetIds = ['warm_coffee', 'moody_japan', 'cross_processed'];
    } else if (data.workflow == 'quick_presets') {
      recommendedCameraIds = ['kodak_gold_200', 'fuji_superia_400'];
      recommendedPresetIds = ['disposable_free', 'light_airy', 'portra_400', 'sunset_picsart'];
    } else {
      recommendedCameraIds = ['kodak_gold_200', 'kodak_portra_400', 'cinestill_800t'];
      recommendedPresetIds = ['disposable_free', 'moody_green', 'light_airy'];
    }

    // Adjust by era
    if (data.favoriteEra == '70s') {
      if (!recommendedCameraIds.contains('polaroid_600')) recommendedCameraIds.insert(0, 'polaroid_600');
      if (!recommendedPresetIds.contains('70s_warm')) recommendedPresetIds.insert(0, '70s_warm');
      if (!recommendedPresetIds.contains('expired_polaroid')) recommendedPresetIds.add('expired_polaroid');
    } else if (data.favoriteEra == '80s') {
      if (!recommendedCameraIds.contains('cinestill_800t')) recommendedCameraIds.insert(0, 'cinestill_800t');
      if (!recommendedPresetIds.contains('80s_neon')) recommendedPresetIds.insert(0, '80s_neon');
      if (!recommendedPresetIds.contains('blade_runner')) recommendedPresetIds.add('blade_runner');
    } else if (data.favoriteEra == '90s') {
      if (!recommendedCameraIds.contains('kodak_gold_200')) recommendedCameraIds.insert(0, 'kodak_gold_200');
      if (!recommendedPresetIds.contains('disposable_free')) recommendedPresetIds.insert(0, 'disposable_free');
      if (!recommendedPresetIds.contains('millennial_palm')) recommendedPresetIds.add('millennial_palm');
    } else if (data.favoriteEra == '2000s') {
      if (!recommendedCameraIds.contains('xpro_slide')) recommendedCameraIds.insert(0, 'xpro_slide');
      if (!recommendedPresetIds.contains('cross_processed')) recommendedPresetIds.insert(0, 'cross_processed');
      if (!recommendedPresetIds.contains('lofi_indoor')) recommendedPresetIds.add('lofi_indoor');
    }

    // Adjust by subjects
    if (data.subjects.contains('portraits')) {
      if (!recommendedCameraIds.contains('kodak_portra_400')) recommendedCameraIds.insert(0, 'kodak_portra_400');
      if (!recommendedPresetIds.contains('bright_portrait')) recommendedPresetIds.insert(0, 'bright_portrait');
    }
    if (data.subjects.contains('nightlife')) {
      if (!recommendedCameraIds.contains('cinestill_800t')) recommendedCameraIds.insert(0, 'cinestill_800t');
      if (!recommendedPresetIds.contains('night_city')) recommendedPresetIds.insert(0, 'night_city');
      if (!recommendedPresetIds.contains('urban_night')) recommendedPresetIds.add('urban_night');
    }
    if (data.subjects.contains('landscapes')) {
      if (!recommendedCameraIds.contains('fuji_velvia_50')) recommendedCameraIds.insert(0, 'fuji_velvia_50');
      if (!recommendedPresetIds.contains('ghibli_green')) recommendedPresetIds.insert(0, 'ghibli_green');
    }
    if (data.subjects.contains('experimental')) {
      if (!recommendedCameraIds.contains('lomo_purple')) recommendedCameraIds.add('lomo_purple');
      if (!recommendedPresetIds.contains('grunge_aesthetic')) recommendedPresetIds.add('grunge_aesthetic');
    }
    if (data.subjects.contains('streets')) {
      if (!recommendedPresetIds.contains('moody_japan')) recommendedPresetIds.insert(0, 'moody_japan');
      if (!recommendedPresetIds.contains('city_rain')) recommendedPresetIds.add('city_rain');
    }

    // Adjust by format
    if (data.aspectRatio == '16:9') {
      if (!recommendedPresetIds.contains('teal_orange')) recommendedPresetIds.insert(0, 'teal_orange');
      if (!recommendedPresetIds.contains('golden_hour_cine')) recommendedPresetIds.add('golden_hour_cine');
    }

    // Adjust by whyFilm
    if (data.whyFilm == 'warmth') {
      if (!recommendedPresetIds.contains('warm_soft')) recommendedPresetIds.insert(0, 'warm_soft');
    } else if (data.whyFilm == 'imperfection') {
      if (!recommendedPresetIds.contains('grunge_aesthetic')) recommendedPresetIds.insert(0, 'grunge_aesthetic');
      if (!recommendedPresetIds.contains('faded_film_v2')) recommendedPresetIds.add('faded_film_v2');
    } else if (data.whyFilm == 'nostalgia') {
      if (!recommendedPresetIds.contains('vintage_matte')) recommendedPresetIds.insert(0, 'vintage_matte');
      if (!recommendedPresetIds.contains('super_8')) recommendedPresetIds.add('super_8');
    }

    // Convert to ToolkitItem models
    final recommendedItems = <ToolkitItem>[];

    // Add cameras (limit to 3)
    for (final id in recommendedCameraIds.take(3)) {
      final camera = allCameras.firstWhere((c) => c.id == id, orElse: () => allCameras.first);
      final item = ToolkitItem.fromCamera(camera);
      if (!recommendedItems.contains(item)) recommendedItems.add(item);
    }

    // Add presets (limit to 4 - presets are more diverse and unique)
    for (final id in recommendedPresetIds.take(4)) {
      final preset = allPresets.firstWhere((p) => p.id == id, orElse: () => allPresets.first);
      final item = ToolkitItem.fromPreset(preset);
      if (!recommendedItems.contains(item)) recommendedItems.add(item);
    }

    // Ensure we have at least 5 items total
    if (recommendedItems.length < 5) {
      // Add more presets first (they're more diverse)
      for (final preset in allPresets.where((p) => !p.isPro)) {
        final item = ToolkitItem.fromPreset(preset);
        if (!recommendedItems.contains(item)) recommendedItems.add(item);
        if (recommendedItems.length >= 6) break;
      }
    }

    return recommendedItems.take(7).toList();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    // Set defaults and finish
    ref.read(onboardingProvider.notifier).setWorkflow('balanced');
    ref.read(onboardingProvider.notifier).setAspectRatio('3:4');
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    final onboarding = ref.read(onboardingProvider);

    // Save to local settings (SharedPreferences)
    ref.read(settingsProvider.notifier).setPreferredWorkflow(onboarding.workflow);
    ref.read(settingsProvider.notifier).setAspectRatio(onboarding.aspectRatio);

    // Get recommended toolkit items (cameras + presets)
    final recommendedItems = _getRecommendedToolkit(onboarding);

    // Separate cameras and presets
    final cameraItems = recommendedItems.where((item) => item.type == ToolkitItemType.camera).toList();
    final presetItems = recommendedItems.where((item) => item.type == ToolkitItemType.preset).toList();

    // Save camera toolkit IDs
    final cameraIds = cameraItems.map((c) => c.originalId).toList();
    ref.read(settingsProvider.notifier).setToolkitCameras(cameraIds);

    // Add cameras to favorites
    for (final item in cameraItems) {
      if (!CameraRepository.isFavorite(item.originalId)) {
        await CameraRepository.toggleFavorite(item.originalId);
      }
    }

    // Add presets to favorites
    for (final item in presetItems) {
      if (!PresetRepository.isFavorite(item.originalId)) {
        await PresetRepository.toggleFavorite(item.originalId);
      }
    }

    // Set active camera
    if (cameraItems.isNotEmpty) {
      ref.read(settingsProvider.notifier).setActiveCamera(cameraItems.first.originalId);
    }

    // Store toolkit for later sync when user logs in
    ref.read(onboardingProvider.notifier).setToolkitCameras(cameraIds);

    // Note: Firebase sync will happen after login in auth_provider

    if (mounted) {
      // Navigate to Login screen - user must authenticate before using the app
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Widget _buildNavigationButtons({required bool canContinue}) {
    return Row(
      children: [
        if (_currentPage > 1)
          Expanded(
            child: _buildSecondaryButton(
              label: 'BACK',
              onPressed: _prevPage,
            ),
          ),
        if (_currentPage > 1) const SizedBox(width: 16),
        Expanded(
          flex: _currentPage > 1 ? 2 : 1,
          child: _buildPrimaryButton(
            label: 'CONTINUE',
            onPressed: canContinue ? _nextPage : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: onPressed != null
                  ? [AppColors.retroBurgundy, AppColors.cherryRed]
                  : [Colors.white10, Colors.white10],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: AppColors.retroBurgundy.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    )
                  ]
                : [],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontSize: 14,
                letterSpacing: 3,
                fontWeight: FontWeight.w800,
                color: onPressed != null ? Colors.white : Colors.white38,
              ),
            ),
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

// ============================================
// FILM GRAIN PAINTER
// ============================================
class FilmGrainPainter extends CustomPainter {
  final double opacity;
  final int seed;

  FilmGrainPainter({required this.opacity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    // Simple noise effect using random dots
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..strokeWidth = 1;

    final random = seed % 1000;
    for (int i = 0; i < 200; i++) {
      final x = ((random + i * 17) % size.width.toInt()).toDouble();
      final y = ((random + i * 23) % size.height.toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(FilmGrainPainter oldDelegate) => true;
}

// AdaptiveGlass is defined in theme_colors.dart
