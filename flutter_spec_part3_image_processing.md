# 📷 Film Camera App - Flutter Development Specification
## Part 3: Image Processing Pipeline & Implementation

---

## 🎨 Image Processing Service Architecture

### Core Processing Workflow

```dart
// lib/core/services/image_processing_service.dart

import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'dart:math' as math;

class ImageProcessingService {
  
  /// Main method to apply film camera effect to an image
  Future<img.Image> applyFilmEffect({
    required img.Image inputImage,
    required PipelineConfig pipeline,
  }) async {
    img.Image processed = img.copyResize(
      inputImage, 
      width: inputImage.width,
      height: inputImage.height,
    );
    
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
    processed = _adjustSaturation(processed, pipeline.saturation);
    
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
        pipeline.halationColor ?? "#ff3333",
        pipeline.halationStrength ?? 0.4,
      );
    }
    
    // 14. Dreamy Glow (Polaroid SX-70, Diana F+)
    if (pipeline.dreamyGlow != null && pipeline.dreamyGlow! > 0) {
      processed = _applyDreamyGlow(processed, pipeline.dreamyGlow!);
    }
    
    // 15. Instant Film Border (last step)
    if (pipeline.instantBorder == true) {
      processed = _addInstantBorder(processed);
    }
    
    return processed;
  }
  
  // ===================================================
  // EFFECT IMPLEMENTATION METHODS
  // ===================================================
  
  /// Convert to Black & White with optional adjustments
  img.Image _convertToBlackAndWhite(
    img.Image image,
    PipelineConfig pipeline,
  ) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
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
        
        image.setPixel(x, y, img.getColor(gray, gray, gray));
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
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
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
        
        image.setPixel(x, y, img.getColor(r, g, b));
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
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Apply exposure
        r = (r * exposureMultiplier).round().clamp(0, 255);
        g = (g * exposureMultiplier).round().clamp(0, 255);
        b = (b * exposureMultiplier).round().clamp(0, 255);
        
        // Apply contrast
        r = (contrastFactor * (r - 128) + 128).round().clamp(0, 255);
        g = (contrastFactor * (g - 128) + 128).round().clamp(0, 255);
        b = (contrastFactor * (b - 128) + 128).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(r, g, b));
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
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
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
        
        image.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return image;
  }
  
  /// Adjust saturation
  img.Image _adjustSaturation(img.Image image, double saturation) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Calculate grayscale value
        double gray = 0.299 * r + 0.587 * g + 0.114 * b;
        
        // Interpolate between gray and original color
        r = (gray + saturation * (r - gray)).round().clamp(0, 255);
        g = (gray + saturation * (g - gray)).round().clamp(0, 255);
        b = (gray + saturation * (b - gray)).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(r, g, b));
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
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
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
        
        image.setPixel(x, y, img.getColor(r, g, b));
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
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Calculate distance from center
        double dx = x - centerX;
        double dy = y - centerY;
        double distance = math.sqrt(dx * dx + dy * dy);
        double ratio = distance / maxDistance;
        
        // Vignette falloff (quadratic for natural look)
        double vignette = 1.0 - (ratio * ratio * vignetteStrength);
        
        r = (r * vignette).round().clamp(0, 255);
        g = (g * vignette).round().clamp(0, 255);
        b = (b * vignette).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return image;
  }
  
  /// Apply split toning (different colors to shadows and highlights)
  img.Image _applySplitToning(
    img.Image image,
    SplitToning splitToning,
  ) {
    int sr = splitToning.shadowColor.red;
    int sg = splitToning.shadowColor.green;
    int sb = splitToning.shadowColor.blue;
    
    int hr = splitToning.highlightColor.red;
    int hg = splitToning.highlightColor.green;
    int hb = splitToning.highlightColor.blue;
    
    double balance = splitToning.balance;
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
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
            .round().clamp(0, 255);
        g = (g + sg * shadowStrength + hg * highlightStrength)
            .round().clamp(0, 255);
        b = (b + sb * shadowStrength + hb * highlightStrength)
            .round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return image;
  }
  
  /// Apply infrared effect (Aerochrome simulation)
  img.Image _applyInfraredEffect(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Swap channels: green foliage becomes magenta
        int newR = (g * 1.3).round().clamp(0, 255);
        int newG = (b * 0.7).round().clamp(0, 255);
        int newB = (r * 1.5).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(newR, newG, newB));
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
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        double luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
        
        // Apply halation to bright areas (lights)
        if (luminance > 0.8) {
          double amount = (luminance - 0.8) / 0.2 * halationStrength;
          
          r = (r + hr * amount * 0.5).round().clamp(0, 255);
          g = (g + hg * amount * 0.5).round().clamp(0, 255);
          b = (b + hb * amount * 0.5).round().clamp(0, 255);
        }
        
        image.setPixel(x, y, img.getColor(r, g, b));
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
            (x - leakX) * (x - leakX) + (y - leakY) * (y - leakY)
          );
          
          if (distance < leakRadius) {
            int pixel = image.getPixel(x, y);
            int r = img.getRed(pixel);
            int g = img.getGreen(pixel);
            int b = img.getBlue(pixel);
            
            double falloff = 1.0 - (distance / leakRadius);
            int leakAmount = (falloff * intensity * 100).round();
            
            // Warm orange light leak
            r = (r + leakAmount * 1.5).round().clamp(0, 255);
            g = (g + leakAmount * 1.2).round().clamp(0, 255);
            b = (b + leakAmount * 0.5).round().clamp(0, 255);
            
            image.setPixel(x, y, img.getColor(r, g, b));
          }
        }
      }
    }
    return image;
  }
  
  /// Add instant film border (Polaroid/Instax style)
  img.Image _addInstantBorder(img.Image image) {
    // Create larger image with white border
    int borderWidth = (image.width * 0.05).round();
    int borderTop = (image.height * 0.05).round();
    int borderBottom = (image.height * 0.15).round(); // Larger bottom
    
    img.Image bordered = img.Image(
      width: image.width + borderWidth * 2,
      height: image.height + borderTop + borderBottom,
    );
    
    // Fill with cream color
    img.fill(bordered, color: img.ColorRgb8(250, 248, 240));
    
    // Copy original image into center
    img.compositeImage(
      bordered,
      image,
      dstX: borderWidth,
      dstY: borderTop,
    );
    
    return bordered;
  }
  
  // Additional helper methods for other effects...
  img.Image _applySoftFocus(img.Image image, double softFocus) {
    return img.gaussianBlur(image, radius: (softFocus * 15).toInt());
  }
  
  img.Image _applyDreamyGlow(img.Image image, double glowStrength) {
    // Create soft glow by blurring and blending
    img.Image blurred = img.gaussianBlur(image, radius: 20);
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int original = image.getPixel(x, y);
        int glow = blurred.getPixel(x, y);
        
        int r = ((img.getRed(original) * (1 - glowStrength)) + 
                 (img.getRed(glow) * glowStrength)).round().clamp(0, 255);
        int g = ((img.getGreen(original) * (1 - glowStrength)) + 
                 (img.getGreen(glow) * glowStrength)).round().clamp(0, 255);
        int b = ((img.getBlue(original) * (1 - glowStrength)) + 
                 (img.getBlue(glow) * glowStrength)).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return image;
  }
  
  img.Image _adjustClarity(img.Image image, double clarity) {
    if (clarity > 0) {
      // Sharpen using unsharp mask
      img.Image blurred = img.gaussianBlur(image, radius: 2);
      
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          int original = image.getPixel(x, y);
          int blurredPixel = blurred.getPixel(x, y);
          
          int r = (img.getRed(original) + clarity * 
                  (img.getRed(original) - img.getRed(blurredPixel)))
                  .round().clamp(0, 255);
          int g = (img.getGreen(original) + clarity * 
                  (img.getGreen(original) - img.getGreen(blurredPixel)))
                  .round().clamp(0, 255);
          int b = (img.getBlue(original) + clarity * 
                  (img.getBlue(original) - img.getBlue(blurredPixel)))
                  .round().clamp(0, 255);
          
          image.setPixel(x, y, img.getColor(r, g, b));
        }
      }
      return image;
    } else if (clarity < 0) {
      // Soften with blur
      return img.gaussianBlur(image, radius: (clarity.abs() * 3).toInt());
    }
    return image;
  }
  
  img.Image _applyRedscaleEffect(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Boost red, reduce blue for apocalyptic look
        int newR = (r * 1.8).round().clamp(0, 255);
        int newG = (g * 0.8).round().clamp(0, 255);
        int newB = (b * 0.3).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(newR, newG, newB));
      }
    }
    return image;
  }
  
  img.Image _applyCrossProcessEffect(img.Image image) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Channel manipulation for cross-processed look
        int newR = ((r * 1.2) + (g * 0.1)).round().clamp(0, 255);
        int newG = ((g * 0.9) - (b * 0.1)).round().clamp(0, 255);
        int newB = ((b * 1.3) + (r * 0.05)).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(newR, newG, newB));
      }
    }
    return image;
  }
  
  img.Image _applyExpiredFilmEffect(img.Image image, double fogLevel) {
    final random = math.Random();
    
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pixel = image.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        
        // Add fog (lift blacks)
        int fogAmount = (255 * fogLevel).round();
        r = (r + fogAmount).round().clamp(0, 255);
        g = (g + fogAmount).round().clamp(0, 255);
        b = (b + fogAmount).round().clamp(0, 255);
        
        // Random color shift
        int colorShift = (random.nextDouble() * 20 - 10).round();
        r = (r + colorShift).round().clamp(0, 255);
        
        image.setPixel(x, y, img.getColor(r, g, b));
      }
    }
    return image;
  }
}
```

