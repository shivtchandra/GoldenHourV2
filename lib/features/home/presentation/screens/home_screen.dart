import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../camera/data/repositories/camera_repository.dart';
import '../../../camera/data/models/camera_model.dart';
import '../../../camera/presentation/screens/camera_screen.dart';
import '../../../gallery/presentation/screens/gallery_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../camera/presentation/screens/camera_selector_screen.dart';
import 'studio_screen.dart';
import '../../../settings/presentation/screens/profile_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../settings/providers/user_provider.dart';
import '../../../presets/presentation/screens/presets_screen.dart';
import '../../../develop/presentation/screens/develop_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../camera/providers/settings_provider.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../widgets/feature_tutorial_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    _initData();
    _checkTutorial();
  }

  void _checkTutorial() async {
    final shouldShow = await FeatureTutorialOverlay.shouldShow();
    if (shouldShow && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  int _getInitialIndexFromWorkflow(String workflow) {
    switch (workflow) {
      case 'camera_explorer':
        return 1; // Lenses tab
      case 'quick_presets':
        return 2; // Presets tab
      case 'balanced':
      default:
        return 0; // Home tab
    }
  }

  void _initData() async {
    try {
      // Always start on the Home Dashboard (index 0) regardless of workflow preference
      setState(() {
        _currentIndex = 0;
      });

      _isLoading = false;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Listen for workflow preference changes
    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      if (previous?.preferredWorkflow != next.preferredWorkflow) {
        // Workflow changed - update current index
        setState(() {
          _currentIndex = _getInitialIndexFromWorkflow(next.preferredWorkflow);
        });
      }
    });

    final tc = context.colors;

    if (_error != null) {
      return Scaffold(
        backgroundColor: tc.scaffoldBackground,
        body: Center(child: Text("ERROR: $_error", style: TextStyle(color: tc.error))),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: tc.scaffoldBackground,
        body: Center(child: CircularProgressIndicator(color: tc.accent)),
      );
    }

    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final user = ref.watch(userProfileProvider);
    final currentCamera = CameraRepository.getAllCameras().firstWhere(
      (c) => c.id == settings.activeCameraId,
      orElse: () => CameraRepository.getAllCameras().first,
    );

    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      body: Stack(
        children: [
          _buildBackgroundGlows(theme),
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeContent(theme, currentCamera, user),
              CameraSelectorScreen(
                currentCamera: currentCamera,
                onCameraSelected: (camera) {
                  ref.read(settingsProvider.notifier).setActiveCamera(camera.id);
                  // Navigate directly to camera screen (like presets)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                },
              ),
              PresetsScreen(
                onPresetSelected: (preset) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(initialPreset: preset),
                    ),
                  );
                },
              ),
            ],
          ),
          // Feature tutorial overlay (shown after first login)
          if (_showTutorial)
            FeatureTutorialOverlay(
              onComplete: () {
                setState(() => _showTutorial = false);
              },
            ),
        ],
      ),
      bottomNavigationBar: _showTutorial ? null : _buildRoyalDock(theme),
    );
  }

  Widget _buildBackgroundGlows(ThemeData theme) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.03),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeContent(ThemeData theme, CameraModel currentCamera, UserProfile user) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, user),
            const SizedBox(height: 24),
            FadeInLeft(
              duration: const Duration(milliseconds: 800),
              child: _buildGreeting(theme, user),
            ),
            const SizedBox(height: 40),
            FadeIn(
              duration: const Duration(milliseconds: 1200),
              child: _buildHeroGlassCard(theme, currentCamera),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 200),
              child: _buildQuickActions(theme),
            ),
            const SizedBox(height: 48),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 400),
              child: _buildFavoritesHeader(theme),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 500),
              child: _buildFavoritesList(theme, currentCamera),
            ),
            const SizedBox(height: 48),
             FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 600),
              child: _buildRecentShotsHeader(theme),
            ),
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              delay: const Duration(milliseconds: 700),
              child: Consumer(
                builder: (context, ref, _) {
                  final recentPhotosAsync = ref.watch(recentPhotosProvider);
                  return recentPhotosAsync.when(
                    data: (photos) => _buildRecentShotsList(theme, currentCamera, photos),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Spacer to keep title centered
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'GOLDENHOUR',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 20,
                    color: theme.colorScheme.primary,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5),
              ),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                radius: 18,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cinzel',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(ThemeData theme, UserProfile user) {
    final hour = DateTime.now().hour;
    String greeting = 'GOOD MORNING';
    if (hour >= 12 && hour < 17) greeting = 'GOOD AFTERNOON';
    if (hour >= 17) greeting = 'GOOD EVENING';

    final user = ref.watch(userProfileProvider);
    final firstName = user.name.split(' ').first.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, $firstName',
            style: AppTypography.displaySmall.copyWith(
              color: context.colors.accentSecondary,
              fontSize: 14,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MASTERPIECES.',
            style: AppTypography.displayLarge.copyWith(
              color: context.colors.textPrimary,
              fontSize: 32,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGlassCard(ThemeData theme, CameraModel currentCamera) {
    return Consumer(
      builder: (context, ref, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AdaptiveGlass(
              height: 520,
              width: double.infinity,
              borderRadius: BorderRadius.circular(32),
              borderWidth: 1.5,
              borderColor: Colors.transparent,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.colors.overlayDark,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () async {
                              await CameraRepository.toggleFavorite(currentCamera.id);
                              setState(() {});
                            },
                            icon: Icon(
                              CameraRepository.isFavorite(currentCamera.id)
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: CameraRepository.isFavorite(currentCamera.id)
                                  ? context.colors.favorite
                                  : context.colors.iconMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'MASTERPIECE MODE',
                    style: AppTypography.monoMedium.copyWith(
                      color: theme.colorScheme.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          currentCamera.iconColor.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentCamera.iconColor.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Animate(
                      onPlay: (controller) => controller.repeat(),
                      child: Icon(
                        Icons.camera_outlined,
                        size: 100,
                        color: currentCamera.iconColor.withOpacity(0.9),
                      ),
                    ).shimmer(duration: const Duration(seconds: 3), color: context.colors.shimmerHighlight),
                  ),
                  const Spacer(),
                  Text(
                    currentCamera.name.toUpperCase(),
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 28,
                      letterSpacing: 2,
                      color: context.colors.textPrimary,
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'ISO ${currentCamera.iso} • ${currentCamera.description}',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.colors.textSecondary,
                        letterSpacing: 1.2,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          Positioned(
            bottom: -28,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CameraScreen()),
                  );
                  if (result == true) {
                    _initData();
                  }
                },
                child: AdaptiveGlass(
                  width: 200,
                  height: 64,
                  borderRadius: BorderRadius.circular(32),
                  borderWidth: 1,
                  borderColor: Colors.transparent,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CAPTURE',
                          style: AppTypography.labelLarge.copyWith(
                            color: context.colors.accent,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_forward_ios_rounded, color: context.colors.accent, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildQuickActions(ThemeData theme) {
    final settings = ref.watch(settingsProvider);
    final preferredWorkflow = settings.preferredWorkflow;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACCESS',
            style: AppTypography.monoSmall.copyWith(
              color: context.colors.textTertiary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _royalActionItem(theme, 'GALLERY', Icons.collections_outlined, () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
                _initData();
              }, emphasized: false),
              _royalActionItem(theme, 'LENSES', Icons.auto_awesome_motion_rounded, () {
                setState(() => _currentIndex = 1);
              }, emphasized: preferredWorkflow == 'camera_explorer'),
              _royalActionItem(theme, 'PRESETS', Icons.auto_awesome_rounded, () {
                setState(() => _currentIndex = 2);
              }, emphasized: preferredWorkflow == 'quick_presets'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _royalActionItem(ThemeData theme, String label, IconData icon, VoidCallback onTap, {bool emphasized = false}) {
    final tc = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AdaptiveGlass(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(24),
            borderWidth: emphasized ? 2 : 1,
            borderColor: emphasized
              ? tc.borderAccent
              : Colors.transparent,
            child: Icon(
              icon,
              color: emphasized ? tc.accent : theme.colorScheme.primary,
              size: emphasized ? 36 : 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              fontSize: 10,
              letterSpacing: 2,
              color: emphasized
                ? tc.accent
                : tc.textSecondary,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildFavoritesHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'FAVORITE CAMERAS',
        style: AppTypography.monoSmall.copyWith(
          color: context.colors.textTertiary,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildFavoritesList(ThemeData theme, CameraModel currentCamera) {
    final favorites = CameraRepository.getFavoriteCameras();
    
    final tc = context.colors;
    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AdaptiveGlass(
          height: 100,
          width: double.infinity,
          borderRadius: BorderRadius.circular(24),
          borderWidth: 1,
          borderColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded, color: tc.textMuted, size: 32),
              const SizedBox(height: 8),
              Text(
                'NO FAVORITES YET',
                style: AppTypography.labelMedium.copyWith(color: tc.textMuted, letterSpacing: 2),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, _) => SizedBox(
        height: 140,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: favorites.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final camera = favorites[index];
            final isSelected = camera.id == currentCamera.id;
            
            return GestureDetector(
              onTap: () => ref.read(settingsProvider.notifier).setActiveCamera(camera.id),
              child: AdaptiveGlass(
                width: 110,
                height: 140,
                borderRadius: BorderRadius.circular(24),
                borderWidth: isSelected ? 2 : 1,
                borderColor: isSelected ? tc.accent : Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: camera.iconColor.withOpacity(0.15),
                      ),
                      child: Icon(Icons.camera, color: camera.iconColor, size: 28),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        camera.name.replaceAll(' ', '\n'),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelMedium.copyWith(
                          fontSize: 10,
                          color: tc.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecentShotsHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'LATEST CAPTURES',
            style: AppTypography.headlineMedium.copyWith(
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
              _initData();
            },
            child: Text(
              'VIEW ALL',
              style: AppTypography.labelMedium.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentShotsList(ThemeData theme, CameraModel currentCamera, List<PhotoInfo> photos) {
    final tc = context.colors;
    if (photos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: AdaptiveGlass(
          height: 160,
          width: double.infinity,
          borderRadius: BorderRadius.circular(24),
          borderWidth: 1,
          borderColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, color: tc.textFaint, size: 40),
              const SizedBox(height: 12),
              Text(
                'NO CAPTURES YET',
                style: AppTypography.labelMedium.copyWith(color: tc.textFaint, letterSpacing: 2),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220, // Increased to accommodate text
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final photo = photos[index];
          
          return GestureDetector(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(photo.path),
                    width: 150,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  photo.cameraId.replaceAll('_', ' ').toUpperCase(),
                  style: AppTypography.monoSmall.copyWith(
                    fontSize: 8,
                    color: tc.accentMuted,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  photo.formattedTime.toUpperCase(),
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 10,
                    color: tc.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoyalDock(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
      child: AdaptiveGlass(
        height: 80,
        width: double.infinity,
        borderRadius: BorderRadius.circular(40),
        borderWidth: 1,
        borderColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _dockIcon(theme, Icons.home_rounded, 0, 'Home'),
            _dockIcon(theme, Icons.auto_awesome_motion_rounded, 1, 'Lenses'),
            _dockIcon(theme, Icons.tune_rounded, 2, 'Presets'),
            _dockIcon(theme, Icons.auto_fix_high_rounded, 3, 'Develop'),
            _dockIcon(theme, Icons.settings_rounded, 4, 'Settings'),
          ],
        ),
      ),
    );
  }

  Widget _dockIcon(ThemeData theme, IconData icon, int index, String label) {
    final active = _currentIndex == index;
    return GestureDetector(
      onTap: () async {
        if (index == 3) {
          // Open Develop as a dedicated full-screen experience
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DevelopScreen()),
          );
          _initData(); 
        } else if (index == 4) {
          // Open Settings
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: (active && index < 3) ? BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.15),
          shape: BoxShape.circle,
        ) : null,
        child: Icon(
          icon,
          color: (active && index < 3) ? theme.colorScheme.primary : context.colors.iconFaint,
          size: 28,
        ),
      ).animate(target: (active && index < 3) ? 1 : 0)
      .scale(
        begin: const Offset(1.0, 1.0),
        end: const Offset(1.2, 1.2),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
      ),
    );
  }
}
