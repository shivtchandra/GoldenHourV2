import 'package:flutter/material.dart';

/// Configuration for the image processing pipeline applied by each camera preset
class PipelineConfig {
  // Color Adjustments
  final double temperature; // -50 to 50 (cool to warm)
  final double tint; // -50 to 50 (green to magenta)
  final double saturation; // 0 to 2 (0 = grayscale, 1 = normal, 2 = double)

  // Exposure
  final double exposureBias; // -2 to 2 EV
  final double contrastBias; // -1 to 1
  final double highlights; // -1 to 1
  final double shadows; // -1 to 1

  // Film Character
  final double grainStrength; // 0 to 1
  final double grainSize; // 0.5 to 2
  final double vignetteStrength; // 0 to 1
  final double clarity; // -1 to 1

  // Split Toning
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
  final bool showDateStamp;
  final String? dateStampText;
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

  const PipelineConfig({
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
    this.showDateStamp = false,
    this.dateStampText,
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

  /// Create a default neutral config
  factory PipelineConfig.defaultConfig() {
    return const PipelineConfig(
      temperature: 0,
      tint: 0,
      saturation: 1.0,
      exposureBias: 0,
      contrastBias: 0,
      highlights: 0,
      shadows: 0,
      grainStrength: 0,
      grainSize: 1.0,
      vignetteStrength: 0,
      clarity: 0,
    );
  }

  /// Create a neutral config for preset mode (no filter applied)
  factory PipelineConfig.neutral() {
    return PipelineConfig.defaultConfig();
  }

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
      'showDateStamp': showDateStamp,
      'dateStampText': dateStampText,
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

  factory PipelineConfig.fromJson(Map<String, dynamic> json) {
    return PipelineConfig(
      temperature: (json['temperature'] as num).toDouble(),
      tint: (json['tint'] as num?)?.toDouble() ?? 0,
      saturation: (json['saturation'] as num).toDouble(),
      exposureBias: (json['exposureBias'] as num).toDouble(),
      contrastBias: (json['contrastBias'] as num).toDouble(),
      highlights: (json['highlights'] as num).toDouble(),
      shadows: (json['shadows'] as num).toDouble(),
      grainStrength: (json['grainStrength'] as num).toDouble(),
      grainSize: (json['grainSize'] as num).toDouble(),
      vignetteStrength: (json['vignetteStrength'] as num).toDouble(),
      clarity: (json['clarity'] as num).toDouble(),
      splitToning: json['splitToning'] != null
          ? SplitToning.fromJson(json['splitToning'] as Map<String, dynamic>)
          : null,
      blackWhiteMode: json['blackWhiteMode'] as bool? ?? false,
      slideFilm: json['slideFilm'] as bool? ?? false,
      instantFilm: json['instantFilm'] as bool? ?? false,
      halation: json['halation'] as bool? ?? false,
      infraredMode: json['infraredMode'] as bool? ?? false,
      crossProcessed: json['crossProcessed'] as bool? ?? false,
      expiredMode: json['expiredMode'] as bool? ?? false,
      lightLeaks: json['lightLeaks'] as bool? ?? false,
      showDateStamp: json['showDateStamp'] as bool? ?? false,
      dateStampText: json['dateStampText'] as String?,
      softFocus: (json['softFocus'] as num?)?.toDouble() ?? 0,
      halationColor: json['halationColor'] as String?,
      halationStrength: (json['halationStrength'] as num?)?.toDouble(),
      lightLeakIntensity: (json['lightLeakIntensity'] as num?)?.toDouble(),
      dreamyGlow: (json['dreamyGlow'] as num?)?.toDouble(),
      colorShiftMode: json['colorShiftMode'] as String?,
      hueShift: (json['hueShift'] as num?)?.toDouble(),
      redSensitivity: (json['redSensitivity'] as num?)?.toDouble(),
      pastelEnhancement: json['pastelEnhancement'] as bool?,
      skinToneOptimization: json['skinToneOptimization'] as bool?,
      instantBorder: json['instantBorder'] as bool?,
      colorShift: json['colorShift'] as int?,
      fogLevel: (json['fogLevel'] as num?)?.toDouble(),
      randomColorShift: json['randomColorShift'] as bool?,
      redscaleMode: json['redscaleMode'] as bool?,
      greenToMagenta: json['greenToMagenta'] as bool?,
      motionPicture: json['motionPicture'] as bool?,
      blackPoint: (json['blackPoint'] as num?)?.toDouble(),
    );
  }

  /// Generates a 4x5 color matrix for use with ColorFiltered
  /// This EXACTLY matches ImageProcessingService output
  List<double> toColorMatrix() {
    // Luminance coefficients (standard)
    const double lumR = 0.2126;
    const double lumG = 0.7152;
    const double lumB = 0.0722;

    // ============================================
    // MATCH ImageProcessingService EXACTLY
    // ============================================

    // Exposure multiplier (matches _adjustExposureAndContrast)
    double exposureMult = exposureBias >= 0
        ? 1.0 + exposureBias * 0.5
        : 1.0 + exposureBias * 0.3;

    // Contrast factor (matches _adjustExposureAndContrast)
    double contrastFactor = (259 * (contrastBias * 255 + 255)) /
        (255 * (259 - contrastBias * 255));

    // Saturation
    double sat = saturation;

    // Color offsets for temperature/tint (additive, matches pixel processing)
    double rOffset = 0.0;
    double gOffset = 0.0;
    double bOffset = 0.0;

    // Temperature adjustment (EXACT match to ImageProcessingService)
    if (temperature > 0) {
      // Warm: increase red, decrease blue
      rOffset += temperature * 2.5;
      bOffset -= temperature * 1.5;
    } else if (temperature < 0) {
      // Cool: increase blue, decrease red
      bOffset += temperature.abs() * 2.5;
      rOffset -= temperature.abs() * 1.5;
    }

    // Tint adjustment (EXACT match to ImageProcessingService)
    if (tint > 0) {
      // Magenta: increase red and blue, decrease green
      rOffset += tint * 1.2;
      bOffset += tint * 1.2;
      gOffset -= tint * 0.8;
    } else if (tint < 0) {
      // Green: increase green, decrease red and blue
      gOffset += tint.abs() * 2.0;
      rOffset -= tint.abs() * 0.5;
      bOffset -= tint.abs() * 0.5;
    }

    // Shadows offset (lifted blacks)
    rOffset += shadows * 30;
    gOffset += shadows * 30;
    bOffset += shadows * 30;

    // ============================================
    // SPECIAL MODES
    // ============================================

    if (expiredMode) {
      double fog = (fogLevel ?? 0.1) * 255 * 0.5;
      rOffset += fog;
      gOffset += fog;
      bOffset += fog;
      exposureMult *= 0.85;
    }

    if (crossProcessed) {
      rOffset += 10;
      gOffset -= 5;
      bOffset += 15;
    }

    if (infraredMode) {
      rOffset += 30;
      gOffset -= 20;
      bOffset -= 30;
    }

    if (redscaleMode == true) {
      rOffset += 50;
      gOffset -= 20;
      bOffset -= 40;
    }

    if (slideFilm) {
      sat *= 1.3;
      contrastFactor *= 1.1;
    }

    if (motionPicture == true) {
      sat *= 0.85;
      rOffset += 8;
      gOffset += 4;
    }

    if (splitToning != null) {
      rOffset += (splitToning!.shadowColor.red - 128) * 0.15;
      gOffset += (splitToning!.shadowColor.green - 128) * 0.15;
      bOffset += (splitToning!.shadowColor.blue - 128) * 0.15;
    }

    // ============================================
    // BUILD MATRIX
    // ============================================

    // Saturation matrix components
    double sr = (1 - sat) * lumR;
    double sg = (1 - sat) * lumG;
    double sb = (1 - sat) * lumB;

    // Combined scale factors
    double scale = exposureMult * contrastFactor;

    // Contrast offset (centers the contrast adjustment)
    double contrastOffset = 128 * (1 - contrastFactor);

    // Final offsets
    double finalROffset = rOffset + contrastOffset;
    double finalGOffset = gOffset + contrastOffset;
    double finalBOffset = bOffset + contrastOffset;

    // Black & White mode
    if (blackWhiteMode) {
      return [
        lumR * scale, lumG * scale, lumB * scale, 0, finalROffset,
        lumR * scale, lumG * scale, lumB * scale, 0, finalGOffset,
        lumR * scale, lumG * scale, lumB * scale, 0, finalBOffset,
        0, 0, 0, 1, 0,
      ];
    }

    // Color matrix with saturation
    return [
      scale * (sr + sat), scale * sg, scale * sb, 0, finalROffset,
      scale * sr, scale * (sg + sat), scale * sb, 0, finalGOffset,
      scale * sr, scale * sg, scale * (sb + sat), 0, finalBOffset,
      0, 0, 0, 1, 0,
    ];
  }

  PipelineConfig copyWith({
    double? temperature,
    double? tint,
    double? saturation,
    double? exposureBias,
    double? contrastBias,
    double? highlights,
    double? shadows,
    double? grainStrength,
    double? grainSize,
    double? vignetteStrength,
    double? clarity,
    SplitToning? splitToning,
    bool? blackWhiteMode,
    bool? slideFilm,
    bool? instantFilm,
    bool? halation,
    bool? infraredMode,
    bool? crossProcessed,
    bool? expiredMode,
    bool? lightLeaks,
    bool? showDateStamp,
    String? dateStampText,
    double? softFocus,
    String? halationColor,
    double? halationStrength,
    double? lightLeakIntensity,
    double? dreamyGlow,
    String? colorShiftMode,
    double? hueShift,
    double? redSensitivity,
    bool? pastelEnhancement,
    bool? skinToneOptimization,
    bool? instantBorder,
    int? colorShift,
    double? fogLevel,
    bool? randomColorShift,
    bool? redscaleMode,
    bool? greenToMagenta,
    bool? motionPicture,
    double? blackPoint,
  }) {
    return PipelineConfig(
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      saturation: saturation ?? this.saturation,
      exposureBias: exposureBias ?? this.exposureBias,
      contrastBias: contrastBias ?? this.contrastBias,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      grainStrength: grainStrength ?? this.grainStrength,
      grainSize: grainSize ?? this.grainSize,
      vignetteStrength: vignetteStrength ?? this.vignetteStrength,
      clarity: clarity ?? this.clarity,
      splitToning: splitToning ?? this.splitToning,
      blackWhiteMode: blackWhiteMode ?? this.blackWhiteMode,
      slideFilm: slideFilm ?? this.slideFilm,
      instantFilm: instantFilm ?? this.instantFilm,
      halation: halation ?? this.halation,
      infraredMode: infraredMode ?? this.infraredMode,
      crossProcessed: crossProcessed ?? this.crossProcessed,
      expiredMode: expiredMode ?? this.expiredMode,
      lightLeaks: lightLeaks ?? this.lightLeaks,
      showDateStamp: showDateStamp ?? this.showDateStamp,
      dateStampText: dateStampText ?? this.dateStampText,
      softFocus: softFocus ?? this.softFocus,
      halationColor: halationColor ?? this.halationColor,
      halationStrength: halationStrength ?? this.halationStrength,
      lightLeakIntensity: lightLeakIntensity ?? this.lightLeakIntensity,
      dreamyGlow: dreamyGlow ?? this.dreamyGlow,
      colorShiftMode: colorShiftMode ?? this.colorShiftMode,
      hueShift: hueShift ?? this.hueShift,
      redSensitivity: redSensitivity ?? this.redSensitivity,
      pastelEnhancement: pastelEnhancement ?? this.pastelEnhancement,
      skinToneOptimization: skinToneOptimization ?? this.skinToneOptimization,
      instantBorder: instantBorder ?? this.instantBorder,
      colorShift: colorShift ?? this.colorShift,
      fogLevel: fogLevel ?? this.fogLevel,
      randomColorShift: randomColorShift ?? this.randomColorShift,
      redscaleMode: redscaleMode ?? this.redscaleMode,
      greenToMagenta: greenToMagenta ?? this.greenToMagenta,
      motionPicture: motionPicture ?? this.motionPicture,
      blackPoint: blackPoint ?? this.blackPoint,
    );
  }
}

/// Split toning configuration for shadow/highlight color grading
class SplitToning {
  final Color shadowColor;
  final Color highlightColor;
  final double balance; // -1 to 1 (negative = more shadow, positive = more highlight)

  const SplitToning({
    required this.shadowColor,
    required this.highlightColor,
    required this.balance,
  });

  Map<String, dynamic> toJson() => {
        'shadowColor': shadowColor.value,
        'highlightColor': highlightColor.value,
        'balance': balance,
      };

  factory SplitToning.fromJson(Map<String, dynamic> json) {
    return SplitToning(
      shadowColor: Color(json['shadowColor'] as int),
      highlightColor: Color(json['highlightColor'] as int),
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
