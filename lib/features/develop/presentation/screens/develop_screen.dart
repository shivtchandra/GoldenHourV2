import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/colors.dart';
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
  final String? initialAspectRatio;
  final String? date;
  final bool showInstantBorder;

  const DevelopScreen({
    super.key,
    this.imageFile,
    this.initialCamera,
    this.initialAspectRatio,
    this.date,
    this.showInstantBorder = false,
  });

  @override
  ConsumerState<DevelopScreen> createState() => _DevelopScreenState();
}

class _DevelopScreenState extends ConsumerState<DevelopScreen> {
  // Image State
  File? _currentFile;
  img.Image? _originalImage;
  Uint8List? _previewBytes;
  Uint8List? _displayBytes;
  bool _isProcessing = false;
  bool _isSaving = false;
  bool _showingOriginal = false;
  
  // Selection State
  PresetModel? _selectedPreset;
  int _activeTab = 0; // 0: Presets, 1: Adjust, 2: Frame
  String _selectedTool = 'Exposure';
  String _selectedAspectRatio = 'Original';

  // Pipeline State
  late PipelineConfig _pipeline;

  @override
  void initState() {
    super.initState();
    _pipeline = PipelineConfig.defaultConfig();
    
    // Default to provider's ratio if not passed specifically
    _selectedAspectRatio = widget.initialAspectRatio ?? ref.read(settingsProvider).aspectRatio;
    
    if (widget.imageFile != null) {
      _currentFile = widget.imageFile;
      _loadAndProcessImage();
    }
  }

