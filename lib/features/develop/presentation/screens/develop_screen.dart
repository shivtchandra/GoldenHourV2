import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../presets/data/models/preset_model.dart';
import '../../../presets/data/repositories/preset_repository.dart';
import '../../../camera/data/models/pipeline_config.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../../../../core/services/image_processing_service.dart';
import '../../../camera/data/models/camera_model.dart';
import '../../../camera/providers/settings_provider.dart';

class DevelopScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final CameraModel? initialCamera;
  final PresetModel? initialPreset;
  final String? initialAspectRatio;
  final String? date;
  final bool showInstantBorder;

  const DevelopScreen({
    super.key,
    this.imageFile,
    this.initialCamera,
    this.initialPreset,
    this.initialAspectRatio,
    this.date,
    this.showInstantBorder = false,
  });

  @override
  ConsumerState<DevelopScreen> createState() => _DevelopScreenState();
}

class _DevelopScreenState extends ConsumerState<DevelopScreen> {
  final ImagePicker _picker = ImagePicker();

  // Image State
  File? _currentFile;
  Uint8List? _originalBytes; // Cache raw bytes to prevent repeated disk reads
  img.Image? _originalImage;
  Uint8List? _previewBytes;
  Uint8List? _displayBytes;
  bool _isProcessing = true; // Start true so first frame shows loading, not original photo
  bool _isSaving = false;
  bool _showingOriginal = false;
  bool _loadError = false; // True when image decode completely fails
  
  // Selection State
  PresetModel? _selectedPreset;
  int _activeTab = 0; // 0: Presets, 1: Adjust, 2: Frame
  String _selectedTool = 'Exposure';
  String _selectedAspectRatio = 'Original';
  bool _hasAutoSwitchedTab = false;

  // Pipeline State
  late PipelineConfig _pipeline;
  late PipelineConfig _capturePipeline;
  String? _captureName;
  Uint8List? _capturePreviewBytes;

  @override
  void initState() {
    super.initState();

    // CORRECTION: The ColorFiltered widget in camera preview only affects the DISPLAY,
    // NOT the captured image. The camera captures RAW unfiltered images.
    // Therefore, we MUST apply the filter pipeline in DevelopScreen to get the film look.
    //
    // - If initialPreset is provided: Apply preset's pipeline
    // - If initialCamera is provided: Apply camera's pipeline
    // - If neither: Start with default (no filter)

    _pipeline = PipelineConfig.defaultConfig();
    _capturePipeline = PipelineConfig.defaultConfig();

    // Apply the filter from preset or camera
    if (widget.initialPreset != null) {
      _selectedPreset = widget.initialPreset;
      _captureName = widget.initialPreset!.name;
      _pipeline = widget.initialPreset!.pipeline; // Apply the preset's filter
      _capturePipeline = widget.initialPreset!.pipeline;
    }

    if (widget.initialCamera != null) {
      _captureName = widget.initialCamera!.name;
      _pipeline = widget.initialCamera!.pipeline; // Apply the camera's filter
      _capturePipeline = widget.initialCamera!.pipeline;
    }

    // Default to provider's ratio if not passed specifically
    _selectedAspectRatio = widget.initialAspectRatio ?? ref.read(settingsProvider).aspectRatio;

    // Auto-switch to Adjust tab if photo was taken with preset/camera filter
    // since the presets tab would just re-apply filters (undesirable)
    if ((widget.initialPreset != null || widget.initialCamera != null) && _activeTab == 0) {
      _activeTab = 1; // Switch to Adjust tab
      _hasAutoSwitchedTab = true;
    }

    if (widget.imageFile != null) {
      _currentFile = widget.imageFile;
      _loadAndProcessImage();
    }
  }

