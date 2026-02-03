# 📷 Film Camera App - Flutter Development Specification
## Part 4: Complete Widget Examples & Final Implementation

---

## 🎨 Core UI Widgets

### 1. Camera Card Widget

```dart
// lib/features/camera/presentation/widgets/camera_card.dart

import 'package:flutter/material.dart';
import '../../data/models/camera_model.dart';

class CameraCard extends StatelessWidget {
  final CameraModel camera;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback onTap;

  const CameraCard({
    Key? key,
    required this.camera,
    this.isSelected = false,
    this.isUnlocked = true,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked 
                ? [
                    camera.iconColor.withOpacity(0.3),
                    camera.iconColor.withOpacity(0.1),
                  ]
                : [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
              ? Border.all(color: AppColors.accentGold, width: 3)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 4,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Grain texture overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('assets/textures/grain.png'),
                  fit: BoxFit.cover,
                  opacity: 0.05,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Icon
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 3D Camera Icon
                          Image.asset(
                            camera.icon3DAssetPath ?? 'assets/camera_icons/default.png',
                            height: 80,
                            color: isUnlocked ? null : Colors.grey,
                            colorBlendMode: isUnlocked ? null : BlendMode.saturation,
                          ),
                          
                          // Lock overlay for locked cameras
                          if (!isUnlocked)
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Camera Name
                  Text(
                    camera.name,
                    style: AppTypography.headlineMedium.copyWith(
                      fontSize: 16,
                      color: isUnlocked ? AppColors.textPrimaryDark : Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 4),
                  
                  // ISO Badge
                  if (camera.iso != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ISO ${camera.iso}',
                        style: AppTypography.monoMedium.copyWith(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  
                  SizedBox(height: 8),
                  
                  // Pro Badge or Price
                  if (camera.isPro && !isUnlocked)
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: AppColors.accentGold),
                        SizedBox(width: 4),
                        Text(
                          camera.price ?? 'PRO',
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 12,
                            color: AppColors.accentGold,
                          ),
                        ),
                      ],
                    )
                  else if (camera.isPro)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PRO',
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Shutter Button Widget

```dart
// lib/features/camera/presentation/widgets/shutter_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShutterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isProcessing;

  const ShutterButton({
    Key? key,
    required this.onPressed,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() {
    if (widget.isProcessing) return;
    
    setState(() => _isPressed = true);
    HapticFeedback.heavyImpact();
    _controller.forward(from: 0);
    
    // Play shutter sound
    // AudioPlayer.play('assets/sounds/shutter.mp3');
    
    widget.onPressed();
    
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) setState(() => _isPressed = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _handlePress(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accentFilmRed,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentFilmRed.withOpacity(0.3),
                    blurRadius: _isPressed ? 20 : 10,
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
              ),
              child: Container(
                margin: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                ),
                child: widget.isProcessing
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.accentFilmRed,
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 3. Film Effect Preview Overlay

```dart
// lib/features/camera/presentation/widgets/film_effect_overlay.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class FilmEffectOverlay extends StatefulWidget {
  final CameraModel camera;
  final double opacity;

  const FilmEffectOverlay({
    Key? key,
    required this.camera,
    this.opacity = 0.6,
  }) : super(key: key);

  @override
  State<FilmEffectOverlay> createState() => _FilmEffectOverlayState();
}

class _FilmEffectOverlayState extends State<FilmEffectOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _grainController;

  @override
  void initState() {
    super.initState();
    _grainController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _grainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Grain animation
          if (widget.camera.pipeline.grainStrength > 0)
            AnimatedBuilder(
              animation: _grainController,
              builder: (context, child) {
                return Opacity(
                  opacity: widget.opacity * widget.camera.pipeline.grainStrength,
                  child: Image.asset(
                    'assets/textures/grain_animated.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    colorBlendMode: BlendMode.overlay,
                  ),
                );
              },
            ),
          
          // Vignette
          if (widget.camera.pipeline.vignetteStrength > 0)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(
                      widget.opacity * widget.camera.pipeline.vignetteStrength,
                    ),
                  ],
                ),
              ),
            ),
          
          // Frame counter (top right)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '24', // Could be dynamic based on shots taken
                style: AppTypography.monoMedium.copyWith(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          
          // Camera info overlay (bottom)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Color temperature indicator
                  if (widget.camera.pipeline.temperature != 0)
                    Row(
                      children: [
                        Icon(
                          widget.camera.pipeline.temperature > 0
                              ? Icons.wb_sunny
                              : Icons.ac_unit,
                          color: widget.camera.pipeline.temperature > 0
                              ? Colors.orange
                              : Colors.blue,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${widget.camera.pipeline.temperature.round()}K',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📱 Complete Screen Implementations

### Camera Screen

```dart
// lib/features/camera/presentation/screens/camera_screen.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  CameraModel? _selectedCamera;
  bool _isProcessing = false;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _selectedCamera = CameraRepository.getFreeCameras().first;
  }
  
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    
    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }
  
  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    setState(() => _isProcessing = true);
    
    try {
      final image = await _cameraController!.takePicture();
      
      // Process image with selected camera effect
      // Navigate to preview screen
      
    } catch (e) {
      print('Error capturing photo: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Camera Preview with Effect Overlay
            Expanded(
              child: Stack(
                children: [
                  CameraPreview(_cameraController!),
                  if (_selectedCamera != null)
                    FilmEffectOverlay(camera: _selectedCamera!),
                ],
              ),
            ),
            
            // Camera Info Bar
            _buildInfoBar(),
            
            // Controls
            _buildControls(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              // Open drawer
            },
          ),
          Text(
            'FILMCAM',
            style: AppTypography.displayMedium.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.photo_library, color: Colors.white),
                onPressed: () {
                  // Open gallery
                },
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  // Open settings
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoBar() {
    if (_selectedCamera == null) return SizedBox.shrink();
    
    return GestureDetector(
      onTap: () {
        // Show camera details bottom sheet
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border(
            top: BorderSide(color: Colors.white24, width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedCamera!.iconColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.camera_alt,
                color: _selectedCamera!.iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCamera!.name,
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_selectedCamera!.type}${_selectedCamera!.iso != null ? " • ISO ${_selectedCamera!.iso}" : ""}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            icon: Icon(Icons.photo, color: Colors.white, size: 32),
            onPressed: () {
              // Open gallery
            },
          ),
          
          // Shutter button
          ShutterButton(
            onPressed: _capturePhoto,
            isProcessing: _isProcessing,
          ),
          
          // Switch camera button
          IconButton(
            icon: Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
            onPressed: () {
              // Switch front/back camera
            },
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}
```

---

## 💰 In-App Purchase Implementation

```dart
// lib/core/services/purchase_service.dart

import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  
  // Product IDs
  static const String CAMERA_SINGLE_PREFIX = 'camera_';
  static const String ALL_PRO_BUNDLE = 'all_pro_cameras';
  
  Future<bool> purchaseCamera(String cameraId) async {
    final productId = '$CAMERA_SINGLE_PREFIX$cameraId';
    
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails({productId});
      
      if (response.productDetails.isEmpty) {
        return false;
      }
      
      final product = response.productDetails.first;
      final purchaseParam = PurchaseParam(productDetails: product);
      
      await _iap.buyConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }
  
  Future<bool> isCameraUnlocked(String cameraId) async {
    // Check if camera is purchased
    // This would typically check against your backend or local storage
    return false; // Implement actual logic
  }
  
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}
```

---

## 🎯 Performance Optimization Tips

### 1. Image Processing Optimization

```dart
// Use isolates for heavy processing
Future<img.Image> processImageInBackground(
  img.Image input,
  PipelineConfig pipeline,
) async {
  return await compute(_processImage, {
    'image': input,
    'pipeline': pipeline,
  });
}

static img.Image _processImage(Map<String, dynamic> data) {
  final service = ImageProcessingService();
  return service.applyFilmEffect(
    inputImage: data['image'],
    pipeline: data['pipeline'],
  );
}
```

### 2. Real-time Preview Optimization

```dart
// Use lower resolution for preview
Future<ui.Image> generatePreview(CameraImage cameraImage) async {
  // Downsample to 720p for real-time processing
  final img.Image downsampled = img.copyResize(
    convertedImage,
    width: 720,
  );
  
  // Apply effects
  final processed = await ImageProcessingService().applyFilmEffect(
    inputImage: downsampled,
    pipeline: selectedCamera.pipeline,
  );
  
  return convertToUIImage(processed);
}
```

### 3. Caching Strategy

```dart
class CameraIconCache {
  static final Map<String, ui.Image> _cache = {};
  
  static Future<ui.Image> getIcon(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path]!;
    }
    
    final image = await loadImage(path);
    _cache[path] = image;
    return image;
  }
}
```

---

## 📦 Required Dependencies

```yaml
# pubspec.yaml

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  
  # Image Processing
  image: ^4.1.3
  camera: ^0.10.5
  image_picker: ^1.0.4
  
  # UI
  google_fonts: ^6.1.0
  
  # Storage
  shared_preferences: ^2.2.2
  path_provider: ^2.1.1
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Monetization
  in_app_purchase: ^3.1.11
  
  # Analytics
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.9

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

---

## ✅ Final Launch Checklist

### Pre-Launch
- [ ] All 30 cameras tested and working
- [ ] In-app purchases configured and tested
- [ ] Privacy policy created
- [ ] Terms of service created
- [ ] App icons (all sizes) generated
- [ ] Launch screenshots created
- [ ] App preview video recorded
- [ ] Localization completed (if applicable)

### App Store Requirements
- [ ] App Store listing complete
- [ ] Keywords optimized for ASO
- [ ] Age rating appropriate
- [ ] Support URL active
- [ ] Privacy policy URL active

### Technical
- [ ] Crash-free rate > 99.5%
- [ ] App size < 150MB
- [ ] Cold start time < 2s
- [ ] Photo processing < 3s (4K images)
- [ ] Memory usage < 500MB peak

---

**🎉 Your complete Flutter film camera app specification is ready! Follow the implementation roadmap and use these code examples to build your app. Good luck!**
