import 'dart:ui';
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
  final int _frameCount = 24;
  final GlobalKey<CameraPreviewState> _cameraKey = GlobalKey();
  
  // Camera state
  FlashMode _flashMode = FlashMode.off;
  late FixedExtentScrollController _rollController;
  late List<CameraModel> _allCameras;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _allCameras = CameraRepository.getAllCameras();
    
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
          // Camera Preview with Live Filter
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(selectedCamera.pipeline.toColorMatrix()),
              child: CameraPreviewWidget(
                key: _cameraKey,
                onCameraReady: (controller) {},
              ),
            ),
          ),

          // Film effect overlay (grain, date, etc)
          Positioned.fill(
            child: FilmEffectOverlay(
              camera: selectedCamera,
              frameCount: _frameCount,
              aspectRatio: aspectRatio,
            ),
          ),

          // UI Layers
          SafeArea(
            child: Column(
              children: [
                _buildRoyalHeader(theme, aspectRatio),
                const Spacer(),
                
                // Horizontal Film Roll (Above Controls)
                _buildHorizontalFilmRoll(theme),
                
                _buildRoyalControls(theme, selectedCamera, aspectRatio),
              ],
            ),
          ),
          
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: GlassContainer.clearGlass(
                    width: 120,
                    height: 120,
                    borderRadius: BorderRadius.circular(20),
                    borderColor: Colors.transparent, // Fix for assertion
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: AppColors.accentGold),
                        const SizedBox(height: 16),
                        Text('DEVELOPING...', 
                          style: AppTypography.monoSmall.copyWith(color: AppColors.accentGold, letterSpacing: 2)),
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

  Widget _buildRoyalHeader(ThemeData theme, String aspectRatio) {
    final canPop = Navigator.canPop(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: FadeInDown(
        duration: const Duration(milliseconds: 800),
        child: Row(
          children: [
            if (canPop)
              _glassIconButton(
                icon: Icons.close_rounded,
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 44), // Maintain layout balance
            
            const Spacer(),
            
            // Minimal Centered Logo
            Text(
              'FILMCAM',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                letterSpacing: 8,
                fontWeight: FontWeight.w900,
                color: AppColors.accentGold,
              ),
            ),

            const Spacer(),

            Row(
              children: [
                _glassIconButton(
                  icon: _flashMode == FlashMode.off ? Icons.flash_off_rounded : 
                        _flashMode == FlashMode.always ? Icons.flash_on_rounded : Icons.flash_auto_rounded,
                  color: _flashMode != FlashMode.off ? AppColors.accentGold : Colors.white,
                  onPressed: _toggleFlash,
                ),
                const SizedBox(width: 4),
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

  Widget _buildHorizontalFilmRoll(ThemeData theme) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 10),
      child: RotatedBox(
        quarterTurns: -1,
        child: ListWheelScrollView.useDelegate(
          controller: _rollController,
          itemExtent: 140, // Width in horizontal mode
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
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Selection Indicator
                        if (isSelected)
                          FadeInDown(
                            duration: const Duration(milliseconds: 400),
                            from: 10,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              height: 2,
                              width: 30,
                              decoration: BoxDecoration(
                                color: AppColors.accentGold,
                                borderRadius: BorderRadius.circular(1),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentGold.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                        // Focused Item Name
                        Text(
                          camera.name.toUpperCase(),
                          style: GoogleFonts.cinzel(
                            color: isSelected ? Colors.white : Colors.white24,
                            fontSize: isSelected ? 18 : 12,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
                            letterSpacing: 4,
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Personality Tag
                        if (isSelected)
                          FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            from: 5,
                            child: Text(
                              camera.personality.toUpperCase(),
                              style: GoogleFonts.spaceMono(
                                color: AppColors.accentGold,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
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

  Widget _buildRoyalControls(ThemeData theme, CameraModel selectedCamera, String aspectRatio) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(
            icon: Icons.photo_library_rounded,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen())),
          ),
          
          ShutterButton(
            onPressed: () => _capturePhoto(selectedCamera, aspectRatio),
            isProcessing: _isProcessing,
          ),
          _controlButton(
            icon: Icons.flip_camera_ios_rounded,
            onPressed: _switchCamera,
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
      child: GlassContainer.clearGlass(
        width: 60,
        height: 60,
        borderRadius: BorderRadius.circular(30),
        borderWidth: 1,
        borderColor: Colors.white10,
        child: Center(
          child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
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
            final photoFile = File(image.path);
            
            if (selectedCamera.pipeline.instantFilm) {
              // Navigate to Instant Development Screen
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
          initialCamera: selectedCamera,
          initialAspectRatio: ref.read(settingsProvider).aspectRatio,
        ),
      ),
    );
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