  Future<void> _loadAndProcessImage() async {
    if (_currentFile == null) return;

    // FOOLPROOF: First verify the file exists
    if (!_currentFile!.existsSync()) {
      debugPrint('DevelopScreen: File does not exist: ${_currentFile!.path}');
      if (mounted) {
        setState(() => _loadError = true);
      }
      return;
    }

    setState(() {
      _isProcessing = true;
      _loadError = false;
    });

    try {
      final bytes = await _currentFile!.readAsBytes();
      _originalBytes = bytes;
      
      // CRITICAL: UI can now show the image immediately using Image.memory(_originalBytes!)
      // before we even start the heavy decoding process in the isolate.
      if (mounted) setState(() {});
      
      debugPrint('DevelopScreen: Read ${bytes.length} bytes from file');

      // FOOLPROOF: If file is empty or too small, it's invalid
      if (bytes.length < 100) {
        debugPrint('DevelopScreen: File too small, likely corrupt');
        if (mounted) setState(() => _loadError = true);
        return;
      }

      // Try multiple decode strategies in order of reliability
      img.Image? decoded;

      // Strategy 1: Direct decode with image package (fastest)
      try {
        decoded = await compute(_decodeAndResizeTask, bytes);
        if (decoded != null && !_isLikelyInvalidDecode(decoded)) {
          debugPrint('DevelopScreen: Strategy 1 (direct decode) succeeded');
        } else {
          decoded = null;
        }
      } catch (e) {
        debugPrint('DevelopScreen: Strategy 1 failed: $e');
        decoded = null;
      }

      // Strategy 2: Platform codec fallback (handles device-specific formats)
      if (decoded == null) {
        try {
          debugPrint('DevelopScreen: Trying Strategy 2 (platform codec)');
          decoded = await _decodeAndResizeWithPlatform(bytes);
          if (decoded != null && !_isLikelyInvalidDecode(decoded)) {
            debugPrint('DevelopScreen: Strategy 2 (platform codec) succeeded');
          } else {
            decoded = null;
          }
        } catch (e) {
          debugPrint('DevelopScreen: Strategy 2 failed: $e');
          decoded = null;
        }
      }

      // Strategy 3: Try decoding as specific formats
      if (decoded == null) {
        try {
          debugPrint('DevelopScreen: Trying Strategy 3 (specific format decode)');
          decoded = await compute(_decodeSpecificFormats, bytes);
          if (decoded != null && !_isLikelyInvalidDecode(decoded)) {
            debugPrint('DevelopScreen: Strategy 3 (specific format) succeeded');
          } else {
            decoded = null;
          }
        } catch (e) {
          debugPrint('DevelopScreen: Strategy 3 failed: $e');
          decoded = null;
        }
      }

      if (decoded != null) {
        _originalImage = decoded;
        debugPrint('DevelopScreen: Successfully decoded image: ${decoded.width}x${decoded.height}');
        await _updatePreview();
      } else {
        // FOOLPROOF: All decode paths failed, but we still have the file
        // The UI will show Image.file as fallback which always works
        debugPrint('DevelopScreen: All decode strategies failed - UI will use Image.file fallback');
        if (mounted) {
          setState(() => _loadError = true);
          // Don't show error snackbar - just silently fall back to showing original
        }
      }
    } catch (e) {
      debugPrint('DevelopScreen: Error loading image: $e');
      if (mounted) {
        setState(() => _loadError = true);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Strategy 3: Try specific image format decoders
  static img.Image? _decodeSpecificFormats(Uint8List bytes) {
    try {
      // Try JPEG first (most common for camera photos)
      var decoded = img.decodeJpg(bytes);
      if (decoded != null) {
        decoded = img.bakeOrientation(decoded);
        return _resizeIfNeeded(decoded);
      }
    } catch (_) {}

    try {
      // Try PNG
      var decoded = img.decodePng(bytes);
      if (decoded != null) {
        return _resizeIfNeeded(decoded);
      }
    } catch (_) {}

    try {
      // Try WebP
      var decoded = img.decodeWebP(bytes);
      if (decoded != null) {
        return _resizeIfNeeded(decoded);
      }
    } catch (_) {}

    try {
      // Try BMP
      var decoded = img.decodeBmp(bytes);
      if (decoded != null) {
        return _resizeIfNeeded(decoded);
      }
    } catch (_) {}

    return null;
  }

  static img.Image _resizeIfNeeded(img.Image decoded) {
    const int maxDimension = 1000;
    if (decoded.width > maxDimension || decoded.height > maxDimension) {
      if (decoded.width > decoded.height) {
        return img.copyResize(decoded, width: maxDimension, interpolation: img.Interpolation.average);
      } else {
        return img.copyResize(decoded, height: maxDimension, interpolation: img.Interpolation.average);
      }
    }
    return decoded;
  }

  static img.Image? _decodeAndResizeTask(Uint8List bytes) {
    try {
      var decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // CRITICAL: Handle EXIF orientation (rotation) before resizing
      // Otherwise images taken in portrait might appear landscape/squashed.
      decoded = img.bakeOrientation(decoded);

      const int maxDimension = 1000;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        if (decoded.width > decoded.height) {
          decoded = img.copyResize(decoded, width: maxDimension, interpolation: img.Interpolation.average);
        } else {
          decoded = img.copyResize(decoded, height: maxDimension, interpolation: img.Interpolation.average);
        }
      }
      return decoded;
    } catch (e) {
      return null;
    }
  }

  Future<img.Image?> _decodeAndResizeWithPlatform(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;

      final rawBytes = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = uiImage.width;
      final height = uiImage.height;

      uiImage.dispose();
      codec.dispose();

      if (rawBytes == null) return null;

      // CRITICAL FIX: Copy the bytes to a new buffer
      // The rawBytes.buffer may be disposed or become invalid on some Android devices
      // This ensures we have our own copy of the pixel data
      final bytesList = rawBytes.buffer.asUint8List();
      final copiedBytes = Uint8List.fromList(bytesList);

      img.Image decoded = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: copiedBytes.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );

      const int maxDimension = 1000;
      if (decoded.width > maxDimension || decoded.height > maxDimension) {
        if (decoded.width > decoded.height) {
          decoded = img.copyResize(decoded, width: maxDimension, interpolation: img.Interpolation.average);
        } else {
          decoded = img.copyResize(decoded, height: maxDimension, interpolation: img.Interpolation.average);
        }
      }

      return decoded;
    } catch (e) {
      debugPrint('DevelopScreen: Platform decode failed: $e');
      return null;
    }
  }

