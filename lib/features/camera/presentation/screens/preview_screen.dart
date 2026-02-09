import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/camera_model.dart';

/// Preview screen shown after capturing a photo
class PreviewScreen extends StatefulWidget {
  final Uint8List? imageBytes;
  final CameraModel camera;

  const PreviewScreen({
    super.key,
    this.imageBytes,
    required this.camera,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool _isSaving = false;
  bool _isProcessing = false;
  double _effectIntensity = 1.0;

  @override
  Widget build(BuildContext context) {
    // Preview screen stays dark - part of camera/capture workflow
    final tc = context.colors;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.camera.name,
          style: AppTypography.headlineMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _savePhoto,
              child: Text(
                'Save',
                style: AppTypography.labelLarge.copyWith(
                  color: tc.accent,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Image preview
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey.shade900,
                  child: widget.imageBytes != null
                      ? Image.memory(
                          widget.imageBytes!,
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo,
                                size: 80,
                                color: Colors.white.withAlpha(77),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Photo Preview',
                                style: AppTypography.bodyLarge.copyWith(
                                  color: Colors.white.withAlpha(128),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(tc.accent),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Effect intensity slider
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tc.cardSurface,
              border: Border(
                top: BorderSide(color: tc.borderSubtle),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Effect Intensity',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${(_effectIntensity * 100).round()}%',
                      style: AppTypography.monoMedium.copyWith(
                        color: tc.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: tc.accent,
                    inactiveTrackColor: tc.borderSubtle,
                    thumbColor: tc.accent,
                    overlayColor: tc.accent.withAlpha(51),
                  ),
                  child: Slider(
                    value: _effectIntensity,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setState(() {
                        _effectIntensity = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom actions
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Retake',
                  onTap: () => Navigator.pop(context),
                ),
                _buildActionButton(
                  icon: Icons.tune,
                  label: 'Adjust',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: _sharePhoto,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final tc = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tc.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tc.borderSubtle),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePhoto() async {
    setState(() => _isSaving = true);

    // Simulate saving
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo saved to gallery',
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
          backgroundColor: context.colors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _sharePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share functionality coming soon',
          style: AppTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: context.colors.cardSurface,
      ),
    );
  }
}
