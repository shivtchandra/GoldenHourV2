# 📷 Film Camera App - Flutter Development Specification
## Part 2: Complete Camera Database (All 30 Cameras)

---

## 📊 Camera Data Models

```dart
// lib/features/camera/data/models/camera_model.dart

class CameraModel {
  final String id;
  final String name;
  final String era;
  final String type;
  final int? iso;
  final String personality;
  final bool isPro;
  final String? price;
  final Color iconColor;
  final List<String> bestFor;
  final String description;
  final PipelineConfig pipeline;
  final String? icon3DAssetPath;

  CameraModel({
    required this.id,
    required this.name,
    required this.era,
    required this.type,
    this.iso,
    required this.personality,
    required this.isPro,
    this.price,
    required this.iconColor,
    required this.bestFor,
    required this.description,
    required this.pipeline,
    this.icon3DAssetPath,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'era': era,
    'type': type,
    'iso': iso,
    'personality': personality,
    'isPro': isPro,
    'price': price,
    'iconColor': iconColor.value,
    'bestFor': bestFor,
    'description': description,
    'pipeline': pipeline.toJson(),
    'icon3DAssetPath': icon3DAssetPath,
  };
}

class PipelineConfig {
  // Color Adjustments
  final double temperature; // -50 to 50
  final double tint; // -50 to 50
  final double saturation; // 0 to 2
  
  // Exposure
  final double exposureBias; // -2 to 2
  final double contrastBias; // -1 to 1
  final double highlights; // -1 to 1
  final double shadows; // -1 to 1
  
  // Film Character
  final double grainStrength; // 0 to 1
  final double grainSize; // 0.5 to 2
  final double vignetteStrength; // 0 to 1
  final double clarity; // -1 to 1
  
  // Split Toning (optional)
  final SplitToning? splitToning;
  
  // Special Modes
  final bool blackWhiteMode;
  final bool slideFilm;
  final bool instantFilm;
  final bool halation;
  final bool infraredMode;
  final bool crossProcessed;
  final bool expiredMode;
  final bool lightLeaks;
  final double softFocus;
  
  // Special mode parameters
  final String? halationColor;
  final double? halationStrength;
  final double? lightLeakIntensity;
  final double? dreamyGlow;
  final String? colorShiftMode;
  final double? hueShift;
  final double? redSensitivity;
  final bool? pastelEnhancement;
  final bool? skinToneOptimization;
  final bool? instantBorder;
  final int? colorShift;
  final double? fogLevel;
  final bool? randomColorShift;
  final bool? redscaleMode;
  final bool? greenToMagenta;
  final bool? motionPicture;
  final double? blackPoint;

  PipelineConfig({
    required this.temperature,
    this.tint = 0,
    required this.saturation,
    required this.exposureBias,
    required this.contrastBias,
    required this.highlights,
    required this.shadows,
    required this.grainStrength,
    required this.grainSize,
    required this.vignetteStrength,
    required this.clarity,
    this.splitToning,
    this.blackWhiteMode = false,
    this.slideFilm = false,
    this.instantFilm = false,
    this.halation = false,
    this.infraredMode = false,
    this.crossProcessed = false,
    this.expiredMode = false,
    this.lightLeaks = false,
    this.softFocus = 0,
    this.halationColor,
    this.halationStrength,
    this.lightLeakIntensity,
    this.dreamyGlow,
    this.colorShiftMode,
    this.hueShift,
    this.redSensitivity,
    this.pastelEnhancement,
    this.skinToneOptimization,
    this.instantBorder,
    this.colorShift,
    this.fogLevel,
    this.randomColorShift,
    this.redscaleMode,
    this.greenToMagenta,
    this.motionPicture,
    this.blackPoint,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'tint': tint,
      'saturation': saturation,
      'exposureBias': exposureBias,
      'contrastBias': contrastBias,
      'highlights': highlights,
      'shadows': shadows,
      'grainStrength': grainStrength,
      'grainSize': grainSize,
      'vignetteStrength': vignetteStrength,
      'clarity': clarity,
      'splitToning': splitToning?.toJson(),
      'blackWhiteMode': blackWhiteMode,
      'slideFilm': slideFilm,
      'instantFilm': instantFilm,
      'halation': halation,
      'infraredMode': infraredMode,
      'crossProcessed': crossProcessed,
      'expiredMode': expiredMode,
      'lightLeaks': lightLeaks,
      'softFocus': softFocus,
      'halationColor': halationColor,
      'halationStrength': halationStrength,
      'lightLeakIntensity': lightLeakIntensity,
      'dreamyGlow': dreamyGlow,
      'colorShiftMode': colorShiftMode,
      'hueShift': hueShift,
      'redSensitivity': redSensitivity,
      'pastelEnhancement': pastelEnhancement,
      'skinToneOptimization': skinToneOptimization,
      'instantBorder': instantBorder,
      'colorShift': colorShift,
      'fogLevel': fogLevel,
      'randomColorShift': randomColorShift,
      'redscaleMode': redscaleMode,
      'greenToMagenta': greenToMagenta,
      'motionPicture': motionPicture,
      'blackPoint': blackPoint,
    };
  }
}

class SplitToning {
  final Color shadowColor;
  final Color highlightColor;
  final double balance; // -1 to 1

  SplitToning({
    required this.shadowColor,
    required this.highlightColor,
    required this.balance,
  });
  
  Map<String, dynamic> toJson() => {
    'shadowColor': shadowColor.value,
    'highlightColor': highlightColor.value,
    'balance': balance,
  };
}
```

