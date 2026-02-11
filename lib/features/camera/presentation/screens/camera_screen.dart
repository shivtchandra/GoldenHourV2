import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:camera/camera.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../../data/models/camera_model.dart';
import '../../data/repositories/camera_repository.dart';
import '../../data/models/pipeline_config.dart';
import '../widgets/shutter_button.dart';
import '../widgets/film_effect_overlay.dart';
import '../widgets/camera_preview_widget.dart';
import '../widgets/preset_carousel.dart';
import 'dart:io';
import 'camera_selector_screen.dart';
import '../../../develop/presentation/screens/develop_screen.dart';
import '../../../gallery/presentation/screens/gallery_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../presets/data/models/preset_model.dart';
import '../../../presets/data/repositories/preset_repository.dart';
import '../../providers/settings_provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import '../../../../core/services/image_processing_service.dart';
import 'instant_development_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final PresetModel? initialPreset;

  const CameraScreen({
    super.key,
    this.initialPreset,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isProcessing = false;
  int _frameCount = 0;
  final GlobalKey<CameraPreviewState> _cameraKey = GlobalKey();

  // Camera state
  FlashMode _flashMode = FlashMode.off;
  late FixedExtentScrollController _rollController;
  late List<CameraModel> _allCameras;
  bool _isScrolling = false;

  // Focus indicator state
  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  // Preset mode state
  PresetModel? _selectedPreset;
  bool _showGrid = true;

  // Mode detection helpers
  bool get isPresetMode => _selectedPreset != null;
  bool get isCameraMode => _selectedPreset == null;

  @override
  void initState() {
    super.initState();
    _allCameras = CameraRepository.getAllCameras();

    // Initialize preset if provided
    _selectedPreset = widget.initialPreset;

    // Initialize controller with current camera index
    final settings = ref.read(settingsProvider);
    final initialIndex = _allCameras.indexWhere((c) => c.id == settings.activeCameraId);
    _rollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final selectedCamera = CameraRepository.getAllCameras().firstWhere(
      (c) => c.id == settings.activeCameraId,
      orElse: () => CameraRepository.getAllCameras().first,
    );
    final aspectRatio = settings.aspectRatio;

    // Sync roll position if changed externally (e.g. from Presets screen)
    ref.listen(settingsProvider, (previous, next) {
      if (previous?.activeCameraId != next.activeCameraId) {
        final index = _allCameras.indexWhere((c) => c.id == next.activeCameraId);
        if (index >= 0 && _rollController.hasClients && _rollController.selectedItem != index) {
          _rollController.animateToItem(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview with Live Filter (respects aspect ratio)
          Positioned.fill(
            child: Center(
              child: _buildFilteredCameraPreview(selectedCamera, aspectRatio),
            ),
          ),

          // Film effect overlay (grain, vignette, etc)
          Positioned.fill(
            child: FilmEffectOverlay(
              camera: selectedCamera,
              frameCount: _frameCount,
              aspectRatio: aspectRatio,
            ),
          ),

          // Rule of Thirds Grid
          if (_showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: _buildGridOverlay(),
              ),
            ),

          // UI Layers - Responsive to screen height
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive spacing based on screen height
                final screenHeight = constraints.maxHeight;
                final isCompactScreen = screenHeight < 600;
                final bottomPadding = isCompactScreen ? 8.0 : 16.0;
                final selectorSpacing = isCompactScreen ? 4.0 : 8.0;

                return Column(
                  children: [
                    _buildRoyalHeader(theme, aspectRatio),
                    const Spacer(),

                    // Bottom UI Group - Responsive padding
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Selector (Film Roll or Preset Carousel)
                          _buildSelector(theme, isCompact: isCompactScreen),
                          SizedBox(height: selectorSpacing),
                          _buildRoyalControls(theme, selectedCamera, aspectRatio, isCompact: isCompactScreen),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          if (_isProcessing)
            Positioned.fill(
              child: FadeIn(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Lens Shutter Icon
                        BounceInDown(
                          duration: const Duration(milliseconds: 1000),
                          child: Icon(
                            isPresetMode ? Icons.auto_awesome_rounded : Icons.camera_rounded,
                            color: AppColors.accentGold,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Processing Text
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            'DEVELOPING FILM...',
                            style: GoogleFonts.cinzel(
                              color: AppColors.accentGold,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtext
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            isPresetMode ? 'APPLYING PREMIUM PRESET' : 'PROCESSING PHOTOCK CHEMICALS',
                            style: GoogleFonts.spaceMono(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        // Progress line
                        Container(
                          width: 200,
                          height: 2,
                          child: const LinearProgressIndicator(
                            backgroundColor: Colors.white10,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the camera preview with live filter applied
  /// Uses selectedCamera from build() context for proper state reactivity
  Widget _buildFilteredCameraPreview(CameraModel selectedCamera, String aspectRatio) {
    // Determine which pipeline to use based on mode
    final PipelineConfig pipeline;
    if (isPresetMode && _selectedPreset != null) {
      pipeline = _selectedPreset!.pipeline;
    } else {
      pipeline = selectedCamera.pipeline;
    }

    final colorMatrix = pipeline.toColorMatrix();

    // Calculate target aspect ratio for preview crop
    double? targetRatio;
    if (aspectRatio == '4:5') targetRatio = 4 / 5;
    else if (aspectRatio == '16:9') targetRatio = 16 / 9;
    else if (aspectRatio == '1:1') targetRatio = 1.0;
    else if (aspectRatio == '3:4') targetRatio = 3 / 4;

    // Apply ColorFiltered with aspect ratio crop
    Widget preview = ColorFiltered(
      colorFilter: ColorFilter.matrix(colorMatrix),
      child: CameraPreviewWidget(
        key: _cameraKey,
        onCameraReady: (controller) {},
      ),
    );

    // If specific aspect ratio selected, crop preview to match output
    if (targetRatio != null) {
      preview = ClipRect(
        child: AspectRatio(
          aspectRatio: targetRatio,
          child: preview,
        ),
      );
    }

    // Wrap with GestureDetector for pinch-to-zoom AND tap-to-focus
    return GestureDetector(
      onScaleStart: (_) {
        _cameraKey.currentState?.onZoomStart();
      },
      onScaleUpdate: (details) {
        if (details.scale != 1.0) {
          _cameraKey.currentState?.onZoomUpdate(details.scale);
        }
      },
      onTapUp: (details) {
        _handleTapToFocus(details.localPosition, context);
      },
      child: Stack(
        children: [
          preview,
          // Focus indicator
          if (_showFocusIndicator && _focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 40,
              top: _focusPoint!.dy - 40,
              child: _buildFocusIndicator(),
            ),
        ],
      ),
    );
  }

  /// Handle tap to focus
  void _handleTapToFocus(Offset localPosition, BuildContext context) {
    // Get the size of the preview area
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final size = box.size;

    // Calculate normalized coordinates (0.0 to 1.0)
    final x = localPosition.dx / size.width;
    final y = localPosition.dy / size.height;

    // Set focus point on camera
    _cameraKey.currentState?.setFocusPoint(x, y);

    // Show focus indicator
    setState(() {
      _focusPoint = localPosition;
      _showFocusIndicator = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Hide indicator after animation
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showFocusIndicator = false;
        });
      }
    });
  }

  /// Build the focus indicator widget
  Widget _buildFocusIndicator() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.5, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.accentGold,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoyalHeader(ThemeData theme, String aspectRatio) {
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Row(
          children: [
            // Left button
            if (canPop)
              _glassIconButton(
                icon: Icons.close_rounded,
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),

            // Center title - use Expanded to prevent overflow
            Expanded(
              child: Text(
                isPresetMode ? 'PRESETS' : 'CAMERA FILMS',
                style: GoogleFonts.cinzel(
                  fontSize: 13,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w900,
                  color: AppColors.accentGold.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Right buttons - wrap in row with mainAxisSize.min
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _glassIconButton(
                  icon: _showGrid ? Icons.grid_on_rounded : Icons.grid_off_rounded,
                  color: _showGrid ? AppColors.accentGold : Colors.white,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _showGrid = !_showGrid);
                  },
                ),
                _glassIconButton(
                  icon: _flashMode == FlashMode.off ? Icons.flash_off_rounded :
                        _flashMode == FlashMode.always ? Icons.flash_on_rounded : Icons.flash_auto_rounded,
                  color: _flashMode != FlashMode.off ? AppColors.accentGold : Colors.white,
                  onPressed: _toggleFlash,
                ),
                _glassIconButton(
                  icon: Icons.aspect_ratio_rounded,
                  label: aspectRatio,
                  onPressed: _toggleAspectRatio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return CustomPaint(
      painter: GridPainter(color: Colors.white.withOpacity(0.15)),
    );
  }

  Widget _glassIconButton({
    required IconData icon, 
    required VoidCallback onPressed, 
    String? label,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: GlassContainer.clearGlass(
        width: label != null ? 70 : 44,
        height: 44,
        borderRadius: BorderRadius.circular(22),
        borderWidth: 1,
        borderColor: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Switch between camera film roll and preset carousel based on mode
  Widget _buildSelector(ThemeData theme, {bool isCompact = false}) {
    if (isPresetMode) {
      return _buildPresetSelector(isCompact: isCompact);
    } else {
      return _buildHorizontalFilmRoll(theme, isCompact: isCompact);
    }
  }

  /// Build preset selector with mode indicator and carousel
  Widget _buildPresetSelector({bool isCompact = false}) {
    if (_selectedPreset == null) return const SizedBox();

    return Column(
      children: [
        // Preset carousel
        PresetCarousel(
          selectedPreset: _selectedPreset!,
          onPresetSelected: (preset) {
            setState(() => _selectedPreset = preset);
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalFilmRoll(ThemeData theme, {bool isCompact = false}) {
    final height = isCompact ? 85.0 : 110.0; // Responsive height
    return Container(
      height: height,
      child: RotatedBox(
        quarterTurns: -1,
        child: ListWheelScrollView.useDelegate(
          controller: _rollController,
          itemExtent: 160, // Wider items for better spacing
          perspective: 0.003,
          diameterRatio: 1.8,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            HapticFeedback.selectionClick();
            final camera = _allCameras[index];
            ref.read(settingsProvider.notifier).setActiveCamera(camera.id);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: _allCameras.length,
            builder: (context, index) {
              final camera = _allCameras[index];
              final settings = ref.watch(settingsProvider);
              final isSelected = settings.activeCameraId == camera.id;
              
              return RotatedBox(
                quarterTurns: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 160, // Fixed width to prevent overflow
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated Selection Indicator (The Dash)
                        if (isSelected)
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            from: 5,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              height: 2.5,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppColors.accentGold,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),

                        // Focused Item Name - single line with ellipsis
                        Text(
                          camera.name.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            color: isSelected ? Colors.white : Colors.white24,
                            fontSize: isSelected ? 16 : 11,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Personality Tag
                        if (isSelected)
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            from: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                camera.personality.toUpperCase(),
                                style: GoogleFonts.spaceMono(
                                  color: AppColors.accentGold.withOpacity(0.9),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRoyalControls(ThemeData theme, CameraModel selectedCamera, String aspectRatio, {bool isCompact = false}) {
    final height = isCompact ? 80.0 : 100.0; // Responsive height
    return Container(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Row for side buttons - Pushed to edges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _controlButton(
                  icon: Icons.photo_library_outlined,
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
                ),
                _controlButton(
                  icon: Icons.flip_camera_ios_outlined,
                  onPressed: _switchCamera,
                ),
              ],
            ),
          ),

          // Central Shutter Group - Absolutely Centered
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // This is the anchor. We show the sparkle button on the right 
              // and a matching transparent spacer on the left to maintain 100% center
              const SizedBox(width: 70), // Balance for the Preset button
              
              ShutterButton(
                onPressed: () => _capturePhoto(selectedCamera, aspectRatio),
                isProcessing: _isProcessing,
              ),

              // Mode Toggle (Sparkle or Camera Return)
              SizedBox(
                width: 70,
                child: Center(
                  child: _controlButton(
                    icon: !isPresetMode ? Icons.auto_awesome_outlined : Icons.photo_camera_outlined,
                    onPressed: () {
                      if (!isPresetMode) {
                        final allPresets = PresetRepository.getAllPresets();
                        if (allPresets.isNotEmpty) {
                          setState(() => _selectedPreset = allPresets.first);
                        }
                      } else {
                        setState(() => _selectedPreset = null);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  void _openCameraSelector() async {
    final settings = ref.read(settingsProvider);
    final currentCamera = CameraRepository.getAllCameras().firstWhere(
      (c) => c.id == settings.activeCameraId,
      orElse: () => CameraRepository.getAllCameras().first,
    );

    final selectedCamera = await Navigator.push<CameraModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraSelectorScreen(
          currentCamera: currentCamera,
        ),
      ),
    );

    if (selectedCamera != null && mounted) {
      ref.read(settingsProvider.notifier).setActiveCamera(selectedCamera.id);
    }
  }

  void _toggleFlash() {
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.auto;
      } else {
        _flashMode = FlashMode.off;
      }
    });
    _cameraKey.currentState?.setFlashMode(_flashMode);
  }

  void _toggleAspectRatio() {
    final current = ref.read(settingsProvider).aspectRatio;
    String next = '3:4';
    if (current == '3:4') next = '1:1';
    else if (current == '1:1') next = '16:9';
    else if (current == '16:9') next = '4:5';
    else next = '3:4';
    
    ref.read(settingsProvider.notifier).setAspectRatio(next);
    HapticFeedback.mediumImpact();
  }

  Future<void> _switchCamera() async {
    HapticFeedback.mediumImpact();
    final state = _cameraKey.currentState;
    if (state != null) {
      await state.switchCamera();
      // Re-apply flash mode after switch
      await state.setFlashMode(_flashMode);
    }
  }

  Future<void> _capturePhoto(CameraModel selectedCamera, String aspectRatio) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    HapticFeedback.heavyImpact();

    try {
      final state = _cameraKey.currentState;
      if (state != null) {
        final image = await state.captureImage();
        if (image != null) {
          if (mounted) {
            // SIMPLIFIED: Pass original file directly to DevelopScreen
            // DevelopScreen will handle display using native Image.file (no processing needed for display)
            // Processing for effects happens separately and safely
            final photoFile = File(image.path);
            
            // When in preset mode, always go to DevelopScreen with the preset applied
            // (presets don't use instant film mode)
            if (isPresetMode) {
              setState(() => _isProcessing = false);
              _navigateToDevelop(selectedCamera, photoFile: photoFile);
            } else if (selectedCamera.pipeline.instantFilm) {
              // Navigate to Instant Development Screen for instant film cameras
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InstantDevelopmentScreen(
                    imageFile: photoFile,
                    camera: selectedCamera,
                    aspectRatio: ref.read(settingsProvider).aspectRatio,
                  ),
                ),
              );
              setState(() => _isProcessing = false);
              HapticFeedback.vibrate();
            } else if (ref.read(settingsProvider).autoSave) {
              // Auto-Save background processing
              final savedPath = await PhotoStorageService.instance.savePhoto(
                sourcePath: photoFile.path,
                cameraName: selectedCamera.name,
                cameraId: selectedCamera.id,
              );
              
              if (mounted) {
                setState(() => _isProcessing = false);
                if (savedPath != null) {
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black87,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.accentGold, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'SAVED TO GALLERY',
                            style: GoogleFonts.spaceMono(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            } else {
              setState(() => _isProcessing = false);
              _navigateToDevelop(selectedCamera, photoFile: photoFile);
            }
          }
        } else {
          if (mounted) setState(() => _isProcessing = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to develop: $e')),
        );
      }
    }
  }

  void _navigateToDevelop(CameraModel selectedCamera, {File? photoFile}) {
    if (photoFile == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevelopScreen(
          imageFile: photoFile,
          initialCamera: isCameraMode ? selectedCamera : null,
          initialPreset: isPresetMode ? _selectedPreset : null,
          initialAspectRatio: ref.read(settingsProvider).aspectRatio,
        ),
      ),
    );
  }

  /// Resize captured image to prevent memory issues on real devices
  /// Real phones can capture 12-48MP images which exhaust memory during processing
  Future<File> _resizeImageIfNeeded(File originalFile) async {
    try {
      final bytes = await originalFile.readAsBytes();
      debugPrint('CameraScreen: Original image size: ${bytes.length} bytes');

      // Decode and check size
      final decoded = await compute(_decodeAndResize, bytes);
      if (decoded == null) {
        debugPrint('CameraScreen: Failed to decode, returning original');
        return originalFile;
      }

      // Write resized image to a new temp file
      final tempDir = originalFile.parent;
      final resizedFile = File('${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await resizedFile.writeAsBytes(decoded);

      debugPrint('CameraScreen: Resized image size: ${decoded.length} bytes');
      return resizedFile;
    } catch (e) {
      debugPrint('CameraScreen: Resize error: $e, returning original');
      return originalFile;
    }
  }

  /// Static method for compute isolate - decodes and resizes image
  static Uint8List? _decodeAndResize(Uint8List bytes) {
    try {
      var decoded = img.decodeJpg(bytes);
      if (decoded == null) {
        decoded = img.decodeImage(bytes);
      }
      if (decoded == null) return null;

      // Apply EXIF rotation
      decoded = img.bakeOrientation(decoded);

      // Resize if too large (max 1200px for processing safety)
      const int maxDimension = 1200;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        if (decoded.width > decoded.height) {
          decoded = img.copyResize(decoded, width: maxDimension);
        } else {
          decoded = img.copyResize(decoded, height: maxDimension);
        }
      }

      // Encode back to JPEG with good quality
      return Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
    } catch (e) {
      return null;
    }
  }

  List<double> _getColorMatrix(PipelineConfig pipeline) {
    double contrast = 1.0 + pipeline.contrastBias;
    double saturation = pipeline.saturation;
    double exposure = 1.0 + (pipeline.exposureBias * 0.1);
    
    // Contrast adjustment
    double t = (1.0 - contrast) / 2.0;

    // Temperature (simple approximation)
    double rMod = 1.0;
    double gMod = 1.0;
    double bMod = 1.0;
    
    if (pipeline.temperature > 0) {
      rMod += pipeline.temperature / 150;
      gMod += pipeline.temperature / 300;
      bMod -= pipeline.temperature / 300;
    } else {
      rMod += pipeline.temperature / 300;
      bMod -= pipeline.temperature / 150;
    }

    // Saturation matrix (standard coefficients)
    const double lumR = 0.2126;
    const double lumG = 0.7152;
    const double lumB = 0.0722;

    double sr = (1 - saturation) * lumR;
    double sg = (1 - saturation) * lumG;
    double sb = (1 - saturation) * lumB;

    // Combine adjustments
    double finalR = contrast * rMod * exposure;
    double finalG = contrast * gMod * exposure;
    double finalB = contrast * bMod * exposure;

    if (pipeline.blackWhiteMode) {
      return [
        lumR, lumG, lumB, 0, 0,
        lumR, lumG, lumB, 0, 0,
        lumR, lumG, lumB, 0, 0,
        0, 0, 0, 1, 0,
      ];
    }

    return [
      finalR * (sr + saturation), finalR * sg, finalR * sb, 0, t * 255,
      finalG * sr, finalG * (sg + saturation), finalG * sb, 0, t * 255,
      finalB * sr, finalB * sg, finalB * (sb + saturation), 0, t * 255,
      0, 0, 0, 1, 0,
    ];
  }

  // Static processing task for high-res images to run in a background isolate
  static img.Image _processImageTask(Map<String, dynamic> data) {
    final Uint8List bytes = data['bytes'];
    final PipelineConfig pipeline = data['pipeline'];
    final String aspectRatio = data['aspectRatio'] ?? 'Original';
    
    final img.Image? input = img.decodeImage(bytes);
    if (input == null) return img.Image(width: 1, height: 1);

    img.Image working = img.Image.from(input);

    // Apply Aspect Ratio Crop
    if (aspectRatio != 'Original') {
      double targetRatio = 1.0;
      if (aspectRatio == '4:5') targetRatio = 4 / 5;
      else if (aspectRatio == '16:9') targetRatio = 16 / 9;
      else if (aspectRatio == '1:1') targetRatio = 1 / 1;
      else if (aspectRatio == '3:4') targetRatio = 3 / 4;

      int w = working.width;
      int h = working.height;
      double currentRatio = w / h;

      if ((currentRatio - targetRatio).abs() > 0.01) {
        if (currentRatio > targetRatio) {
          int targetW = (h * targetRatio).toInt();
          int offset = (w - targetW) ~/ 2;
          working = img.copyCrop(working, x: offset, y: 0, width: targetW, height: h);
        } else {
          int targetH = (w / targetRatio).toInt();
          int offset = (h - targetH) ~/ 2;
          working = img.copyCrop(working, x: 0, y: offset, width: w, height: targetH);
        }
      }
    }

    // Apply Effects via Service
    return ImageProcessingService().applyFilmEffect(
      inputImage: working,
      pipeline: pipeline,
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Main grid lines - more visible
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)  // Increased visibility
      ..strokeWidth = 1.0;  // Thicker lines

    // Vertical lines (rule of thirds)
    canvas.drawLine(Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(2 * size.width / 3, 0), Offset(2 * size.width / 3, size.height), paint);

    // Horizontal lines (rule of thirds)
    canvas.drawLine(Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, 2 * size.height / 3), Offset(size.width, 2 * size.height / 3), paint);

    // Optional: Add intersection dots for better visibility
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final dotRadius = 3.0;
    // Top-left intersection
    canvas.drawCircle(Offset(size.width / 3, size.height / 3), dotRadius, dotPaint);
    // Top-right intersection
    canvas.drawCircle(Offset(2 * size.width / 3, size.height / 3), dotRadius, dotPaint);
    // Bottom-left intersection
    canvas.drawCircle(Offset(size.width / 3, 2 * size.height / 3), dotRadius, dotPaint);
    // Bottom-right intersection
    canvas.drawCircle(Offset(2 * size.width / 3, 2 * size.height / 3), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