  static bool _isLikelyInvalidDecode(img.Image image) {
    if (image.width < 8 || image.height < 8) return false;

    const int sampleGrid = 24;
    final int stepX = (image.width / sampleGrid).ceil().clamp(1, image.width);
    final int stepY = (image.height / sampleGrid).ceil().clamp(1, image.height);

    int minLum = 255;
    int maxLum = 0;
    int minR = 255;
    int maxR = 0;
    int minG = 255;
    int maxG = 0;
    int minB = 255;
    int maxB = 0;

    for (int y = 0; y < image.height; y += stepY) {
      for (int x = 0; x < image.width; x += stepX) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        final lum = (0.299 * r + 0.587 * g + 0.114 * b).round();
        if (lum < minLum) minLum = lum;
        if (lum > maxLum) maxLum = lum;

        if (r < minR) minR = r;
        if (r > maxR) maxR = r;
        if (g < minG) minG = g;
        if (g > maxG) maxG = g;
        if (b < minB) minB = b;
        if (b > maxB) maxB = b;
      }
    }

    // RELAXED: Changed threshold from 3 to 1 to reduce false positives
    // Only flag images that are truly solid colors (no variation at all)
    // This was too aggressive and flagging valid photos as "invalid" on some Android devices
    final bool lowLumaRange = (maxLum - minLum) <= 1;
    final bool lowColorRange = (maxR - minR) <= 1 && (maxG - minG) <= 1 && (maxB - minB) <= 1;
    return lowLumaRange && lowColorRange;
  }

  Future<void> _updatePreview() async {
    // FOOLPROOF: If no original image, the UI will fall back to Image.file
    if (_originalImage == null) {
      debugPrint('DevelopScreen: _updatePreview called but _originalImage is null');
      return;
    }

    try {
      // For live preview, we use a smaller version to keep it snappy.
      final processed = await compute(_processImageTask, {
        'image': _originalImage!,
        'pipeline': _pipeline,
        'aspectRatio': _selectedAspectRatio,
        'isPreview': true,
        'date': _pipeline.showDateStamp ? (_pipeline.dateStampText ?? widget.date) : null,
      });

      final encoded = await compute(img.encodeJpg, processed);
      if (mounted && encoded.isNotEmpty) {
        setState(() {
          _displayBytes = Uint8List.fromList(encoded);
        });
      }
    } catch (e) {
      debugPrint('DevelopScreen: Preview processing failed: $e');
      // Fallback 1: Try to encode original image without processing
      try {
        final fallback = await compute(img.encodeJpg, _originalImage!);
        if (mounted && fallback.isNotEmpty) {
          setState(() {
            _displayBytes = Uint8List.fromList(fallback);
          });
          debugPrint('DevelopScreen: Using unprocessed original as fallback');
          return;
        }
      } catch (e2) {
        debugPrint('DevelopScreen: Fallback encoding also failed: $e2');
      }

      // Fallback 2: Just leave _displayBytes null - UI will show Image.file
      // This is fine because buildSafeFileImage() always works
      debugPrint('DevelopScreen: All preview methods failed - UI will use Image.file');
    }
  }

  static img.Image _processImageTask(Map<String, dynamic> data) {
    final img.Image input = data['image'];
    final PipelineConfig pipeline = data['pipeline'];
    final bool isPreview = data['isPreview'] ?? false;
    final String aspectRatio = data['aspectRatio'] ?? 'Original';
    final String? date = data['date'];
    
    // 1. Initial Scale for performance
    img.Image working = isPreview 
      ? img.copyResize(input, width: (input.width > 1200 ? 1200 : input.width)) 
      : img.Image.from(input);

    // 2. Apply Aspect Ratio Crop
    if (aspectRatio != 'Original') {
      double targetRatio = 1.0;
      if (aspectRatio == '4:5') targetRatio = 4 / 5;
      else if (aspectRatio == '16:9') targetRatio = 16 / 9;
      else if (aspectRatio == '1:1') targetRatio = 1 / 1;

      int w = working.width;
      int h = working.height;
      double currentRatio = w / h;

      if (currentRatio > targetRatio) {
        // Current is wider than target: cut sides
        int targetW = (h * targetRatio).toInt();
        int offset = (w - targetW) ~/ 2;
        working = img.copyCrop(working, x: offset, y: 0, width: targetW, height: h);
      } else {
        // Current is taller than target: cut top/bottom
        int targetH = (w / targetRatio).toInt();
        int offset = (h - targetH) ~/ 2;
        working = img.copyCrop(working, x: 0, y: offset, width: w, height: targetH);
      }
    }

    // 3. Apply Effects
    return ImageProcessingService().applyFilmEffect(
      inputImage: working,
      pipeline: pipeline,
      date: date,
    );
  }

  PipelineConfig _getCurrentPipeline() => _pipeline;

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      body: Stack(
        children: [
          _buildBackgroundGradient(),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMainContent(),
                  ),
                ),
                _buildToolShelf(),
              ],
            ),
          ),

          if (_isSaving) _buildSavingOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: context.colors.backgroundGradient,
      ),
    );
  }

  Widget _buildHeader() {
    final tc = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _glassIconButton(
            icon: Icons.refresh_rounded,
            onPressed: () => Navigator.pop(context),
            tooltip: 'Retake',
          ),
          // Compare button - toggle to show original
          _glassIconButton(
            icon: _showingOriginal ? Icons.filter_hdr_rounded : Icons.compare_rounded,
            onPressed: () => setState(() => _showingOriginal = !_showingOriginal),
            color: _showingOriginal ? tc.accent : tc.iconMuted,
            tooltip: _showingOriginal ? 'Show Filtered' : 'Compare Original',
          ),
          Text(
            'DEVELOP',
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: tc.accent,
            ),
          ),
          _glassIconButton(
            icon: Icons.check_rounded,
            onPressed: _savePhoto,
            color: tc.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentFile == null) {
      return _buildImagePicker();
    }

    // ONLY show the processed photo. Show loading screen until displayBytes is ready.
    // This ensures the original unfiltered photo NEVER appears.
    if (_displayBytes == null && !_showingOriginal) {
      return _buildProcessingScreen();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Hero(
            tag: 'photo_card',
            child: widget.showInstantBorder ? _buildInstantPhotoFrame() : _buildImagePreview(),
          ),
        ),
      ],
    );
  }

  /// Full-screen processing indicator (like Instagram/VSCO)
  Widget _buildProcessingScreen() {
    final tc = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated film icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: 0.5 + (0.5 * value),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    size: 80,
                    color: tc.accent,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Processing text
          Text(
            'DEVELOPING YOUR PHOTO',
            style: GoogleFonts.spaceMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: tc.textPrimary,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            'Applying film effects...',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: tc.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
          // Progress indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: tc.borderSubtle,
              color: tc.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstantPhotoFrame() {
    // Determine the aspect ratio of the image container
    double targetRatio = 1.0;
    if (widget.initialAspectRatio == '4:5') targetRatio = 4/5;
    else if (widget.initialAspectRatio == '3:4') targetRatio = 3/4;
    else if (widget.initialAspectRatio == '16:9') targetRatio = 16/9;

    final tc = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 32), // Significantly tighter margins
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF5),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(tc.isDark ? 0.5 : 0.2),
            blurRadius: 40,
            spreadRadius: tc.isDark ? 5 : 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: targetRatio,
            child: _buildImagePreview(noDecoration: true, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16), // Reduced spacing
          if (widget.date != null)
            Text(
              widget.date!,
              style: GoogleFonts.permanentMarker(
                color: Colors.black.withOpacity(0.2),
                fontSize: 18, // Slightly smaller for better balance
                letterSpacing: 1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePreview({bool noDecoration = false, BoxFit fit = BoxFit.contain}) {
    final tc = context.colors;

    /// FOOLPROOF: This widget ALWAYS shows something - never gray/blank
    Widget buildSafeFileImage() {
      if (_originalBytes != null) {
        return Image.memory(
          _originalBytes!,
          fit: fit,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('DevelopScreen: Image.memory from cached bytes failed: $error');
            return _buildImageError(tc, 'PROCESS ERROR');
          },
        );
      }

      if (_currentFile == null) {
        return _buildImageError(tc, 'NO FILE');
      }

      // Fallback to Image.file if bytes haven't loaded yet
      return Image.file(
        _currentFile!,
        fit: fit,
        errorBuilder: (_, e, __) {
          return _buildImageError(tc, 'CANNOT DISPLAY');
        },
      );
    }

    // ONLY SHOW PROCESSED IMAGE - never show the original unfiltered photo
    Widget imageWidget;

    // Case 1: User wants to see original (compare mode)
    if (_showingOriginal) {
      imageWidget = buildSafeFileImage();
    }
    // Case 2: We have processed bytes ready to display
    else if (_displayBytes != null && _displayBytes!.isNotEmpty) {
      imageWidget = Image.memory(
        _displayBytes!,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('DevelopScreen: Image.memory failed, showing loading');
          // Don't fall back to original - show loading instead
          return Center(
            child: CircularProgressIndicator(color: tc.accent),
          );
        },
      );
    }
    // Case 3: Still processing - show loading indicator, NOT the original
    else if (_currentFile != null) {
      imageWidget = Center(
        child: CircularProgressIndicator(color: tc.accent),
      );
    }
    // Case 4: No file at all
    else {
      imageWidget = _buildImageError(tc, 'SELECT A PHOTO');
    }

    // Use InteractiveViewer for proper pinch-to-zoom
    final preview = InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: imageWidget,
    );

    if (noDecoration) return preview;

    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(tc.isDark ? 0.5 : 0.15),
                    blurRadius: 30,
                    spreadRadius: tc.isDark ? 5 : 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: preview,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_pipeline.showDateStamp && !widget.showInstantBorder)
                 Text(
                  _pipeline.dateStampText ?? '',
                  style: GoogleFonts.permanentMarker(
                    fontSize: 14,
                    color: tc.accentMuted,
                  ),
                ),
              if (_pipeline.showDateStamp && !widget.showInstantBorder) const SizedBox(width: 12),
              Text(
                _showingOriginal 
                    ? 'ORIGINAL (${_captureName?.toUpperCase() ?? 'RAW'})' 
                    : (_selectedPreset != null ? '${_selectedPreset!.name.toUpperCase()} VIEW' : 'ENHANCED VIEW'),
                style: GoogleFonts.spaceMono(
                  fontSize: 10,
                  color: _showingOriginal ? tc.accent : tc.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSourceButton(
            icon: Icons.photo_library_outlined,
            label: 'OPEN FROM GALLERY',
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 20),
          _buildSourceButton(
            icon: Icons.camera_alt_outlined,
            label: 'SHOOT NEW PHOTO',
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildToolShelf() {
    if (_currentFile == null) return const SizedBox.shrink();

    // If photo was taken with a preset, hide the presets tab
    final bool hidePresetsTab = widget.initialPreset != null;
    
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Active Tool Area
          Container(
            height: 120, // Reduced from 140
            child: _buildActiveToolContent(),
          ),
          const SizedBox(height: 12), // Reduced from 20
          // Tab Switcher
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: context.colors.glassBackground,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: context.colors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!hidePresetsTab) _tabIcon(Icons.style_rounded, 0, 'PRESETS'),
                _tabIcon(Icons.tune_rounded, hidePresetsTab ? 0 : 1, 'ADJUST'),
                _tabIcon(Icons.crop_rounded, hidePresetsTab ? 1 : 2, 'FRAME'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToolContent() {
    final bool hidePresetsTab = widget.initialPreset != null;
    
    // Adjust tab indices based on whether presets are hidden
    final int presetsTabIndex = 0;
    final int adjustTabIndex = hidePresetsTab ? 0 : 1;
    final int frameTabIndex = hidePresetsTab ? 1 : 2;
    
    if (_activeTab == presetsTabIndex && !hidePresetsTab) {
      // Presets tab (only shown when not shot with preset)
        final presets = PresetRepository.getAllPresets();
        final tc = context.colors;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: presets.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final bool isSelected = _selectedPreset == null;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPreset = null;
                    _resetToOriginal();
                  });
                  _updatePreview();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? tc.accent : tc.borderSubtle,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected ? tc.accent.withOpacity(0.1) : tc.glassBackground,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: isSelected ? tc.accent : tc.iconMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: Text(
                        'ORIGINAL',
                        style: GoogleFonts.spaceMono(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? tc.textPrimary : tc.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            final preset = presets[index - 1];
            final isSelected = _selectedPreset?.id == preset.id;
            return GestureDetector(
                onTap: () {
                setState(() {
                  _selectedPreset = preset;
                  _pipeline = preset.pipeline;
                });

                ref.read(settingsProvider.notifier).setActiveCamera(preset.id);

                _updatePreview();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? tc.accent : tc.borderSubtle,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected ? tc.accent.withOpacity(0.1) : tc.glassBackground,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.filter_hdr_rounded,
                        color: isSelected ? tc.accent : tc.iconMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: Text(
                      preset.name.toUpperCase(),
                      style: GoogleFonts.spaceMono(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? tc.textPrimary : tc.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
    } else if (_activeTab == adjustTabIndex) {
      // Adjustments tab
        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                   _toolButton('Exposure', Icons.brightness_6_rounded),
                  _toolButton('Contrast', Icons.contrast_rounded),
                  _toolButton('Saturation', Icons.palette_rounded),
                  _toolButton('Temperature', Icons.thermostat_rounded),
                  _toolButton('Grain', Icons.grain_rounded),
                  _toolButton('Vignette', Icons.vignette_rounded),
                  _toolButton('Date', Icons.calendar_today_rounded),
                  const SizedBox(width: 8),
                  // Reset button inside the adjust shelf
                  GestureDetector(
                    onTap: () {
                      _resetToOriginal();
                      _updatePreview();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text('RESET', style: GoogleFonts.spaceMono(fontSize: 9, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildSleekSlider(),
          ],
        );
    } else if (_activeTab == frameTabIndex) {
      // Frame tab
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _frameOption('Original', Icons.image_aspect_ratio_rounded),
            _frameOption('4:5', Icons.portrait_rounded),
            _frameOption('1:1', Icons.crop_square_rounded),
            _frameOption('16:9', Icons.panorama_horizontal_rounded),
          ],
        );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildSleekSlider() {
    double value = 0;
    double min = -1, max = 1;
    
    if (_selectedTool == 'Exposure') { value = _pipeline.exposureBias; min = -2; max = 2; }
    else if (_selectedTool == 'Contrast') { value = _pipeline.contrastBias; min = -1; max = 1; }
    else if (_selectedTool == 'Saturation') { value = _pipeline.saturation; min = 0; max = 2; }
    else if (_selectedTool == 'Temperature') { value = _pipeline.temperature; min = -50; max = 50; }
    else if (_selectedTool == 'Grain') { value = _pipeline.grainStrength; min = 0; max = 1; }
    else if (_selectedTool == 'Vignette') { value = _pipeline.vignetteStrength; min = 0; max = 1; }
    else if (_selectedTool == 'Date') {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('DATE STAMP', style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.white70)),
            const SizedBox(width: 12),
            Switch(
              value: _pipeline.showDateStamp,
              onChanged: (v) {
                setState(() {
                  _pipeline = _pipeline.copyWith(
                    showDateStamp: v,
                    dateStampText: v ? (widget.date ?? DateTime.now().toString().split(' ')[0]) : null,
                  );
                });
                _updatePreview();
              },
              activeColor: context.colors.accent,
            ),
          ],
        ),
      );
    }

    final tc = context.colors;
    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: tc.accent,
        inactiveTrackColor: tc.borderSubtle,
        thumbColor: tc.textPrimary,
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayColor: tc.accent.withOpacity(0.1),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
      onChanged: (v) {
        setState(() {
           if (_selectedTool == 'Exposure') {
             _pipeline = _pipeline.copyWith(exposureBias: v);
           } else if (_selectedTool == 'Contrast') {
             _pipeline = _pipeline.copyWith(contrastBias: v);
           } else if (_selectedTool == 'Saturation') {
             _pipeline = _pipeline.copyWith(saturation: v);
           } else if (_selectedTool == 'Temperature') {
             _pipeline = _pipeline.copyWith(temperature: v);
           } else if (_selectedTool == 'Grain') {
             _pipeline = _pipeline.copyWith(grainStrength: v);
           } else if (_selectedTool == 'Vignette') {
             _pipeline = _pipeline.copyWith(vignetteStrength: v);
           }
        });
      },
        onChangeEnd: (_) => _updatePreview(),
      ),
    );
  }

  Widget _toolButton(String title, IconData icon) {
    final tc = context.colors;
    bool active = _selectedTool == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: active ? tc.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: active ? tc.accent : tc.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: active ? tc.accent : tc.iconMuted),
            const SizedBox(width: 8),
            Text(title.toUpperCase(), style: GoogleFonts.spaceMono(fontSize: 9, color: active ? tc.textPrimary : tc.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _tabIcon(IconData icon, int index, String label) {
    final tc = context.colors;
    bool active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Icon(
          icon,
          color: active ? tc.accent : tc.textFaint,
          size: 22,
        ),
      ),
    );
  }

  Widget _frameOption(String label, IconData icon) {
    final tc = context.colors;
    bool active = _selectedAspectRatio == label;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedAspectRatio = label);
        if (label != 'Original') {
          ref.read(settingsProvider.notifier).setAspectRatio(label);
        }
        _updatePreview();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: active ? tc.accent.withOpacity(0.1) : tc.glassBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? tc.accent : tc.borderSubtle,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: active ? tc.accent : tc.textFaint,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? tc.textPrimary : tc.textFaint,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, required VoidCallback onPressed, Color? color, String? tooltip}) {
    final tc = context.colors;
    return Tooltip(
      message: tooltip ?? '',
      child: AdaptiveGlass(
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(24),
        borderColor: Colors.transparent,
        child: IconButton(
          icon: Icon(icon, color: color ?? tc.iconPrimary, size: 24),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildImageError(dynamic tc, String message) {
    // Show file path for debugging on real devices
    final filePath = _currentFile?.path ?? 'NO PATH';
    final fileExists = _currentFile?.existsSync() ?? false;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: tc.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.spaceMono(fontSize: 12, color: tc.textMuted, letterSpacing: 2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'File: ${filePath.split('/').last}\nExists: $fileExists',
              style: GoogleFonts.spaceMono(fontSize: 9, color: tc.textGhost),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _resetToOriginal() {
    setState(() {
      _pipeline = _capturePipeline;
      _selectedAspectRatio = widget.initialAspectRatio ?? 'Original';
      _selectedPreset = widget.initialPreset;
    });
  }

  Widget _buildSourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    final tc = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AdaptiveGlass(
        height: 120,
        width: 240,
        borderRadius: BorderRadius.circular(20),
        borderColor: tc.borderSubtle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: tc.accent, size: 32),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.spaceMono(fontSize: 10, color: tc.textSecondary, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingOverlay() {
    final tc = context.colors;
    return Container(
      color: tc.isDark ? Colors.black87 : Colors.white.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: tc.accent),
            const SizedBox(height: 20),
            Text(
              'EXPORTING MASTERPIECE...',
              style: GoogleFonts.spaceMono(color: tc.accent, letterSpacing: 3, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1200, 
      maxHeight: 1200,
      imageQuality: 90,
    );
    if (file != null) {
      final pickedFile = File(file.path);
      if (await pickedFile.exists()) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _currentFile = pickedFile;
          _originalBytes = bytes;
        });
        _loadAndProcessImage();
      }
    }
  }

  Future<void> _savePhoto() async {
    if (_originalImage == null) return;
    setState(() => _isSaving = true);
    
    try {
      final pipeline = _getCurrentPipeline();
      final processed = await compute(_processImageTask, {
        'image': _originalImage!,
        'pipeline': pipeline,
        'aspectRatio': _selectedAspectRatio,
        'isPreview': false, 
        'date': pipeline.showDateStamp ? (pipeline.dateStampText ?? widget.date) : null,
      });
      
      final bytes = await compute(img.encodeJpg, processed);
      final uint8Bytes = Uint8List.fromList(bytes);
      
      await Gal.putImageBytes(uint8Bytes);
      
      String saveId = _selectedPreset?.id ?? widget.initialCamera?.id ?? 'custom';
      
      await PhotoStorageService.instance.saveProcessedPhoto(
        bytes: uint8Bytes,
        cameraId: saveId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('SAVED TO GALLERY'), backgroundColor: context.colors.accent),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('DevelopScreen: Save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