---

## 🚀 Implementation Roadmap

### Phase 1: Core Infrastructure (Week 1-2)
- [ ] Set up Flutter project structure
- [ ] Implement data models (CameraModel, PipelineConfig)
- [ ] Create CameraRepository with all 30 cameras
- [ ] Set up state management (Riverpod/Provider)
- [ ] Design basic UI theme and color system

### Phase 2: Image Processing (Week 3-4)
- [ ] Implement ImageProcessingService
- [ ] Test each effect individually
- [ ] Optimize performance (use isolates for heavy processing)
- [ ] Implement real-time preview (lower resolution)
- [ ] Add progress indicators

### Phase 3: Camera Integration (Week 5-6)
- [ ] Implement camera screen with live preview
- [ ] Add real-time effect overlay
- [ ] Implement shutter button with animations
- [ ] Add focus, zoom, and flash controls
- [ ] Test on multiple devices

### Phase 4: UI/UX Polish (Week 7-8)
- [ ] Design and implement camera selector screen
- [ ] Create camera detail bottom sheets
- [ ] Implement preview/edit screen
- [ ] Add gallery functionality
- [ ] Design settings screen

### Phase 5: Monetization & Polish (Week 9-10)
- [ ] Integrate in-app purchases
- [ ] Implement PRO camera unlock system
- [ ] Add analytics and crash reporting
- [ ] Performance optimization
- [ ] Beta testing and bug fixes

### Phase 6: Launch Preparation (Week 11-12)
- [ ] Create app store assets (screenshots, videos)
- [ ] Write app description and keywords
- [ ] Final QA testing
- [ ] Submit to App Store and Google Play

---

## 📝 Testing Checklist

### Image Processing Tests
- [ ] Test each camera profile produces expected results
- [ ] Verify grain appears realistic at different strengths
- [ ] Check vignette doesn't create hard edges
- [ ] Ensure split toning blends smoothly
- [ ] Test special effects (halation, light leaks) work correctly
- [ ] Verify instant film borders are proportional

### Performance Tests
- [ ] Process time for 4K images < 3 seconds
- [ ] Real-time preview runs at 30fps minimum
- [ ] Memory usage stays below 500MB
- [ ] No memory leaks after 100 captures
- [ ] App launches in < 2 seconds

### User Experience Tests
- [ ] Camera selector loads instantly
- [ ] Switching cameras feels responsive
- [ ] Shutter button has satisfying feedback
- [ ] Undo/redo works correctly
- [ ] Gallery scrolling is smooth
- [ ] Export quality matches preview

---

**Continue to Part 4 for complete implementation examples and code snippets...**