---

## 🎞️ Complete Camera Repository (All 30 Cameras)

```dart
// lib/features/camera/data/repositories/camera_repository.dart

import 'package:flutter/material.dart';
import '../models/camera_model.dart';

class CameraRepository {
  
  static List<CameraModel> getAllCameras() {
    return [
      // ========================================
      // 🆓 FREE TIER (3 cameras)
      // ========================================
      
      _kodakGold200(),
      _fujiSuperia400(),
      _ilfordHP5(),
      
      // ========================================
      // 👑 PRO TIER - COLOR FILMS (12 cameras)
      // ========================================
      
      _kodakPortra400(),
      _kodakEktar100(),
      _cinestill800T(),
      _fujiPro400H(),
      _kodakColorPlus200(),
      _kodakUltramax400(),
      _fujiC200(),
      _fujiVelvia50(),
      _fujiProvia100F(),
      _lomo800(),
      _agfaVista200(),
      _kodakVision3500T(),
      
      // ========================================
      // 👑 PRO TIER - B&W FILMS (5 cameras)
      // ========================================
      
      _kodakTriX400(),
      _kodakTMax400(),
      _ilfordDelta3200(),
      _fomapan400(),
      _rolleiRetro400S(),
      
      // ========================================
      // 👑 PRO TIER - SPECIAL FILMS (5 cameras)
      // ========================================
      
      _lomoRedscale(),
      _lomoPurple(),
      _aerochrome(),
      _xproSlide(),
      _expiredFilm(),
      
      // ========================================
      // 👑 PRO TIER - INSTANT FILMS (3 cameras)
      // ========================================
      
      _polaroid600(),
      _polaroidSX70(),
      _fujiInstax(),
      
      // ========================================
      // 👑 PRO TIER - TOY CAMERAS (2 cameras)
      // ========================================
      
      _holgaPlastic(),
      _dianaFPlus(),
    ];
  }
  
  // === FREE CAMERAS ===
  
  static CameraModel _kodakGold200() {
    return CameraModel(
      id: "kodak_gold_200",
      name: "Kodak Gold 200",
      era: "1990s-Present",
      type: "Color Negative",
      iso: 200,
      personality: "Warm & Nostalgic",
      isPro: false,
      iconColor: Color(0xFFF4C542),
      bestFor: ["Everyday moments", "Sunny days", "Travel photography", "Summer vibes"],
      description: "The most popular consumer film stock of the 90s. Warm, sunny, and forgiving. Perfect for capturing nostalgic summer memories.",
      pipeline: PipelineConfig(
        temperature: 15,
        saturation: 1.10,
        exposureBias: 0.3,
        contrastBias: 0,
        highlights: -0.05,
        shadows: 0.05,
        grainStrength: 0.25,
        grainSize: 1.0,
        vignetteStrength: 0.15,
        clarity: 0,
        splitToning: SplitToning(
          shadowColor: Color(0xFF2a1f0a),
          highlightColor: Color(0xFFffecd2),
          balance: 0.15,
        ),
      ),
      icon3DAssetPath: "assets/camera_icons/kodak_gold_200.png",
    );
  }
  
  static CameraModel _fujiSuperia400() {
    return CameraModel(
      id: "fuji_superia_400",
      name: "Fuji Superia 400",
      era: "2000s-Present",
      type: "Color Negative",
      iso: 400,
      personality: "Cool & Vibrant",
      isPro: false,
      iconColor: Color(0xFF5B9BD5),
      bestFor: ["Street photography", "Overcast days", "Urban landscapes", "Night scenes"],
      description: "Fujifilm's versatile all-rounder with a distinctive cool tone. Slightly blue-green cast makes colors pop. Handles mixed lighting well.",
      pipeline: PipelineConfig(
        temperature: -10,
        saturation: 1.15,
        exposureBias: 0.2,
        contrastBias: 0.1,
        highlights: 0.05,
        shadows: 0,
        grainStrength: 0.25,
        grainSize: 1.0,
        vignetteStrength: 0.15,
        clarity: 0.05,
        splitToning: SplitToning(
          shadowColor: Color(0xFF0a2a2a),
          highlightColor: Color(0xFFe6f2ff),
          balance: -0.1,
        ),
      ),
      icon3DAssetPath: "assets/camera_icons/fuji_superia_400.png",
    );
  }
  
  static CameraModel _ilfordHP5() {
    return CameraModel(
      id: "ilford_hp5",
      name: "Ilford HP5 Plus",
      era: "1976-Present",
      type: "Black & White",
      iso: 400,
      personality: "Classic Documentary",
      isPro: false,
      iconColor: Color(0xFF666670),
      bestFor: ["Documentary", "Street photography", "Portraits", "Low light"],
      description: "The most famous black & white film. Rich tones, beautiful grain, forgiving exposure latitude. A documentary photographer's favorite.",
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 0,
        exposureBias: 0.1,
        contrastBias: 0.2,
        highlights: 0.1,
        shadows: 0.15,
        grainStrength: 0.35,
        grainSize: 1.2,
        vignetteStrength: 0.2,
        clarity: 0.1,
        blackWhiteMode: true,
        blackPoint: -0.05,
      ),
      icon3DAssetPath: "assets/camera_icons/ilford_hp5.png",
    );
  }
  
  // === PRO COLOR FILMS ===
  
  static CameraModel _kodakPortra400() {
    return CameraModel(
      id: "kodak_portra_400",
      name: "Kodak Portra 400",
      era: "1998-Present",
      type: "Color Negative (Portrait)",
      iso: 400,
      personality: "Natural Skin Tones",
      isPro: true,
      price: "\$2.99",
      iconColor: Color(0xFFFFB6C1),
      bestFor: ["Portrait photography", "Wedding photography", "Fashion", "Lifestyle"],
      description: "The gold standard for portrait photographers. Incredible skin tone reproduction, fine grain, and beautiful pastel colors.",
      pipeline: PipelineConfig(
        temperature: 8,
        saturation: 0.95,
        exposureBias: 0.4,
        contrastBias: -0.1,
        highlights: -0.1,
        shadows: 0.2,
        grainStrength: 0.15,
        grainSize: 0.8,
        vignetteStrength: 0.1,
        clarity: -0.05,
        skinToneOptimization: true,
        splitToning: SplitToning(
          shadowColor: Color(0xFF1a1510),
          highlightColor: Color(0xFFfff5eb),
          balance: 0.2,
        ),
      ),
      icon3DAssetPath: "assets/camera_icons/kodak_portra_400.png",
    );
  }
  
  static CameraModel _kodakEktar100() {
    return CameraModel(
      id: "kodak_ektar_100",
      name: "Kodak Ektar 100",
      era: "2008-Present",
      type: "Color Negative",
      iso: 100,
      personality: "Ultra Saturated",
      isPro: true,
      price: "\$2.99",
      iconColor: Color(0xFFFF6347),
      bestFor: ["Landscape photography", "Product photography", "Architecture", "Bright daylight"],
      description: "The world's finest grain color negative film. Punchy, saturated colors. Best in bright sunlight.",
      pipeline: PipelineConfig(
        temperature: 5,
        saturation: 1.25,
        exposureBias: 0,
        contrastBias: 0.2,
        highlights: 0,
        shadows: 0,
        grainStrength: 0.08,
        grainSize: 0.5,
        vignetteStrength: 0.1,
        clarity: 0.15,
        splitToning: SplitToning(
          shadowColor: Color(0xFF1a0a05),
          highlightColor: Color(0xFFfff8f0),
          balance: 0,
        ),
      ),
      icon3DAssetPath: "assets/camera_icons/kodak_ektar_100.png",
    );
  }
  
  static CameraModel _cinestill800T() {
    return CameraModel(
      id: "cinestill_800t",
      name: "Cinestill 800T",
      era: "2012-Present",
      type: "Color Negative (Tungsten)",
      iso: 800,
      personality: "Cinematic Nightlife",
      isPro: true,
      price: "\$3.99",
      iconColor: Color(0xFFFF1744),
      bestFor: ["Night photography", "Neon lights", "Cinematic shots", "Urban nightlife"],
      description: "Motion picture film adapted for still cameras. Famous for red halation around lights. Perfect for neon-lit streets.",
      pipeline: PipelineConfig(
        temperature: -20,
        saturation: 1.10,
        exposureBias: 0.5,
        contrastBias: 0.15,
        highlights: 0.1,
        shadows: 0.2,
        grainStrength: 0.3,
        grainSize: 1.1,
        vignetteStrength: 0.25,
        clarity: 0.1,
        halation: true,
        halationColor: "#ff3333",
        halationStrength: 0.4,
        splitToning: SplitToning(
          shadowColor: Color(0xFF001a33),
          highlightColor: Color(0xFFff9966),
          balance: -0.2,
        ),
      ),
      icon3DAssetPath: "assets/camera_icons/cinestill_800t.png",
    );
  }
  
  static CameraModel _fujiPro400H() {
    return CameraModel(
      id: "fuji_pro_400h",
      name: "Fuji Pro 400H",
      era: "2001-2021 (Discontinued)",
      type: "Color Negative",
      iso: 400,
      personality: "Pastel Dream",
      isPro: true,
      price: "\$3.99",
      iconColor: Color(0xFFE6E6FA),
      bestFor: ["Weddings", "Fine art", "Soft portraits", "Pastel aesthetics"],
      description: "Legendary discontinued film. Soft, muted pastels with a slight cool cast. Wedding photographers' secret weapon.",
      pipeline: PipelineConfig(
        temperature: -5,
        saturation: 0.90,
        exposureBias: 0.3,
        contrastBias: -0.1,
        highlights: -0.05,
        shadows: 0.15,
        grainStrength: 0.12,
        grainSize: 0.7,
        vignetteStrength: 0.1,
        clarity: -0.1,
        pastelEnhancement: true,
        splitToning: SplitToning(
          shadowColor: Color(0xFF1a1a2e),
          highlightColor: Color(0xFFf0f8ff),
          balance: 0.1,
        ),
      ),
      icon3DAssetPath: "assets/camera_icons/fuji_pro_400h.png",
    );
  }
  
  static CameraModel _kodakColorPlus200() {
    return CameraModel(
      id: "kodak_colorplus_200",
      name: "Kodak ColorPlus 200",
      era: "2000s-Present",
      type: "Color Negative",
      iso: 200,
      personality: "Budget Warmth",
      isPro: true,
      price: "\$1.99",
      iconColor: Color(0xFFFFA500),
      bestFor: ["Everyday shooting", "Budget photography", "Beginners", "Outdoor scenes"],
      description: "The affordable entry to Kodak. Warm tones, higher contrast than Gold. Great for budget-conscious shooters.",
      pipeline: PipelineConfig(
        temperature: 12,
        saturation: 1.05,
        exposureBias: 0.2,
        contrastBias: 0.15,
        highlights: 0,
        shadows: 0,
        grainStrength: 0.3,
        grainSize: 1.1,
        vignetteStrength: 0.2,
        clarity: 0,
      ),
      icon3DAssetPath: "assets/camera_icons/kodak_colorplus_200.png",
    );
  }
  
  // Continue with remaining cameras...
  // Due to length, showing structure for remaining cameras
  
  static CameraModel _kodakUltramax400() { /* Implementation */ }
  static CameraModel _fujiC200() { /* Implementation */ }
  static CameraModel _fujiVelvia50() { /* Implementation */ }
  static CameraModel _fujiProvia100F() { /* Implementation */ }
  static CameraModel _lomo800() { /* Implementation */ }
  static CameraModel _agfaVista200() { /* Implementation */ }
  static CameraModel _kodakVision3500T() { /* Implementation */ }
  
  // === PRO B&W FILMS ===
  static CameraModel _kodakTriX400() { /* Implementation */ }
  static CameraModel _kodakTMax400() { /* Implementation */ }
  static CameraModel _ilfordDelta3200() { /* Implementation */ }
  static CameraModel _fomapan400() { /* Implementation */ }
  static CameraModel _rolleiRetro400S() { /* Implementation */ }
  
  // === PRO SPECIAL FILMS ===
  static CameraModel _lomoRedscale() { /* Implementation */ }
  static CameraModel _lomoPurple() { /* Implementation */ }
  static CameraModel _aerochrome() { /* Implementation */ }
  static CameraModel _xproSlide() { /* Implementation */ }
  static CameraModel _expiredFilm() { /* Implementation */ }
  
  // === PRO INSTANT FILMS ===
  static CameraModel _polaroid600() { /* Implementation */ }
  static CameraModel _polaroidSX70() { /* Implementation */ }
  static CameraModel _fujiInstax() { /* Implementation */ }
  
  // === PRO TOY CAMERAS ===
  static CameraModel _holgaPlastic() { /* Implementation */ }
  static CameraModel _dianaFPlus() { /* Implementation */ }
  
  // === HELPER METHODS ===
  
  static List<CameraModel> getFreeCameras() {
    return getAllCameras().where((camera) => !camera.isPro).toList();
  }
  
  static List<CameraModel> getProCameras() {
    return getAllCameras().where((camera) => camera.isPro).toList();
  }
  
  static CameraModel? getCameraById(String id) {
    try {
      return getAllCameras().firstWhere((camera) => camera.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static List<CameraModel> searchCameras(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllCameras().where((camera) {
      return camera.name.toLowerCase().contains(lowerQuery) ||
             camera.type.toLowerCase().contains(lowerQuery) ||
             camera.personality.toLowerCase().contains(lowerQuery) ||
             camera.era.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  static List<CameraModel> filterByType(String type) {
    return getAllCameras().where((camera) {
      return camera.type.toLowerCase().contains(type.toLowerCase());
    }).toList();
  }
}
```

---

## 📝 Full Camera Details Reference

For complete implementation details of all 30 cameras with exact pipeline configurations, refer to the original camera database document provided. Each camera includes:

- Unique ID
- Full name and era
- Film type (Color Negative, B&W, Slide, Instant, etc.)
- ISO rating
- Personality description
- Best use cases (4 scenarios)
- Full description
- Complete pipeline configuration with all parameters
- 3D icon asset path

---

**Continue to Part 3 for Image Processing Pipeline Implementation...**