  Future<void> _loadAndProcessImage() async {
    if (_currentFile == null) return;
    setState(() => _isProcessing = true);

    try {
      final bytes = await _currentFile!.readAsBytes();
      final decoded = await compute(img.decodeImage, bytes);
      if (decoded != null) {
        _originalImage = decoded;
        // Apply initial camera/preset if provided
        if (widget.initialCamera != null) {
           _pipeline = widget.initialCamera!.pipeline;
        }
        await _updatePreview();
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updatePreview() async {
    if (_originalImage == null) return;
    
    // For live preview, we use a smaller version to keep it snappy
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
    return Scaffold(
      backgroundColor: Colors.black,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0F0F), Colors.black],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _glassIconButton(
            icon: Icons.refresh_rounded, // Retake icon
            onPressed: () => Navigator.pop(context),
            tooltip: 'Retake',
          ),
          Text(
            'DEVELOP',
            style: GoogleFonts.spaceMono(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: AppColors.accentGold,
            ),
          ),
          _glassIconButton(
            icon: Icons.check_rounded,
            onPressed: _savePhoto,
            color: AppColors.accentGold,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_currentFile == null) {
      return _buildImagePicker();
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

  Widget _buildInstantPhotoFrame() {
    // Determine the aspect ratio of the image container
    double targetRatio = 1.0;
    if (widget.initialAspectRatio == '4:5') targetRatio = 4/5;
    else if (widget.initialAspectRatio == '3:4') targetRatio = 3/4;
    else if (widget.initialAspectRatio == '16:9') targetRatio = 16/9;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 32), // Significantly tighter margins
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF5),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 40,
            spreadRadius: 5,
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
    final preview = GestureDetector(
      onLongPressStart: (_) => setState(() => _showingOriginal = true),
      onLongPressEnd: (_) => setState(() => _showingOriginal = false),
      child: _isProcessing 
        ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
        : _displayBytes != null
          ? Image.memory(
              _showingOriginal ? File(_currentFile!.path).readAsBytesSync() : _displayBytes!,
              fit: fit,
            )
          : const SizedBox.shrink(),
    );

    if (noDecoration) return preview;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: preview,
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
                  color: AppColors.accentGold.withOpacity(0.5),
                ),
              ),
            if (_pipeline.showDateStamp && !widget.showInstantBorder) const SizedBox(width: 12),
            Text(
              _showingOriginal ? 'ORIGINAL' : 'ENHANCED VIEW',
              style: GoogleFonts.spaceMono(
                fontSize: 10,
                color: _showingOriginal ? AppColors.accentGold : Colors.white38,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
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
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _tabIcon(Icons.style_rounded, 0, 'PRESETS'),
                _tabIcon(Icons.tune_rounded, 1, 'ADJUST'),
                _tabIcon(Icons.crop_rounded, 2, 'FRAME'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToolContent() {
    switch (_activeTab) {
      case 0: // Presets
        final presets = PresetRepository.getAllPresets();
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: presets.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // The "Original" option
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
                          color: isSelected ? AppColors.accentGold : Colors.white10,
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected ? AppColors.accentGold.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: isSelected ? AppColors.accentGold : Colors.white54,
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
                          color: isSelected ? Colors.white : Colors.white38,
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
                
                // Set this as the active camera for the live viewfinder too
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
                        color: isSelected ? AppColors.accentGold : Colors.white10,
                        width: isSelected ? 2 : 1,
                      ),
                      color: isSelected ? AppColors.accentGold.withOpacity(0.1) : Colors.white.withOpacity(0.02),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.filter_hdr_rounded,
                        color: isSelected ? AppColors.accentGold : Colors.white54,
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
                        color: isSelected ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      case 1: // Adjustments
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
      case 2: // Frame
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _frameOption('Original', Icons.image_aspect_ratio_rounded),
            _frameOption('4:5', Icons.portrait_rounded),
            _frameOption('1:1', Icons.crop_square_rounded),
            _frameOption('16:9', Icons.panorama_horizontal_rounded),
          ],
        );
      default:
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
              activeColor: AppColors.accentGold,
            ),
          ],
        ),
      );
    }

    return SliderTheme(
      data: SliderThemeData(
        activeTrackColor: AppColors.accentGold,
        inactiveTrackColor: Colors.white10,
        thumbColor: Colors.white,
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayColor: AppColors.accentGold.withOpacity(0.1),
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
    bool active = _selectedTool == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accentGold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: active ? AppColors.accentGold : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: active ? AppColors.accentGold : Colors.white54),
            const SizedBox(width: 8),
            Text(title.toUpperCase(), style: GoogleFonts.spaceMono(fontSize: 9, color: active ? Colors.white : Colors.white38)),
          ],
        ),
      ),
    );
  }

  Widget _tabIcon(IconData icon, int index, String label) {
    bool active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Icon(
          icon,
          color: active ? AppColors.accentGold : Colors.white24,
          size: 22,
        ),
      ),
    );
  }

  Widget _frameOption(String label, IconData icon) {
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
              color: active ? AppColors.accentGold.withOpacity(0.1) : Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.accentGold : Colors.white10,
                width: active ? 1.5 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.accentGold : Colors.white24,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : Colors.white24,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, required VoidCallback onPressed, Color color = Colors.white, String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: GlassContainer.clearGlass(
        width: 48,
        height: 48,
        borderRadius: BorderRadius.circular(24),
        borderColor: Colors.transparent,
        child: IconButton(
          icon: Icon(icon, color: color, size: 24),
          onPressed: onPressed,
        ),
      ),
    );
  }

  void _resetToOriginal() {
    setState(() {
      _pipeline = PipelineConfig.defaultConfig();
      _selectedAspectRatio = 'Original';
    });
  }

  Widget _buildSourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        height: 120,
        width: 240,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]),
        borderColor: Colors.white10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.accentGold, size: 32),
            const SizedBox(height: 12),
            Text(label, style: GoogleFonts.spaceMono(fontSize: 10, color: Colors.white70, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accentGold),
            const SizedBox(height: 20),
            Text(
              'EXPORTING MASTERPIECE...',
              style: GoogleFonts.spaceMono(color: AppColors.accentGold, letterSpacing: 3, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() {
        _currentFile = File(file.path);
      });
      _loadAndProcessImage();
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
        'isPreview': false, // Full resolution
        'date': pipeline.showDateStamp ? (pipeline.dateStampText ?? widget.date) : null,
      });
      
      final bytes = await compute(img.encodeJpg, processed);
      final uint8Bytes = Uint8List.fromList(bytes);
      
      await Gal.putImageBytes(uint8Bytes);
      await PhotoStorageService.instance.saveProcessedPhoto(
        bytes: uint8Bytes,
        cameraId: _selectedPreset?.id ?? 'custom',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SAVED TO GALLERY'), backgroundColor: AppColors.accentGold),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Save error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
