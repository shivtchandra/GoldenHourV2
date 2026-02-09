import 'dart:math' as math;
import 'package:image/image.dart' as img;
import '../../../features/camera/data/models/pipeline_config.dart';

/// Service for applying film camera effects to images
class ImageProcessingService {
  ImageProcessingService();

  /// Main method to apply film camera effect to an image
  img.Image applyFilmEffect({
    required img.Image inputImage,
    required PipelineConfig pipeline,
    String? date,
  }) {
    // Create working copy without resampling to preserve quality
    img.Image processed = img.Image.from(inputImage);

    // Processing pipeline order (important for realistic results):

    // 1. Black & White Conversion (if needed)
    if (pipeline.blackWhiteMode) {
      processed = _convertToBlackAndWhite(processed, pipeline);
    }

    // 2. Color Temperature & Tint
    processed = _adjustTemperatureAndTint(
      processed,
      pipeline.temperature,
      pipeline.tint,
    );

    // 3. Exposure & Contrast
    processed = _adjustExposureAndContrast(
      processed,
      pipeline.exposureBias,
      pipeline.contrastBias,
    );

    // 4. Highlights & Shadows
    processed = _adjustHighlightsAndShadows(
      processed,
      pipeline.highlights,
      pipeline.shadows,
    );

    // 5. Saturation
    if (!pipeline.blackWhiteMode) {
      processed = _adjustSaturation(processed, pipeline.saturation);
    }

    // 6. Clarity
    if (pipeline.clarity != 0) {
      processed = _adjustClarity(processed, pipeline.clarity);
    }

    // 7. Split Toning (if specified)
    if (pipeline.splitToning != null) {
      processed = _applySplitToning(processed, pipeline.splitToning!);
    }

    // 8. Special Effects (order matters)
    if (pipeline.infraredMode) {
      processed = _applyInfraredEffect(processed);
    }
    if (pipeline.redscaleMode == true) {
      processed = _applyRedscaleEffect(processed);
    }
    if (pipeline.crossProcessed) {
      processed = _applyCrossProcessEffect(processed);
    }
    if (pipeline.expiredMode) {
      processed = _applyExpiredFilmEffect(processed, pipeline.fogLevel ?? 0.1);
    }

    // 9. Film Grain (before vignette for realistic look)
    processed = _applyGrain(
      processed,
      pipeline.grainStrength,
      pipeline.grainSize,
    );

    // 10. Vignette
    processed = _applyVignette(processed, pipeline.vignetteStrength);

    // 11. Light Leaks (toy cameras)
    if (pipeline.lightLeaks) {
      processed = _applyLightLeaks(
        processed,
        pipeline.lightLeakIntensity ?? 0.3,
      );
    }

    // 12. Soft Focus (toy cameras & instant films)
    if (pipeline.softFocus > 0) {
      processed = _applySoftFocus(processed, pipeline.softFocus);
    }

    // 13. Halation (Cinestill)
    if (pipeline.halation) {
      processed = _applyHalation(
        processed,
        pipeline.halationColor ?? '#ff3333',
        pipeline.halationStrength ?? 0.4,
      );
    }

    // 14. Dreamy Glow (Polaroid SX-70, Diana F+)
    if (pipeline.dreamyGlow != null && pipeline.dreamyGlow! > 0) {
      processed = _applyDreamyGlow(processed, pipeline.dreamyGlow!);
    }

     // 15. Instant Film Border (last step)
    if (pipeline.instantBorder == true || pipeline.instantFilm) {
      processed = _addInstantBorder(processed, date: date ?? pipeline.dateStampText);
    } else if (pipeline.showDateStamp) {
      processed = _applyDateStamp(processed, date: date ?? pipeline.dateStampText);
    }

    return processed;
  }

  // ===================================================
  // EFFECT IMPLEMENTATION METHODS
  // ===================================================

  /// Convert to Black & White with optional adjustments
  img.Image _convertToBlackAndWhite(img.Image image, PipelineConfig pipeline) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Luminance calculation (perceptual - matches human eye)
        int gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

        // Apply red sensitivity for special B&W films (like Rollei Retro)
        if (pipeline.redSensitivity != null) {
          gray = ((gray * 0.7) + (r * 0.3 * pipeline.redSensitivity!))
              .round()
              .clamp(0, 255);
        }

        // Black point adjustment
        if (pipeline.blackPoint != null) {
          gray = (gray + (255 * pipeline.blackPoint!)).round().clamp(0, 255);
        }

