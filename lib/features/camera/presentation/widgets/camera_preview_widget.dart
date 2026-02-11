import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

/// Global key type for camera preview state access
typedef CameraPreviewState = _CameraPreviewWidgetState;

/// Live camera preview widget
class CameraPreviewWidget extends StatefulWidget {
  final Function(CameraController)? onCameraReady;

  const CameraPreviewWidget({
    super.key,
    this.onCameraReady,
  });

  @override
  CameraPreviewState createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isFrontCamera = false;
  List<CameraDescription> _cameras = [];

  // Flash mode - stored to persist across camera switches
  FlashMode _currentFlashMode = FlashMode.off;

  // Zoom state
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoom = 1.0; // For pinch gesture calculation

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final CameraController? cameraController = _controller;
    _controller = null;
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. Request Camera Permission explicitly
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = result.isPermanentlyDenied 
                  ? 'Camera permission permanently denied.\nPlease enable it in app settings.' 
                  : 'Camera access required.\nPlease grant permission.';
            });
          }
          return;
        }
      }

      // 2. Clear previous errors if we have permission now
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = '';
        });
      }

      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'No cameras available';
          });
        }
        return;
      }

      // Select front or back camera
      final cameraIndex = _isFrontCamera
          ? _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front)
          : _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);

      final selectedCamera = cameraIndex >= 0 ? _cameras[cameraIndex] : _cameras.first;

      // Use MAXIMUM resolution for best quality - each device gives its best
      // DevelopScreen handles resizing for processing, so we capture at full quality
      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.max, // Device's maximum resolution for best quality
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      // CRITICAL: Apply flash mode IMMEDIATELY after initialization
      // This fixes the bug where flash auto-turns on after camera switch
      try {
        await _controller!.setFlashMode(_currentFlashMode);
      } catch (e) {
        debugPrint('Error setting initial flash mode: $e');
      }

      // Get zoom limits for this camera
      try {
        _minZoom = await _controller!.getMinZoomLevel();
        _maxZoom = await _controller!.getMaxZoomLevel();
        _currentZoom = _minZoom;
        _baseZoom = _minZoom;
      } catch (e) {
        debugPrint('Error getting zoom limits: $e');
        _minZoom = 1.0;
        _maxZoom = 1.0;
        _currentZoom = 1.0;
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        widget.onCameraReady?.call(_controller!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Camera initialization failed.\n$e';
        });
      }
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _controller?.dispose();
    setState(() {
      _isInitialized = false;
    });
    await _initializeCamera();
  }

  /// Capture an image and return the file
  Future<XFile?> captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      return image;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Update flash mode - stores mode for persistence across camera switches
  Future<void> setFlashMode(FlashMode mode) async {
    _currentFlashMode = mode; // Store for re-initialization
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  /// Get current zoom level
  double get currentZoom => _currentZoom;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;

  /// Set zoom level with clamping
  Future<void> setZoomLevel(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final clampedZoom = zoom.clamp(_minZoom, _maxZoom);
      await _controller!.setZoomLevel(clampedZoom);
      _currentZoom = clampedZoom;
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  /// Called when pinch gesture starts - stores base zoom
  void onZoomStart() {
    _baseZoom = _currentZoom;
  }

  /// Called during pinch gesture - calculates new zoom from scale
  Future<void> onZoomUpdate(double scale) async {
    final newZoom = _baseZoom * scale;
    await setZoomLevel(newZoom);
  }

  /// Set focus and exposure point (tap to focus)
  /// x and y are normalized coordinates (0.0 to 1.0)
  Future<void> setFocusPoint(double x, double y) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      // Set focus point
      await _controller!.setFocusPoint(Offset(x, y));
      // Also set exposure point to same location for better results
      await _controller!.setExposurePoint(Offset(x, y));
      debugPrint('Focus set to: ($x, $y)');
    } catch (e) {
      debugPrint('Error setting focus point: $e');
      // Some devices don't support focus point - that's okay
    }
  }

  /// Lock current focus and exposure
  Future<void> lockFocus() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFocusMode(FocusMode.locked);
      await _controller!.setExposureMode(ExposureMode.locked);
    } catch (e) {
      debugPrint('Error locking focus: $e');
    }
  }

  /// Unlock focus and exposure (return to auto)
  Future<void> unlockFocus() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
    } catch (e) {
      debugPrint('Error unlocking focus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: Colors.white.withAlpha(77),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _initializeCamera,
                    icon: const Icon(Icons.refresh),
                    label: const Text('RETRY'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => openAppSettings(),
                    icon: const Icon(Icons.settings),
                    label: const Text('SETTINGS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Starting camera...',
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }
}
