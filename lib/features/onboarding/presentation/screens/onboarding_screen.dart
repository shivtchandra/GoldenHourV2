import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../camera/data/repositories/camera_repository.dart';
import '../../../camera/data/models/camera_model.dart';
import '../../../camera/providers/settings_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // User Preferences
  final Set<String> _selectedStyles = {};
  String _selectedFormat = '3:4';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glows
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
                    AppColors.accentGold.withOpacity(0.12),
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
                    AppColors.retroBurgundy.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Page Content
          PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (page) => setState(() => _currentPage = page),
            children: [
              _buildWelcomePage(),
              _buildStyleSelectionPage(),
              _buildFormatSelectionPage(),
              _buildRecommendationPage(),
            ],
          ),
        ],
      ),
    );
  }

  // --- PAGE 1: WELCOME ---
  Widget _buildWelcomePage() {
    return FadeIn(
      duration: const Duration(seconds: 1),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              // Premium Logo / Element
              GlassContainer.clearGlass(
                width: 140,
                height: 140,
                borderRadius: BorderRadius.circular(70),
                borderColor: AppColors.accentGold.withOpacity(0.4),
                child: Hero(
                  tag: 'app_logo',
                  child: Icon(Icons.camera_rounded, size: 60, color: AppColors.accentGold),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(duration: 3.seconds, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
              
              const Spacer(flex: 2),
              
              FadeInDown(
                delay: 200.ms,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'FILMCAM',
                      style: GoogleFonts.cinzel(
                        fontSize: 48,
                        letterSpacing: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentGold,
                        height: 1.0,
                      ).copyWith(fontFamilyFallback: ['Georgia', 'serif']),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeInDown(
                delay: 400.ms,
                child: Text(
                  'ANALOG CRAFTSMANSHIP',
                  style: GoogleFonts.spaceMono(
                    color: AppColors.accentGold.withOpacity(0.5),
                    letterSpacing: 6,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ).copyWith(fontFamilyFallback: ['Courier', 'monospace']),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 48),
              
              FadeInUp(
                delay: 600.ms,
                child: Text(
                  'Elevate your digital canvas with\nauthentic photochemical aesthetics.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                    height: 1.6,
                  ).copyWith(fontFamilyFallback: ['Times New Roman', 'serif']),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const Spacer(flex: 3),
              
              FadeInUp(
                delay: 800.ms,
                child: _buildPrimaryButton(
                  label: 'ENTER STUDIO',
                  onPressed: () => _nextPage(),
                ),
              ),
              const SizedBox(height: 24),
              FadeIn(
                delay: 1000.ms,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'SKIP TO GALLERY →',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white24,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PAGE 2: STYLE PREFERENCES ---
  Widget _buildStyleSelectionPage() {
    final styles = [
      {'id': 'warm', 'title': 'GOLDEN HOUR', 'subtitle': 'WARM', 'desc': 'Sun-drenched nostalgia'},
      {'id': 'cool', 'title': 'SILVER NITRATE', 'subtitle': 'COOL', 'desc': 'Icy clinical aesthetics'},
      {'id': 'bw', 'title': 'MONOLITH', 'subtitle': 'B&W', 'desc': 'Timeless grain & shadow'},
      {'id': 'vibrant', 'title': 'TECHNICOLOR', 'subtitle': 'VIBRANT', 'desc': 'Saturated vivid life'},
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderLink(onTap: _prevPage),
            const SizedBox(height: 32),
            FadeInDown(
              child: Text(
                'YOUR AESTHETIC?',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ).copyWith(fontFamilyFallback: ['serif']),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: 100.ms,
              child: Text(
                'Select the visual signature for your studio.',
                style: AppTypography.bodyLarge.copyWith(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: ListView.separated(
                itemCount: (styles.length / 2).ceil(),
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, rowIndex) {
                  return Row(
                    children: [
                      Expanded(child: _buildStyleCard(styles[rowIndex * 2])),
                      const SizedBox(width: 20),
                      Expanded(
                        child: rowIndex * 2 + 1 < styles.length 
                          ? _buildStyleCard(styles[rowIndex * 2 + 1]) 
                          : const SizedBox(),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            FadeInUp(
              child: _buildPrimaryButton(
                label: 'DEFINE IDENTITY',
                onPressed: _selectedStyles.isEmpty ? null : _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleCard(Map<String, String> style) {
    final isSelected = _selectedStyles.contains(style['id']);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedStyles.remove(style['id']);
          } else {
            _selectedStyles.add(style['id']!);
          }
        });
      },
      child: GlassContainer.clearGlass(
        height: 180,
        width: double.infinity,
        borderRadius: BorderRadius.circular(24),
        borderWidth: isSelected ? 2.0 : 1.0,
        borderColor: isSelected ? AppColors.accentGold : Colors.white.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lens_blur_rounded,
                color: isSelected ? AppColors.accentGold : Colors.white24,
                size: 28,
              ),
              const SizedBox(height: 16),
              Text(
                style['title']!,
                textAlign: TextAlign.center,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  color: isSelected ? AppColors.accentGold : Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                style['subtitle']!,
                style: AppTypography.monoSmall.copyWith(
                  color: isSelected ? AppColors.accentGold.withOpacity(0.5) : Colors.white24,
                  fontSize: 8,
                ),
              ),
              const Spacer(),
              Text(
                style['desc']!,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 9,
                  color: Colors.white38,
                  fontStyle: FontStyle.italic,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- PAGE 3: FORMAT SELECTION ---
  Widget _buildFormatSelectionPage() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderLink(onTap: _prevPage),
            const SizedBox(height: 32),
            FadeInDown(
              child: Text(
                'CHOOSE ASPECT',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: Colors.white,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ).copyWith(fontFamilyFallback: ['serif']),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: 100.ms,
              child: Text(
                'How do you want to frame your stories?',
                style: AppTypography.bodyLarge.copyWith(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 48),
            FadeInLeft(delay: 200.ms, child: _buildFormatOption('3:4', 'PORTRAIT', 'Best for social stories')),
            const SizedBox(height: 16),
            FadeInLeft(delay: 350.ms, child: _buildFormatOption('1:1', 'SQUARE', 'Classic Rolleiflex feel')),
            const SizedBox(height: 16),
            FadeInLeft(delay: 500.ms, child: _buildFormatOption('16:9', 'CINEMA', 'Wide anamorphic look')),
            const Spacer(),
            FadeInUp(
              delay: 600.ms,
              child: _buildPrimaryButton(
                label: 'CONTINUE',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatOption(String id, String label, String sub) {
    final isSelected = _selectedFormat == id;
    
    // Calculate preview box size
    double w = 30;
    double h = 30;
    if (id == '3:4') { w = 22; h = 30; }
    if (id == '16:9') { w = 30; h = 17; }

    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = id),
      child: GlassContainer.clearGlass(
        height: 84,
        width: double.infinity,
        borderRadius: BorderRadius.circular(20),
        borderWidth: isSelected ? 2.0 : 1.0,
        borderColor: isSelected ? AppColors.accentGold : Colors.white.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Ratio Visual
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppColors.accentGold : Colors.white24,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Row(
                     children: [
                       Text(
                        id,
                        style: GoogleFonts.spaceMono(
                          color: isSelected ? AppColors.accentGold : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected ? AppColors.accentGold : Colors.white70,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                     ],
                   ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white24,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (isSelected) 
                const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- PAGE 4: RECOMMENDATIONS ---
  Widget _buildRecommendationPage() {
    final recommended = _getRecommendedCameras();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              child: Text(
                'YOUR TOOLKIT',
                style: AppTypography.displayLarge.copyWith(
                   fontSize: 32,
                   color: Colors.white,
                   letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeInDown(
              delay: 100.ms,
              child: Text(
                'We have prepared these vintage tools for you.',
                style: AppTypography.bodyMedium.copyWith(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.separated(
                itemCount: recommended.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final camera = recommended[index];
                  return FadeInLeft(
                    delay: (index * 150).ms,
                    child: GlassContainer.clearGlass(
                      height: 100,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(24),
                      borderWidth: 1,
                      borderColor: camera.iconColor.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: camera.iconColor.withOpacity(0.1),
                              ),
                              child: Icon(Icons.photo_camera_back_rounded, size: 32, color: camera.iconColor),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    camera.name.toUpperCase(), 
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    camera.type.toUpperCase(), 
                                    style: AppTypography.monoSmall.copyWith(
                                      color: camera.iconColor.withOpacity(0.6),
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white10, size: 14),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            FadeInUp(
              child: _buildPrimaryButton(
                label: 'OPEN SHUTTER',
                onPressed: _finishOnboarding,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CameraModel> _getRecommendedCameras() {
    // Simple mock logic
    final all = CameraRepository.getAllCameras();
    // In a real app, filter based on _selectedStyles
    return all.take(3).toList();
  }

  // --- HELPERS ---
  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    
    // Wire it up!
    final recommended = _getRecommendedCameras();
    if (recommended.isNotEmpty) {
      ref.read(settingsProvider.notifier).setActiveCamera(recommended.first.id);
    }
    ref.read(settingsProvider.notifier).setAspectRatio(_selectedFormat);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Widget _buildPrimaryButton({required String label, VoidCallback? onPressed}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: onPressed != null 
                ? [AppColors.retroBurgundy, AppColors.cherryRed]
                : [Colors.white10, Colors.white10],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: onPressed != null ? [
              BoxShadow(
                color: AppColors.retroBurgundy.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ] : [],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontSize: 16,
                letterSpacing: 4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderLink({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_rounded, color: Colors.white54, size: 16),
            const SizedBox(width: 8),
            Text(
              'BACK',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white54,
                letterSpacing: 2,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