        image.setPixelRgba(x, y, gray, gray, gray, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Adjust color temperature and tint
  img.Image _adjustTemperatureAndTint(
    img.Image image,
    double temperature,
    double tint,
  ) {
    // Temperature: -50 (cool/blue) to +50 (warm/yellow)
    // Tint: -50 (green) to +50 (magenta)

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Temperature adjustment
        if (temperature > 0) {
          // Warm: increase red, decrease blue
          r = (r + temperature * 2.5).round().clamp(0, 255);
          b = (b - temperature * 1.5).round().clamp(0, 255);
        } else if (temperature < 0) {
          // Cool: increase blue, decrease red
          b = (b + temperature.abs() * 2.5).round().clamp(0, 255);
          r = (r - temperature.abs() * 1.5).round().clamp(0, 255);
        }

        // Tint adjustment
        if (tint > 0) {
          // Magenta: increase red and blue, decrease green
          r = (r + tint * 1.2).round().clamp(0, 255);
          b = (b + tint * 1.2).round().clamp(0, 255);
          g = (g - tint * 0.8).round().clamp(0, 255);
        } else if (tint < 0) {
          // Green: increase green, decrease red and blue
          g = (g + tint.abs() * 2.0).round().clamp(0, 255);
          r = (r - tint.abs() * 0.5).round().clamp(0, 255);
          b = (b - tint.abs() * 0.5).round().clamp(0, 255);
        }

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Adjust exposure and contrast
  img.Image _adjustExposureAndContrast(
    img.Image image,
    double exposureBias,
    double contrastBias,
  ) {
    // Exposure: -2 to +2 EV
    double exposureMultiplier = exposureBias >= 0
        ? 1.0 + exposureBias * 0.5
        : 1.0 + exposureBias * 0.3;

    // Contrast formula
    double contrastFactor = (259 * (contrastBias * 255 + 255)) /
        (255 * (259 - contrastBias * 255));

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Apply exposure
        r = (r * exposureMultiplier).round().clamp(0, 255);
        g = (g * exposureMultiplier).round().clamp(0, 255);
        b = (b * exposureMultiplier).round().clamp(0, 255);

        // Apply contrast
        r = (contrastFactor * (r - 128) + 128).round().clamp(0, 255);
        g = (contrastFactor * (g - 128) + 128).round().clamp(0, 255);
        b = (contrastFactor * (b - 128) + 128).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Adjust highlights and shadows independently
  img.Image _adjustHighlightsAndShadows(
    img.Image image,
    double highlights,
    double shadows,
  ) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Calculate luminance
        double lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

        // Adjust shadows (darker tones)
        if (lum < 0.5 && shadows != 0) {
          double shadowFactor = 1.0 + (shadows * (1.0 - lum * 2));
          r = (r * shadowFactor).round().clamp(0, 255);
          g = (g * shadowFactor).round().clamp(0, 255);
          b = (b * shadowFactor).round().clamp(0, 255);
        }

        // Adjust highlights (brighter tones)
        if (lum > 0.5 && highlights != 0) {
          double highlightFactor = 1.0 + (highlights * (lum * 2 - 1));
          r = (r * highlightFactor).round().clamp(0, 255);
          g = (g * highlightFactor).round().clamp(0, 255);
          b = (b * highlightFactor).round().clamp(0, 255);
        }

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Adjust saturation
  img.Image _adjustSaturation(img.Image image, double saturation) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Calculate grayscale value
        double gray = 0.299 * r + 0.587 * g + 0.114 * b;

        // Interpolate between gray and original color
        r = (gray + saturation * (r - gray)).round().clamp(0, 255);
        g = (gray + saturation * (g - gray)).round().clamp(0, 255);
        b = (gray + saturation * (b - gray)).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply film grain texture
  img.Image _applyGrain(
    img.Image image,
    double grainStrength,
    double grainSize,
  ) {
    final random = math.Random();

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Generate grain noise (-1 to 1)
        double noise = (random.nextDouble() * 2 - 1) * grainStrength * 40;

        // Apply grain more to mid-tones (realistic film behavior)
        double lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
        double midtoneBoost = 1.0 - ((lum - 0.5).abs() * 2);
        noise *= midtoneBoost;

        // Scale by grain size
        noise *= grainSize;

        r = (r + noise).round().clamp(0, 255);
        g = (g + noise).round().clamp(0, 255);
        b = (b + noise).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply vignette darkening
  img.Image _applyVignette(img.Image image, double vignetteStrength) {
    int centerX = image.width ~/ 2;
    int centerY = image.height ~/ 2;
    double maxDistance = math.sqrt(centerX * centerX + centerY * centerY);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Calculate distance from center
        double dx = (x - centerX).toDouble();
        double dy = (y - centerY).toDouble();
        double distance = math.sqrt(dx * dx + dy * dy);
        double ratio = distance / maxDistance;

        // Vignette falloff (quadratic for natural look)
        double vignette = 1.0 - (ratio * ratio * vignetteStrength);

        r = (r * vignette).round().clamp(0, 255);
        g = (g * vignette).round().clamp(0, 255);
        b = (b * vignette).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply split toning (different colors to shadows and highlights)
  img.Image _applySplitToning(img.Image image, SplitToning splitToning) {
    int sr = splitToning.shadowColor.red;
    int sg = splitToning.shadowColor.green;
    int sb = splitToning.shadowColor.blue;

    int hr = splitToning.highlightColor.red;
    int hg = splitToning.highlightColor.green;
    int hb = splitToning.highlightColor.blue;

    double balance = splitToning.balance;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Calculate luminance
        double lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

        // Calculate toning strengths
        double shadowStrength = (1.0 - lum) * 0.15;
        double highlightStrength = lum * 0.15;

        // Apply balance
        if (balance > 0) {
          highlightStrength *= (1.0 + balance);
        } else if (balance < 0) {
          shadowStrength *= (1.0 - balance);
        }

        r = (r + sr * shadowStrength + hr * highlightStrength)
            .round()
            .clamp(0, 255);
        g = (g + sg * shadowStrength + hg * highlightStrength)
            .round()
            .clamp(0, 255);
        b = (b + sb * shadowStrength + hb * highlightStrength)
            .round()
            .clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply infrared effect (Aerochrome simulation)
  img.Image _applyInfraredEffect(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Swap channels: green foliage becomes magenta
        int newR = (g * 1.3).round().clamp(0, 255);
        int newG = (b * 0.7).round().clamp(0, 255);
        int newB = (r * 1.5).round().clamp(0, 255);

        image.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply halation effect (Cinestill red glow around lights)
  img.Image _applyHalation(
    img.Image image,
    String halationColor,
    double halationStrength,
  ) {
    // Parse hex color
    int hr = int.parse(halationColor.substring(1, 3), radix: 16);
    int hg = int.parse(halationColor.substring(3, 5), radix: 16);
    int hb = int.parse(halationColor.substring(5, 7), radix: 16);

    // Find and enhance bright areas
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        double luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;

        // Apply halation to bright areas (lights)
        if (luminance > 0.8) {
          double amount = (luminance - 0.8) / 0.2 * halationStrength;

          r = (r + hr * amount * 0.5).round().clamp(0, 255);
          g = (g + hg * amount * 0.5).round().clamp(0, 255);
          b = (b + hb * amount * 0.5).round().clamp(0, 255);

          image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
        }
      }
    }

    // Apply blur to halation areas for glow effect
    return img.gaussianBlur(image, radius: 3);
  }

  /// Apply light leaks (toy camera effect)
  img.Image _applyLightLeaks(img.Image image, double intensity) {
    final random = math.Random();

    // Create 2-3 random light leak areas
    for (int i = 0; i < 2; i++) {
      int leakX = random.nextInt(image.width);
      int leakY = random.nextInt(image.height);
      int leakRadius = random.nextInt(200) + 100;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          double distance = math.sqrt(
            (x - leakX) * (x - leakX) + (y - leakY) * (y - leakY),
          );

          if (distance < leakRadius) {
            final pixel = image.getPixel(x, y);
            int r = pixel.r.toInt();
            int g = pixel.g.toInt();
            int b = pixel.b.toInt();

            double falloff = 1.0 - (distance / leakRadius);
            int leakAmount = (falloff * intensity * 100).round();

            // Warm orange light leak
            r = (r + leakAmount * 1.5).round().clamp(0, 255);
            g = (g + leakAmount * 1.2).round().clamp(0, 255);
            b = (b + leakAmount * 0.5).round().clamp(0, 255);

            image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
          }
        }
      }
    }
    return image;
  }

  /// Add instant film border (Polaroid/Instax style)
  img.Image _addInstantBorder(img.Image image, {String? date}) {
    // 1. Force Square crop (1:1) for authentic Polaroid look
    int size = math.min(image.width, image.height);
    int offsetX = (image.width - size) ~/ 2;
    int offsetY = (image.height - size) ~/ 2;
    
    img.Image squareImage = img.copyCrop(
      image,
      x: offsetX,
      y: offsetY,
      width: size,
      height: size,
    );

    // 2. Create larger image with white/cream border
    int borderWidth = (size * 0.08).round();
    int borderTop = (size * 0.08).round();
    int borderBottom = (size * 0.30).round(); // Iconic wide bottom

    img.Image bordered = img.Image(
      width: size + borderWidth * 2,
      height: size + borderTop + borderBottom,
    );

    // Fill with authentic Polaroid cream color
    img.fill(bordered, color: img.ColorRgba8(252, 252, 248, 255));

    // Copy square image into the frame
    img.compositeImage(
      bordered,
      squareImage,
      dstX: borderWidth,
      dstY: borderTop,
    );

    // 3. Draw Date (if available) - Using simple built-in font for burning into file
    if (date != null) {
      // Position date in the middle of the bottom border
      int textX = (bordered.width ~/ 2) - (date.length * 7);
      int textY = bordered.height - (borderBottom ~/ 2) - 10;
      img.drawString(bordered, date, font: img.arial24, x: textX, y: textY, color: img.ColorRgba8(180, 180, 170, 150));
    }

    return bordered;
  }

  /// Apply a subtle date stamp to a regular photo
  img.Image _applyDateStamp(img.Image image, {String? date}) {
    if (date == null) return image;
    
    // Position in bottom right corner
    int x = image.width - (date.length * 15) - 40;
    int y = image.height - 60;
    
    // Draw subtle orange-ish digital date stamp (retro style)
    img.drawString(image, date, font: img.arial24, x: x, y: y, color: img.ColorRgba8(255, 140, 50, 180));
    
    return image;
  }

  /// Apply soft focus blur
  img.Image _applySoftFocus(img.Image image, double softFocus) {
    return img.gaussianBlur(image, radius: (softFocus * 15).toInt().clamp(1, 30));
  }

  /// Apply dreamy glow effect
  img.Image _applyDreamyGlow(img.Image image, double glowStrength) {
    // Create soft glow by blurring and blending
    img.Image blurred = img.gaussianBlur(img.Image.from(image), radius: 20);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final original = image.getPixel(x, y);
        final glow = blurred.getPixel(x, y);

        int r = ((original.r.toInt() * (1 - glowStrength)) +
                (glow.r.toInt() * glowStrength))
            .round()
            .clamp(0, 255);
        int g = ((original.g.toInt() * (1 - glowStrength)) +
                (glow.g.toInt() * glowStrength))
            .round()
            .clamp(0, 255);
        int b = ((original.b.toInt() * (1 - glowStrength)) +
                (glow.b.toInt() * glowStrength))
            .round()
            .clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, original.a.toInt());
      }
    }
    return image;
  }

