import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../app/theme/colors.dart';
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
import '../../../presets/presentation/screens/presets_screen.dart';
import '../../../develop/presentation/screens/develop_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../camera/providers/settings_provider.dart';
import '../../../../core/services/photo_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  List<PhotoInfo> _recentPhotos = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    try {
      // Removed local _selectedCamera initialization as it's now handled by Riverpod

      // Fetch recent photos
      _recentPhotos = await PhotoStorageService.instance.getAllPhotos();
      
      _isLoading = false;
    } catch (e) {
      _error = e.toString();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text("ERROR: $_error", style: const TextStyle(color: Colors.red))),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppColors.accentGold)),
      );
    }

    final theme = Theme.of(context);

    return Consumer(
      builder: (context, ref, child) {
        final settings = ref.watch(settingsProvider);
        final currentCamera = CameraRepository.getAllCameras().firstWhere(
          (c) => c.id == settings.activeCameraId,
          orElse: () => CameraRepository.getAllCameras().first,
        );

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              _buildBackgroundGlows(theme),
              IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeContent(theme, currentCamera),
                  CameraSelectorScreen(
                    currentCamera: currentCamera,
                    onCameraSelected: (camera) {
                      ref.read(settingsProvider.notifier).setActiveCamera(camera.id);
                      setState(() => _currentIndex = 0);
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
            ],
          ),
          bottomNavigationBar: _buildRoyalDock(theme),
        );
      },
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

  Widget _buildHomeContent(ThemeData theme, CameraModel currentCamera) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 24),
            FadeInLeft(
              duration: const Duration(milliseconds: 800),
              child: _buildGreeting(theme),
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
              child: _buildRecentShotsList(theme, currentCamera),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Spacer to keep title centered
          Text(
            'FILMCAM',
            style: AppTypography.displayMedium.copyWith(
              fontSize: 24,
              color: theme.colorScheme.primary,
              letterSpacing: 4,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5), width: 1.5),
            ),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                radius: 18,
                child: Text(
                  'S',
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

  Widget _buildGreeting(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting = 'GOOD MORNING';
    if (hour >= 12 && hour < 17) greeting = 'GOOD AFTERNOON';
    if (hour >= 17) greeting = 'GOOD EVENING';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.accentGold.withOpacity(0.6),
              fontSize: 14,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MASTERPIECES.',
            style: AppTypography.displayLarge.copyWith(
              color: Colors.white,
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
            GlassContainer.clearGlass(
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
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                CameraRepository.toggleFavorite(currentCamera.id);
                              });
                            },
                            icon: Icon(
                              CameraRepository.isFavorite(currentCamera.id) 
                                  ? Icons.favorite_rounded 
                                  : Icons.favorite_border_rounded,
                              color: CameraRepository.isFavorite(currentCamera.id) 
                                  ? Colors.redAccent 
                                  : Colors.white.withOpacity(0.6),
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
                    ).shimmer(duration: const Duration(seconds: 3), color: Colors.white.withOpacity(0.3)),
                  ),
                  const Spacer(),
                  Text(
                    currentCamera.name.toUpperCase(),
                    style: AppTypography.displayMedium.copyWith(
                      fontSize: 28,
                      letterSpacing: 2,
                      color: Colors.white,
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
                        color: Colors.white.withOpacity(0.8),
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
                child: GlassContainer.clearGlass(
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
                            color: AppColors.accentGold,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accentGold, size: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACCESS',
            style: AppTypography.monoSmall.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
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
              }),
              _royalActionItem(theme, 'LENSES', Icons.auto_awesome_motion_rounded, () {
                setState(() => _currentIndex = 1);
              }),
              _royalActionItem(theme, 'PRESETS', Icons.auto_awesome_rounded, () {
                setState(() => _currentIndex = 2);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _royalActionItem(ThemeData theme, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          GlassContainer.clearGlass(
            width: 80,
            height: 80,
            borderRadius: BorderRadius.circular(24),
            borderWidth: 1,
            borderColor: Colors.transparent,
            child: Icon(icon, color: theme.colorScheme.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              fontSize: 10,
              letterSpacing: 2,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
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
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildFavoritesList(ThemeData theme, CameraModel currentCamera) {
    final favorites = CameraRepository.getFavoriteCameras();
    
    if (favorites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassContainer.clearGlass(
          height: 100,
          width: double.infinity,
          borderRadius: BorderRadius.circular(24),
          borderWidth: 1,
          borderColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded, color: Colors.white.withOpacity(0.3), size: 32),
              const SizedBox(height: 8),
              Text(
                'NO FAVORITES YET',
                style: AppTypography.labelMedium.copyWith(color: Colors.white38, letterSpacing: 2),
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
              child: GlassContainer.clearGlass(
                width: 110,
                height: 140,
                borderRadius: BorderRadius.circular(24),
                borderWidth: isSelected ? 2 : 1,
                borderColor: isSelected ? AppColors.accentGold : Colors.transparent,
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
                          color: Colors.white.withOpacity(0.9),
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

  Widget _buildRecentShotsList(ThemeData theme, CameraModel currentCamera) {
    if (_recentPhotos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassContainer.clearGlass(
          height: 160,
          width: double.infinity,
          borderRadius: BorderRadius.circular(24),
          borderWidth: 1,
          borderColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, color: Colors.white.withOpacity(0.2), size: 40),
              const SizedBox(height: 12),
              Text(
                'NO CAPTURES YET',
                style: AppTypography.labelMedium.copyWith(color: Colors.white24, letterSpacing: 2),
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
        itemCount: _recentPhotos.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final photo = _recentPhotos[index];
          
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
                    color: AppColors.accentGold.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  photo.formattedTime.toUpperCase(),
                  style: AppTypography.labelMedium.copyWith(
                    fontSize: 10,
                    color: Colors.white54,
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
      child: GlassContainer.clearGlass(
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
          color: (active && index < 3) ? theme.colorScheme.primary : Colors.white.withOpacity(0.4),
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
