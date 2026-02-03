import 'package:flutter/material.dart';
import '../models/camera_model.dart';
import '../models/pipeline_config.dart';

/// Repository containing all 30 film camera presets
class CameraRepository {
  CameraRepository._();

  /// Get all cameras
  // Favorites Management
  static final Set<String> _favorites = {}; // Start with no favorites

  static bool isFavorite(String id) => _favorites.contains(id);

  static void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
  }

  static List<CameraModel> getFavoriteCameras() {
    final all = getAllCameras();
    return all.where((c) => _favorites.contains(c.id)).toList();
  }

  /// Get all cameras
  static List<CameraModel> getAllCameras() {
    return [
      // FREE TIER (3 cameras)
      _kodakGold200(),
      _fujiSuperia400(),
      _ilfordHP5(),

      // PRO COLOR FILMS (12 cameras)
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

      // PRO B&W FILMS (5 cameras)
      _kodakTriX400(),
      _kodakTMax400(),
      _ilfordDelta3200(),
      _fomapan400(),
      _rolleiRetro400S(),

      // PRO SPECIAL FILMS (5 cameras)
      _lomoRedscale(),
      _lomoPurple(),
      _aerochrome(),
      _xproSlide(),
      _expiredFilm(),

      // PRO INSTANT FILMS (3 cameras)
      _polaroid600(),
      _polaroidSX70(),
      _fujiInstax(),

      // PRO TOY CAMERAS (2 cameras)
      _holgaPlastic(),
      _dianaFPlus(),
    ];
  }

  // ========================================
  // 🆓 FREE TIER (3 cameras)
  // ========================================

  static CameraModel _kodakGold200() {
    return const CameraModel(
      id: 'kodak_gold_200',
      name: 'Kodak Gold 200',
      era: '1990s-Present',
      type: 'Color Negative',
      iso: 200,
      personality: 'Warm & Nostalgic',
      isPro: false,
      iconColor: Color(0xFFF4C542),
      bestFor: ['Everyday moments', 'Sunny days', 'Travel photography', 'Summer vibes'],
      description: 'The most popular consumer film stock of the 90s. Warm, sunny, and forgiving. Perfect for capturing nostalgic summer memories.',
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
      icon3DAssetPath: 'assets/camera_icons/kodak_gold_200.png',
    );
  }

  static CameraModel _fujiSuperia400() {
    return const CameraModel(
      id: 'fuji_superia_400',
      name: 'Fuji Superia 400',
      era: '2000s-Present',
      type: 'Color Negative',
      iso: 400,
      personality: 'Cool & Vibrant',
      isPro: false,
      iconColor: Color(0xFF5B9BD5),
      bestFor: ['Street photography', 'Overcast days', 'Urban landscapes', 'Night scenes'],
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
      icon3DAssetPath: 'assets/camera_icons/fuji_superia_400.png',
    );
  }

  static CameraModel _ilfordHP5() {
    return const CameraModel(
      id: 'ilford_hp5',
      name: 'Ilford HP5 Plus',
      era: '1976-Present',
      type: 'Black & White',
      iso: 400,
      personality: 'Classic Documentary',
      isPro: false,
      iconColor: Color(0xFF666670),
      bestFor: ['Documentary', 'Street photography', 'Portraits', 'Low light'],
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
      icon3DAssetPath: 'assets/camera_icons/ilford_hp5.png',
    );
  }

  // ========================================
  // 👑 PRO TIER - COLOR FILMS (12 cameras)
  // ========================================

  static CameraModel _kodakPortra400() {
    return const CameraModel(
      id: 'kodak_portra_400',
      name: 'Kodak Portra 400',
      era: '1998-Present',
      type: 'Color Negative (Portrait)',
      iso: 400,
      personality: 'Natural Skin Tones',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFFFFB6C1),
      bestFor: ['Portrait photography', 'Wedding photography', 'Fashion', 'Lifestyle'],
      description: 'The gold standard for portrait photographers. Incredible skin tone reproduction, fine grain, and beautiful pastel colors.',
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
      icon3DAssetPath: 'assets/camera_icons/kodak_portra_400.png',
    );
  }

  static CameraModel _kodakEktar100() {
    return const CameraModel(
      id: 'kodak_ektar_100',
      name: 'Kodak Ektar 100',
      era: '2008-Present',
      type: 'Color Negative',
      iso: 100,
      personality: 'Ultra Saturated',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFFFF6347),
      bestFor: ['Landscape photography', 'Product photography', 'Architecture', 'Bright daylight'],
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
      icon3DAssetPath: 'assets/camera_icons/kodak_ektar_100.png',
    );
  }

  static CameraModel _cinestill800T() {
    return const CameraModel(
      id: 'cinestill_800t',
      name: 'Cinestill 800T',
      era: '2012-Present',
      type: 'Color Negative (Tungsten)',
      iso: 800,
      personality: 'Cinematic Nightlife',
      isPro: true,
      price: r'$3.99',
      iconColor: Color(0xFFFF1744),
      bestFor: ['Night photography', 'Neon lights', 'Cinematic shots', 'Urban nightlife'],
      description: 'Motion picture film adapted for still cameras. Famous for red halation around lights. Perfect for neon-lit streets.',
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
        halationColor: '#ff3333',
        halationStrength: 0.4,
        splitToning: SplitToning(
          shadowColor: Color(0xFF001a33),
          highlightColor: Color(0xFFff9966),
          balance: -0.2,
        ),
      ),
      icon3DAssetPath: 'assets/camera_icons/cinestill_800t.png',
    );
  }

  static CameraModel _fujiPro400H() {
    return const CameraModel(
      id: 'fuji_pro_400h',
      name: 'Fuji Pro 400H',
      era: '2001-2021 (Discontinued)',
      type: 'Color Negative',
      iso: 400,
      personality: 'Pastel Dream',
      isPro: true,
      price: r'$3.99',
      iconColor: Color(0xFFE6E6FA),
      bestFor: ['Weddings', 'Fine art', 'Soft portraits', 'Pastel aesthetics'],
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
      icon3DAssetPath: 'assets/camera_icons/fuji_pro_400h.png',
    );
  }

  static CameraModel _kodakColorPlus200() {
    return const CameraModel(
      id: 'kodak_colorplus_200',
      name: 'Kodak ColorPlus 200',
      era: '2000s-Present',
      type: 'Color Negative',
      iso: 200,
      personality: 'Budget Warmth',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFFFFA500),
      bestFor: ['Everyday shooting', 'Budget photography', 'Beginners', 'Outdoor scenes'],
      description: 'The affordable entry to Kodak. Warm tones, higher contrast than Gold. Great for budget-conscious shooters.',
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
      icon3DAssetPath: 'assets/camera_icons/kodak_colorplus_200.png',
    );
  }

  static CameraModel _kodakUltramax400() {
    return const CameraModel(
      id: 'kodak_ultramax_400',
      name: 'Kodak Ultramax 400',
      era: '2000s-Present',
      type: 'Color Negative',
      iso: 400,
      personality: 'Versatile Classic',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFFFFD700),
      bestFor: ['All-around', 'Flash photography', 'Indoor events', 'Travel'],
      description: 'Kodak\'s versatile consumer film. Punchy colors, good in mixed lighting. A reliable everyday choice.',
      pipeline: PipelineConfig(
        temperature: 10,
        saturation: 1.12,
        exposureBias: 0.25,
        contrastBias: 0.1,
        highlights: 0,
        shadows: 0.05,
        grainStrength: 0.28,
        grainSize: 1.0,
        vignetteStrength: 0.15,
        clarity: 0.05,
      ),
      icon3DAssetPath: 'assets/camera_icons/kodak_ultramax_400.png',
    );
  }

  static CameraModel _fujiC200() {
    return const CameraModel(
      id: 'fuji_c200',
      name: 'Fuji C200',
      era: '2000s-Present',
      type: 'Color Negative',
      iso: 200,
      personality: 'Everyday Cool',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFF87CEEB),
      bestFor: ['Casual shooting', 'Daylight', 'Beginners', 'Budget-friendly'],
      description: 'Fuji\'s budget-friendly option. Cool tones, natural colors. Great for everyday snapshots.',
      pipeline: PipelineConfig(
        temperature: -8,
        saturation: 1.05,
        exposureBias: 0.15,
        contrastBias: 0.1,
        highlights: 0,
        shadows: 0,
        grainStrength: 0.25,
        grainSize: 1.0,
        vignetteStrength: 0.15,
        clarity: 0,
      ),
      icon3DAssetPath: 'assets/camera_icons/fuji_c200.png',
    );
  }

  static CameraModel _fujiVelvia50() {
    return const CameraModel(
      id: 'fuji_velvia_50',
      name: 'Fuji Velvia 50',
      era: '1990s-Present',
      type: 'Color Slide',
      iso: 50,
      personality: 'Hyper Saturated',
      isPro: true,
      price: r'$4.99',
      iconColor: Color(0xFF228B22),
      bestFor: ['Landscape', 'Nature', 'Sunrise/sunset', 'Autumn colors'],
      description: 'The king of landscape film. Extremely saturated colors, especially greens and reds. Iconic for nature photography.',
      pipeline: PipelineConfig(
        temperature: 3,
        saturation: 1.4,
        exposureBias: -0.2,
        contrastBias: 0.25,
        highlights: -0.1,
        shadows: -0.1,
        grainStrength: 0.05,
        grainSize: 0.4,
        vignetteStrength: 0.1,
        clarity: 0.2,
        slideFilm: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/fuji_velvia_50.png',
    );
  }

  static CameraModel _fujiProvia100F() {
    return const CameraModel(
      id: 'fuji_provia_100f',
      name: 'Fuji Provia 100F',
      era: '1990s-Present',
      type: 'Color Slide',
      iso: 100,
      personality: 'Balanced Precision',
      isPro: true,
      price: r'$4.99',
      iconColor: Color(0xFF4169E1),
      bestFor: ['Product shots', 'Studio', 'Accurate colors', 'Professional work'],
      description: 'The professional slide film standard. Neutral, accurate colors with fine grain. Ideal for commercial work.',
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 1.15,
        exposureBias: 0,
        contrastBias: 0.15,
        highlights: 0,
        shadows: 0,
        grainStrength: 0.08,
        grainSize: 0.5,
        vignetteStrength: 0.1,
        clarity: 0.1,
        slideFilm: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/fuji_provia_100f.png',
    );
  }

  static CameraModel _lomo800() {
    return const CameraModel(
      id: 'lomo_800',
      name: 'Lomography 800',
      era: '2010s-Present',
      type: 'Color Negative',
      iso: 800,
      personality: 'Wild & Experimental',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFFFF69B4),
      bestFor: ['Concerts', 'Low light parties', 'Experimental', 'Night scenes'],
      description: 'High-speed, high-saturation film for the adventurous. Unpredictable, vibrant colors in low light.',
      pipeline: PipelineConfig(
        temperature: 5,
        saturation: 1.2,
        exposureBias: 0.4,
        contrastBias: 0.1,
        highlights: 0.1,
        shadows: 0.15,
        grainStrength: 0.4,
        grainSize: 1.3,
        vignetteStrength: 0.2,
        clarity: 0,
        randomColorShift: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/lomo_800.png',
    );
  }

  static CameraModel _agfaVista200() {
    return const CameraModel(
      id: 'agfa_vista_200',
      name: 'Agfa Vista 200',
      era: '1990s-2010s (Discontinued)',
      type: 'Color Negative',
      iso: 200,
      personality: 'European Classic',
      isPro: true,
      price: r'$2.49',
      iconColor: Color(0xFFDC143C),
      bestFor: ['Street photos', 'Travel', 'Casual shooting', 'Sunny days'],
      description: 'German engineering meets warm tones. Rich reds and yellows with a classic European look.',
      pipeline: PipelineConfig(
        temperature: 8,
        saturation: 1.08,
        exposureBias: 0.2,
        contrastBias: 0.1,
        highlights: 0,
        shadows: 0.05,
        grainStrength: 0.22,
        grainSize: 0.9,
        vignetteStrength: 0.15,
        clarity: 0.05,
      ),
      icon3DAssetPath: 'assets/camera_icons/agfa_vista_200.png',
    );
  }

  static CameraModel _kodakVision3500T() {
    return const CameraModel(
      id: 'kodak_vision3_500t',
      name: 'Kodak Vision3 500T',
      era: '2007-Present',
      type: 'Motion Picture',
      iso: 500,
      personality: 'Hollywood Cinema',
      isPro: true,
      price: r'$3.99',
      iconColor: Color(0xFF4682B4),
      bestFor: ['Cinematic look', 'Tungsten light', 'Film production', 'Night scenes'],
      description: 'Actual Hollywood motion picture film. Cool tungsten balance, incredible shadow detail, cinematic quality.',
      pipeline: PipelineConfig(
        temperature: -15,
        saturation: 1.05,
        exposureBias: 0.3,
        contrastBias: 0.1,
        highlights: 0,
        shadows: 0.25,
        grainStrength: 0.2,
        grainSize: 0.9,
        vignetteStrength: 0.15,
        clarity: 0.05,
        motionPicture: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/kodak_vision3_500t.png',
    );
  }

  // ========================================
  // 👑 PRO TIER - B&W FILMS (5 cameras)
  // ========================================

  static CameraModel _kodakTriX400() {
    return const CameraModel(
      id: 'kodak_trix_400',
      name: 'Kodak Tri-X 400',
      era: '1954-Present',
      type: 'Black & White',
      iso: 400,
      personality: 'Gritty Photojournalism',
      isPro: true,
      price: r'$2.49',
      iconColor: Color(0xFF505050),
      bestFor: ['Photojournalism', 'Street photography', 'Action sports', 'Documentary'],
      description: 'The legendary press film. High contrast, punchy blacks, gritty grain. Used by the greatest photojournalists.',
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 0,
        exposureBias: 0.15,
        contrastBias: 0.3,
        highlights: 0.15,
        shadows: 0.1,
        grainStrength: 0.4,
        grainSize: 1.2,
        vignetteStrength: 0.2,
        clarity: 0.15,
        blackWhiteMode: true,
        blackPoint: -0.08,
      ),
      icon3DAssetPath: 'assets/camera_icons/kodak_trix_400.png',
    );
  }

  static CameraModel _kodakTMax400() {
    return const CameraModel(
      id: 'kodak_tmax_400',
      name: 'Kodak T-Max 400',
      era: '1986-Present',
      type: 'Black & White',
      iso: 400,
      personality: 'Modern Precision',
      isPro: true,
      price: r'$2.49',
      iconColor: Color(0xFF696969),
      bestFor: ['Studio portraits', 'Architecture', 'Fine art', 'Technical work'],
      description: 'Kodak\'s technical B&W film. Super fine grain, smooth tones, excellent for enlargements.',
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 0,
        exposureBias: 0.1,
        contrastBias: 0.15,
        highlights: 0.05,
        shadows: 0.1,
        grainStrength: 0.2,
        grainSize: 0.8,
        vignetteStrength: 0.15,
        clarity: 0.1,
        blackWhiteMode: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/kodak_tmax_400.png',
    );
  }

  static CameraModel _ilfordDelta3200() {
    return const CameraModel(
      id: 'ilford_delta_3200',
      name: 'Ilford Delta 3200',
      era: '1998-Present',
      type: 'Black & White',
      iso: 3200,
      personality: 'Extreme Low Light',
      isPro: true,
      price: r'$3.99',
      iconColor: Color(0xFF404040),
      bestFor: ['Concert photography', 'Extreme low light', 'Artistic grain', 'Night scenes'],
      description: 'The ultimate low-light B&W film. Beautiful, prominent grain structure. Perfect for available-light shooting.',
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 0,
        exposureBias: 0.6,
        contrastBias: 0.2,
        highlights: 0.1,
        shadows: 0.3,
        grainStrength: 0.55,
        grainSize: 1.5,
        vignetteStrength: 0.25,
        clarity: 0.05,
        blackWhiteMode: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/ilford_delta_3200.png',
    );
  }

  static CameraModel _fomapan400() {
    return const CameraModel(
      id: 'fomapan_400',
      name: 'Fomapan 400',
      era: '1960s-Present',
      type: 'Black & White',
      iso: 400,
      personality: 'Eastern European Classic',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFF787878),
      bestFor: ['Budget B&W', 'Vintage look', 'Experimental', 'Student projects'],
      description: 'Czech film with character. Lower contrast, vintage aesthetic. Great for those seeking an old-school look.',
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 0,
        exposureBias: 0.2,
        contrastBias: 0.1,
        highlights: 0.05,
        shadows: 0.2,
        grainStrength: 0.45,
        grainSize: 1.3,
        vignetteStrength: 0.2,
        clarity: 0,
        blackWhiteMode: true,
        blackPoint: 0.05,
      ),
      icon3DAssetPath: 'assets/camera_icons/fomapan_400.png',
    );
  }

  static CameraModel _rolleiRetro400S() {
    return const CameraModel(
      id: 'rollei_retro_400s',
      name: 'Rollei Retro 400S',
      era: '2000s-Present',
      type: 'Black & White (Infrared Sensitive)',
      iso: 400,
      personality: 'Artistic Infrared Tones',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFF5A5A5A),
      bestFor: ['Infrared effects', 'Landscapes', 'Artistic B&W', 'Extended red sensitivity'],
      description: 'German B&W with extended red sensitivity. Creates dreamy skies and glowing foliage. A creative tool.',
      pipeline: PipelineConfig(
        temperature: 0,
        saturation: 0,
        exposureBias: 0.15,
        contrastBias: 0.2,
        highlights: 0.1,
        shadows: 0.15,
        grainStrength: 0.35,
        grainSize: 1.1,
        vignetteStrength: 0.2,
        clarity: 0.1,
        blackWhiteMode: true,
        redSensitivity: 1.5,
      ),
      icon3DAssetPath: 'assets/camera_icons/rollei_retro_400s.png',
    );
  }

  // ========================================
  // 👑 PRO TIER - SPECIAL FILMS (5 cameras)
  // ========================================

  static CameraModel _lomoRedscale() {
    return const CameraModel(
      id: 'lomo_redscale',
      name: 'Lomo Redscale',
      era: '2000s-Present',
      type: 'Redscale',
      iso: 100,
      personality: 'Apocalyptic Red',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFFB22222),
      bestFor: ['Experimental', 'Golden hour', 'Surreal landscapes', 'Artistic shots'],
      description: 'Film shot backwards through the base. Everything turns red/orange. Surreal, apocalyptic vibes.',
      pipeline: PipelineConfig(
        temperature: 30,
        saturation: 1.1,
        exposureBias: 0.3,
        contrastBias: 0.15,
        highlights: 0.1,
        shadows: 0,
        grainStrength: 0.35,
        grainSize: 1.2,
        vignetteStrength: 0.25,
        clarity: 0.1,
        redscaleMode: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/lomo_redscale.png',
    );
  }

  static CameraModel _lomoPurple() {
    return const CameraModel(
      id: 'lomo_purple',
      name: 'Lomography Purple',
      era: '2010s-Present',
      type: 'Color Shift',
      iso: 400,
      personality: 'Psychedelic Shift',
      isPro: true,
      price: r'$3.49',
      iconColor: Color(0xFF9932CC),
      bestFor: ['Experimental', 'Music festivals', 'Creative shoots', 'Color shift art'],
      description: 'Color-shifting experimental film. Greens become purple, reality gets weird. For the adventurous.',
      pipeline: PipelineConfig(
        temperature: -10,
        saturation: 1.15,
        exposureBias: 0.2,
        contrastBias: 0.1,
        highlights: 0.05,
        shadows: 0.1,
        grainStrength: 0.3,
        grainSize: 1.1,
        vignetteStrength: 0.2,
        clarity: 0,
        hueShift: 60,
        greenToMagenta: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/lomo_purple.png',
    );
  }

  static CameraModel _aerochrome() {
    return const CameraModel(
      id: 'aerochrome',
      name: 'Aerochrome',
      era: '1960s-2009 (Discontinued)',
      type: 'Infrared Color',
      iso: 400,
      personality: 'False Color Infrared',
      isPro: true,
      price: r'$4.99',
      iconColor: Color(0xFFFF1493),
      bestFor: ['Surreal landscapes', 'Artistic work', 'Pink foliage', 'Dreamscapes'],
      description: 'Legendary false-color infrared film. Green foliage turns hot pink. Originally for aerial surveillance.',
      pipeline: PipelineConfig(
        temperature: 5,
        saturation: 1.2,
        exposureBias: 0.2,
        contrastBias: 0.15,
        highlights: 0.1,
        shadows: 0.1,
        grainStrength: 0.25,
        grainSize: 1.0,
        vignetteStrength: 0.2,
        clarity: 0.1,
        infraredMode: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/aerochrome.png',
    );
  }

  static CameraModel _xproSlide() {
    return const CameraModel(
      id: 'xpro_slide',
      name: 'X-Pro Slide',
      era: 'Technique-based',
      type: 'Cross-Processed',
      iso: 100,
      personality: 'Vintage Fashion',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFF00CED1),
      bestFor: ['Fashion', 'Music videos', 'Retro aesthetic', '90s look'],
      description: 'Slide film cross-processed in C-41. High contrast, shifted colors, the classic 90s fashion look.',
      pipeline: PipelineConfig(
        temperature: 10,
        saturation: 1.25,
        exposureBias: 0.1,
        contrastBias: 0.3,
        highlights: 0.15,
        shadows: -0.1,
        grainStrength: 0.2,
        grainSize: 0.9,
        vignetteStrength: 0.15,
        clarity: 0.1,
        crossProcessed: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/xpro_slide.png',
    );
  }

  static CameraModel _expiredFilm() {
    return const CameraModel(
      id: 'expired_film',
      name: 'Expired Film',
      era: 'Various',
      type: 'Expired',
      iso: 400,
      personality: 'Unpredictable Vintage',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFFDEB887),
      bestFor: ['Lo-fi aesthetic', 'Vintage look', 'Experimental', 'Happy accidents'],
      description: 'Simulates film past its expiration date. Faded colors, lifted blacks, random color shifts. Embrace the chaos.',
      pipeline: PipelineConfig(
        temperature: 12,
        saturation: 0.85,
        exposureBias: 0.4,
        contrastBias: -0.1,
        highlights: -0.1,
        shadows: 0.2,
        grainStrength: 0.4,
        grainSize: 1.3,
        vignetteStrength: 0.3,
        clarity: -0.1,
        expiredMode: true,
        fogLevel: 0.15,
        randomColorShift: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/expired_film.png',
    );
  }

  // ========================================
  // 👑 PRO TIER - INSTANT FILMS (3 cameras)
  // ========================================

  static CameraModel _polaroid600() {
    return const CameraModel(
      id: 'polaroid_600',
      name: 'Polaroid 600',
      era: '1980s-Present',
      type: 'Instant',
      iso: 640,
      personality: 'Classic Instant',
      isPro: true,
      price: r'$2.99',
      iconColor: Color(0xFFFCFAF5),
      bestFor: ['Parties', 'Casual moments', 'Nostalgic photos', 'Instant gratification'],
      description: 'The iconic Polaroid look. Soft focus, slightly washed colors, distinct instant film aesthetic.',
      pipeline: PipelineConfig(
        temperature: 5,
        saturation: 0.95,
        exposureBias: 0.3,
        contrastBias: -0.05,
        highlights: -0.1,
        shadows: 0.15,
        grainStrength: 0.15,
        grainSize: 0.8,
        vignetteStrength: 0.15,
        clarity: -0.15,
        softFocus: 0.1,
        instantFilm: true,
        instantBorder: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/polaroid_600.png',
    );
  }

  static CameraModel _polaroidSX70() {
    return const CameraModel(
      id: 'polaroid_sx70',
      name: 'Polaroid SX-70',
      era: '1972-Present',
      type: 'Instant',
      iso: 160,
      personality: 'Warm & Dreamy',
      isPro: true,
      price: r'$3.49',
      iconColor: Color(0xFFFFF8DC),
      bestFor: ['Artistic portraits', 'Dreamy aesthetics', 'Vintage collectors', 'Soft romantic shots'],
      description: 'The original folding Polaroid. Softer, dreamier than 600. A favorite of artists and celebrities.',
      pipeline: PipelineConfig(
        temperature: 8,
        saturation: 0.9,
        exposureBias: 0.35,
        contrastBias: -0.1,
        highlights: -0.15,
        shadows: 0.2,
        grainStrength: 0.12,
        grainSize: 0.7,
        vignetteStrength: 0.2,
        clarity: -0.2,
        softFocus: 0.15,
        dreamyGlow: 0.2,
        instantFilm: true,
        instantBorder: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/polaroid_sx70.png',
    );
  }

  static CameraModel _fujiInstax() {
    return const CameraModel(
      id: 'fuji_instax',
      name: 'Fuji Instax Mini',
      era: '1998-Present',
      type: 'Instant',
      iso: 800,
      personality: 'Bright & Fun',
      isPro: true,
      price: r'$2.49',
      iconColor: Color(0xFFFFE4E1),
      bestFor: ['Friends & selfies', 'Parties', 'Scrapbooking', 'Fun moments'],
      description: 'Modern instant film. Brighter, punchier than Polaroid. The go-to for cute, casual shots.',
      pipeline: PipelineConfig(
        temperature: 3,
        saturation: 1.1,
        exposureBias: 0.25,
        contrastBias: 0.05,
        highlights: 0,
        shadows: 0.1,
        grainStrength: 0.1,
        grainSize: 0.6,
        vignetteStrength: 0.1,
        clarity: 0,
        softFocus: 0.05,
        instantFilm: true,
        instantBorder: true,
      ),
      icon3DAssetPath: 'assets/camera_icons/fuji_instax.png',
    );
  }

  // ========================================
  // 👑 PRO TIER - TOY CAMERAS (2 cameras)
  // ========================================

  static CameraModel _holgaPlastic() {
    return const CameraModel(
      id: 'holga_plastic',
      name: 'Holga 120N',
      era: '1982-Present',
      type: 'Toy Camera',
      iso: 400,
      personality: 'Lo-Fi Blur',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFF8B4513),
      bestFor: ['Artistic blur', 'Light leaks', 'Dreamy photos', 'Experimental'],
      description: 'The famous plastic camera. Heavy vignette, soft edges, light leaks. Imperfection is the aesthetic.',
      pipeline: PipelineConfig(
        temperature: 8,
        saturation: 1.0,
        exposureBias: 0.3,
        contrastBias: 0,
        highlights: 0,
        shadows: 0.1,
        grainStrength: 0.3,
        grainSize: 1.2,
        vignetteStrength: 0.5,
        clarity: -0.2,
        softFocus: 0.25,
        lightLeaks: true,
        lightLeakIntensity: 0.3,
      ),
      icon3DAssetPath: 'assets/camera_icons/holga_plastic.png',
    );
  }

  static CameraModel _dianaFPlus() {
    return const CameraModel(
      id: 'diana_f_plus',
      name: 'Diana F+',
      era: '1960s (2007 reissue)',
      type: 'Toy Camera',
      iso: 400,
      personality: 'Dreamy Softness',
      isPro: true,
      price: r'$1.99',
      iconColor: Color(0xFF9370DB),
      bestFor: ['Retro vibes', 'Soft portraits', 'Double exposures', 'Art projects'],
      description: 'The original lo-fi camera, reissued. Extreme softness, dreamy glow, unpredictable results.',
      pipeline: PipelineConfig(
        temperature: 5,
        saturation: 0.95,
        exposureBias: 0.35,
        contrastBias: -0.1,
        highlights: -0.1,
        shadows: 0.15,
        grainStrength: 0.25,
        grainSize: 1.1,
        vignetteStrength: 0.45,
        clarity: -0.25,
        softFocus: 0.3,
        dreamyGlow: 0.25,
        lightLeaks: true,
        lightLeakIntensity: 0.25,
      ),
      icon3DAssetPath: 'assets/camera_icons/diana_f_plus.png',
    );
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  /// Get only free cameras
  static List<CameraModel> getFreeCameras() {
    return getAllCameras().where((camera) => !camera.isPro).toList();
  }

  /// Get only pro cameras
  static List<CameraModel> getProCameras() {
    return getAllCameras().where((camera) => camera.isPro).toList();
  }

  /// Get camera by ID
  static CameraModel? getCameraById(String id) {
    try {
      return getAllCameras().firstWhere((camera) => camera.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search cameras by name, type, or personality
  static List<CameraModel> searchCameras(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllCameras().where((camera) {
      return camera.name.toLowerCase().contains(lowerQuery) ||
          camera.type.toLowerCase().contains(lowerQuery) ||
          camera.personality.toLowerCase().contains(lowerQuery) ||
          camera.era.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter cameras by type
  static List<CameraModel> filterByType(String type) {
    return getAllCameras().where((camera) {
      return camera.type.toLowerCase().contains(type.toLowerCase());
    }).toList();
  }

  /// Get cameras by category
  static List<CameraModel> filterByCategory(CameraCategory category) {
    switch (category) {
      case CameraCategory.all:
        return getAllCameras();
      case CameraCategory.free:
        return getFreeCameras();
      case CameraCategory.pro:
        return getProCameras();
      case CameraCategory.color:
        return getAllCameras()
            .where((c) =>
                c.type.toLowerCase().contains('color') &&
                !c.type.toLowerCase().contains('black'))
            .toList();
      case CameraCategory.blackAndWhite:
        return getAllCameras()
            .where((c) => c.type.toLowerCase().contains('black'))
            .toList();
      case CameraCategory.instant:
        return getAllCameras()
            .where((c) => c.type.toLowerCase().contains('instant'))
            .toList();
      case CameraCategory.special:
        return getAllCameras()
            .where((c) =>
                c.type.toLowerCase().contains('redscale') ||
                c.type.toLowerCase().contains('infrared') ||
                c.type.toLowerCase().contains('cross') ||
                c.type.toLowerCase().contains('expired') ||
                c.type.toLowerCase().contains('color shift'))
            .toList();
      case CameraCategory.toy:
        return getAllCameras()
            .where((c) => c.type.toLowerCase().contains('toy'))
            .toList();
    }
  }
}