  /// Adjust clarity
  img.Image _adjustClarity(img.Image image, double clarity) {
    if (clarity > 0) {
      // Sharpen using unsharp mask
      img.Image blurred = img.gaussianBlur(img.Image.from(image), radius: 2);

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final original = image.getPixel(x, y);
          final blurredPixel = blurred.getPixel(x, y);

          int r = (original.r.toInt() +
                  clarity * (original.r.toInt() - blurredPixel.r.toInt()))
              .round()
              .clamp(0, 255);
          int g = (original.g.toInt() +
                  clarity * (original.g.toInt() - blurredPixel.g.toInt()))
              .round()
              .clamp(0, 255);
          int b = (original.b.toInt() +
                  clarity * (original.b.toInt() - blurredPixel.b.toInt()))
              .round()
              .clamp(0, 255);

          image.setPixelRgba(x, y, r, g, b, original.a.toInt());
        }
      }
      return image;
    } else if (clarity < 0) {
      // Soften with blur
      return img.gaussianBlur(image, radius: (clarity.abs() * 3).toInt().clamp(1, 10));
    }
    return image;
  }

  /// Apply redscale effect
  img.Image _applyRedscaleEffect(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Boost red, reduce blue for apocalyptic look
        int newR = (r * 1.8).round().clamp(0, 255);
        int newG = (g * 0.8).round().clamp(0, 255);
        int newB = (b * 0.3).round().clamp(0, 255);

        image.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply cross-process effect
  img.Image _applyCrossProcessEffect(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Channel manipulation for cross-processed look
        int newR = ((r * 1.2) + (g * 0.1)).round().clamp(0, 255);
        int newG = ((g * 0.9) - (b * 0.1)).round().clamp(0, 255);
        int newB = ((b * 1.3) + (r * 0.05)).round().clamp(0, 255);

        image.setPixelRgba(x, y, newR, newG, newB, pixel.a.toInt());
      }
    }
    return image;
  }

  /// Apply expired film effect
  img.Image _applyExpiredFilmEffect(img.Image image, double fogLevel) {
    final random = math.Random();

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Add fog (lift blacks)
        int fogAmount = (255 * fogLevel).round();
        r = (r + fogAmount).round().clamp(0, 255);
        g = (g + fogAmount).round().clamp(0, 255);
        b = (b + fogAmount).round().clamp(0, 255);

        // Random color shift
        int colorShift = (random.nextDouble() * 20 - 10).round();
        r = (r + colorShift).round().clamp(0, 255);

        image.setPixelRgba(x, y, r, g, b, pixel.a.toInt());
      }
    }
    return image;
  }
}
