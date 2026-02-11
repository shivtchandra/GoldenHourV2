import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/camera_model.dart';

/// Premium film effect overlay with glassmorphic indicators
class FilmEffectOverlay extends StatelessWidget {
  final CameraModel camera;
  final double opacity;
  final int frameCount;
  final String? aspectRatio;

  const FilmEffectOverlay({
    super.key,
    required this.camera,
    this.opacity = 0.6,
    this.frameCount = 24,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          // Aspect Ratio Masking
          if (aspectRatio != null) _buildAspectRatioMask(aspectRatio!),
          // Vignette effect
          if (camera.pipeline.vignetteStrength > 0)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withAlpha(
                      (255 * opacity * camera.pipeline.vignetteStrength * 0.7).toInt(),
                    ),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

          // Film border effect
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black.withAlpha(40),
                width: 2,
              ),
            ),
          ),

          // NOTE: Scanline effect REMOVED - was causing visible lines on photos
          // The effect was supposed to be UI-only but was appearing in captures

          // Film Grain Overlay
          if (camera.pipeline.grainStrength > 0)
            Opacity(
              opacity: camera.pipeline.grainStrength * 0.15,
              child: CustomPaint(
                painter: _GrainPainter(),
                size: Size.infinite,
              ),
            ),
        ],
      ),
    );
  }
}

/// Dynamic grain painter for analog texture
class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..strokeWidth = 1.2;

    final random = math.Random(42); // Seed for consistency but could be changed per frame
    
    // Draw ~1500 dots for grain
    for (int i = 0; i < 1500; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      canvas.drawPoints(PointMode.points, [Offset(x, y)], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Subtle scanline effect painter for film aesthetic
/// NOTE: This is a UI-only overlay and does NOT appear in saved photos.
/// The effect is purely visual for the viewfinder experience.
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha(4) // Reduced from 8 to 4 for subtler effect
      ..strokeWidth = 0.5; // Thinner lines

    // Draw lines every 6 pixels instead of 4 for less visible effect
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildAspectRatioMask(String ratio) {
  return Builder(builder: (context) {
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    double targetRatio = 1.0;
    bool applyMask = true;

    if (ratio == '1:1') {
      targetRatio = 1.0;
    } else if (ratio == '16:9') {
      targetRatio = 16 / 9;
    } else if (ratio == '4:5') {
      targetRatio = 4 / 5;
    } else if (ratio == 'Original' || ratio == '3:4') {
      targetRatio = 3 / 4;
    } else {
      applyMask = false;
    }

    if (!applyMask) return const SizedBox.shrink();

    final targetH = screenW / targetRatio;
    double top = 0;
    
    if (targetH < screenH) {
      top = (screenH - targetH) / 2;
    }

    if (top <= 0) return const SizedBox.shrink();

    return Positioned.fill(
      child: Column(
        children: [
          Container(height: top, color: Colors.black.withOpacity(0.9)),
          const Spacer(),
          Container(height: top, color: Colors.black.withOpacity(0.9)),
        ],
      ),
    );
  });
}
