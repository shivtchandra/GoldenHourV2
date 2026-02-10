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
  img.Image? _originalImage;
  Uint8List? _previewBytes;
  Uint8List? _displayBytes;
  bool _isProcessing = false;
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
    _pipeline = PipelineConfig.defaultConfig();
    _capturePipeline = PipelineConfig.defaultConfig();

    // Load initial preset if provided
    if (widget.initialPreset != null) {
      _selectedPreset = widget.initialPreset;
      _pipeline = widget.initialPreset!.pipeline;
      _capturePipeline = widget.initialPreset!.pipeline;
      _captureName = widget.initialPreset!.name;
    }

    if (widget.initialCamera != null) {
      _pipeline = widget.initialCamera!.pipeline;
      _capturePipeline = widget.initialCamera!.pipeline;
      _captureName = widget.initialCamera!.name;
    }

    // Default to provider's ratio if not passed specifically
    _selectedAspectRatio = widget.initialAspectRatio ?? ref.read(settingsProvider).aspectRatio;

    // Auto-switch to Adjust tab if photo was taken with preset
    if (widget.initialPreset != null && _activeTab == 0) {
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
    setState(() {
      _isProcessing = true;
      _loadError = false;
    });

    try {
      final bytes = await _currentFile!.readAsBytes();
      debugPrint('DevelopScreen: Read ${bytes.length} bytes from file');

      // Primary decode path in isolate for performance.
      // Fallback to platform codec when needed for device-specific formats.
      img.Image? decoded = await compute(_decodeAndResizeTask, bytes);
      if (decoded == null || _isLikelyInvalidDecode(decoded)) {
        debugPrint('DevelopScreen: Primary decode failed or invalid, trying platform fallback');
        final platformDecoded = await _decodeAndResizeWithPlatform(bytes);
        if (platformDecoded != null) {
          decoded = platformDecoded;
        }
      }

      if (decoded != null) {
        _originalImage = decoded;
        debugPrint('DevelopScreen: Successfully decoded image: ${decoded.width}x${decoded.height}');

        // We no longer pre-compute capturePreview because we'll use Image.file 
        // for the "Original" view, which is much more stable and handled natively.
        _capturePreviewBytes = null; 

        await _updatePreview();
      } else {
        // Both decode paths failed - mark error but keep file for Image.file fallback
        debugPrint('DevelopScreen: Both decode paths failed - using Image.file fallback');
        if (mounted) {
          setState(() => _loadError = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not process photo - showing original'),
              backgroundColor: Colors.orange.shade700,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('DevelopScreen: Error loading image: $e');
      if (mounted) {
        setState(() => _loadError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading photo: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  static img.Image? _decodeAndResizeTask(Uint8List bytes) {
    try {
      var decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      // CRITICAL: Handle EXIF orientation (rotation) before resizing
      // Otherwise images taken in portrait might appear landscape/squashed.
      decoded = img.bakeOrientation(decoded);

      const int maxDimension = 1200;
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

      img.Image decoded = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: rawBytes.buffer,
        numChannels: 4,
        order: img.ChannelOrder.rgba,
      );

      const int maxDimension = 1200;
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

    final bool lowLumaRange = (maxLum - minLum) <= 3;
    final bool lowColorRange = (maxR - minR) <= 3 && (maxG - minG) <= 3 && (maxB - minB) <= 3;
    return lowLumaRange && lowColorRange;
  }

  Future<void> _updatePreview() async {
    if (_originalImage == null) return;

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
      if (mounted) {
        setState(() {
          _displayBytes = Uint8List.fromList(encoded);
        });
      }
    } catch (e) {
      debugPrint('DevelopScreen: Preview processing failed, using fallback: $e');
      try {
        final fallback = await compute(img.encodeJpg, _originalImage!);
        if (mounted) {
          setState(() {
            _displayBytes = Uint8List.fromList(fallback);
          });
        }
      } catch (_) {}
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

    // Show the image - either processed or raw fallback
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

    Widget buildSafeFileImage() {
      if (_currentFile == null) {
        debugPrint('DevelopScreen: buildSafeFileImage - _currentFile is null');
        return _buildImageError(tc, 'NO IMAGE FILE');
      }
      
      // Check if file actually exists
      if (!_currentFile!.existsSync()) {
        debugPrint('DevelopScreen: buildSafeFileImage - file does not exist: ${_currentFile!.path}');
        // Try to show displayBytes if available
        if (_displayBytes != null) {
          return Image.memory(
            _displayBytes!,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _buildImageError(tc, 'FILE DELETED'),
          );
        }
        return _buildImageError(tc, 'FILE NOT FOUND');
      }
      
      debugPrint('DevelopScreen: buildSafeFileImage - showing file: ${_currentFile!.path}');
      return Image.file(
        _currentFile!,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('DevelopScreen: Image.file errorBuilder triggered: $error');
          if (_displayBytes != null) {
            return Image.memory(
              _displayBytes!,
              fit: fit,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _buildImageError(tc, 'UNSUPPORTED PHOTO'),
            );
          }
          return _buildImageError(tc, 'UNSUPPORTED PHOTO');
        },
      );
    }


    // Determine the primary widget to show
    Widget imageWidget;
    
    if (_showingOriginal) {
      // ALWAYS use Image.file for original if available - it's handled natively
      // and won't crash even with 48MP images.
      if (_currentFile != null) {
        imageWidget = buildSafeFileImage();
      } else {
        imageWidget = _buildImageError(tc, 'ORIGINAL NOT FOUND');
      }
    } else if (_displayBytes != null) {
      // Show processed preview
      imageWidget = Image.memory(
        _displayBytes!,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _currentFile != null 
            ? Image.file(_currentFile!, fit: fit) 
            : _buildImageError(tc, 'DISPLAY ERROR'),
      );
    } else if (_currentFile != null) {
      // Fallback: show original file directly while processing
      imageWidget = Stack(
        fit: StackFit.expand,
        children: [
          buildSafeFileImage(),
          if (_isProcessing) 
            Container(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator(color: tc.accent)),
            ),
        ],
      );
    } else {
      imageWidget = _isProcessing 
          ? Center(child: CircularProgressIndicator(color: tc.accent))
          : _buildImageError(tc, 'NO IMAGE');
    }

    final preview = GestureDetector(
      onLongPressStart: (_) => setState(() => _showingOriginal = true),
      onLongPressEnd: (_) => setState(() => _showingOriginal = false),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, color: tc.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.spaceMono(fontSize: 10, color: tc.textMuted, letterSpacing: 2),
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
        setState(() {
          _currentFile = pickedFile;
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
