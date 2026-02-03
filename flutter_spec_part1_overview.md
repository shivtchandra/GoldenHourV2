# 📷 Film Camera App - Flutter Development Specification
## Part 1: Overview, Architecture & Design System

---

## 🎯 Executive Summary

**App Name**: FilmCam (or your preferred name)  
**Platform**: iOS & Android (Flutter)  
**Core Purpose**: Apply authentic film camera effects to digital photos using scientifically accurate color grading pipelines  
**Monetization**: Freemium (3 free cameras + 27 PRO cameras via in-app purchase)  
**Target Audience**: Photography enthusiasts, content creators, Instagram users, film photography fans

---

## 📱 App Architecture Overview

### Tech Stack
```yaml
Framework: Flutter 3.x+
Language: Dart
State Management: Riverpod (recommended) or Provider
Image Processing: 
  - image package (Dart native)
  - flutter_gpu_image (hardware acceleration)
  - Custom shaders for advanced effects
Camera: 
  - camera package
  - image_picker package
Storage:
  - shared_preferences (settings)
  - hive or sqflite (camera favorites)
  - path_provider (file management)
Monetization:
  - in_app_purchase package
  - revenue_cat (optional, for subscription management)
Analytics:
  - firebase_analytics
  - firebase_crashlytics
```

### Project Structure
```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── typography.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── asset_paths.dart
│   ├── services/
│   │   ├── camera_service.dart
│   │   ├── image_processing_service.dart
│   │   ├── storage_service.dart
│   │   └── purchase_service.dart
│   └── utils/
│       ├── color_utils.dart
│       └── image_utils.dart
├── features/
│   ├── camera/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── camera_model.dart
│   │   │   │   └── pipeline_config.dart
│   │   │   └── repositories/
│   │   │       └── camera_repository.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── camera_screen.dart
│   │   │   │   ├── camera_selector_screen.dart
│   │   │   │   └── preview_screen.dart
│   │   │   └── widgets/
│   │   │       ├── camera_card.dart
│   │   │       ├── camera_preview.dart
│   │   │       ├── film_effect_overlay.dart
│   │   │       └── shutter_button.dart
│   │   └── providers/
│   │       ├── camera_provider.dart
│   │       └── selected_camera_provider.dart
│   ├── processing/
│   │   ├── pipelines/
│   │   │   ├── base_pipeline.dart
│   │   │   ├── color_pipeline.dart
│   │   │   ├── bw_pipeline.dart
│   │   │   ├── special_effects_pipeline.dart
│   │   │   └── instant_film_pipeline.dart
│   │   └── effects/
│   │       ├── grain_effect.dart
│   │       ├── vignette_effect.dart
│   │       ├── split_tone_effect.dart
│   │       ├── halation_effect.dart
│   │       └── light_leak_effect.dart
│   ├── gallery/
│   │   └── presentation/
│   │       └── screens/
│   │           └── gallery_screen.dart
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── settings_screen.dart
└── shared/
    └── widgets/
        ├── pro_badge.dart
        └── loading_indicator.dart
```

---

## 🎨 Design System & UI/UX Specifications

### Design Aesthetic Direction

**Overall Vibe**: **Retro-Modern Film Photography Studio**
- Blend of vintage film camera aesthetics with clean, modern UI patterns
- Rich, textured backgrounds inspired by film packaging
- Warm, nostalgic color palette with pops of vibrant accents
- Tactile, physical design language (buttons feel like shutter releases)

### Color Palette

```dart
// lib/app/theme/colors.dart

class AppColors {
  // Primary Brand Colors
  static const Color primaryBlack = Color(0xFF1A1A1A);
  static const Color primaryCream = Color(0xFFFFF8E7);
  static const Color accentGold = Color(0xFFF4C542);
  static const Color accentFilmRed = Color(0xFFFF4444);
  
  // Background Gradients
  static const Gradient darkroomGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A1810), Color(0xFF1A1A1A)],
  );
  
  static const Gradient vintagePaperGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF8E7), Color(0xFFF5E6D3)],
  );
  
  // Camera Category Colors
  static const Color freeGreen = Color(0xFF4CAF50);
  static const Color proGold = Color(0xFFFFB74D);
  static const Color colorFilmBlue = Color(0xFF42A5F5);
  static const Color bwGray = Color(0xFF757575);
  static const Color specialPurple = Color(0xFFAB47BC);
  static const Color instantPink = Color(0xFFEC407A);
  
  // UI Element Colors
  static const Color cardBackground = Color(0xFF2D2D2D);
  static const Color cardBackgroundLight = Color(0xFFFFFBF0);
  static const Color divider = Color(0xFF3D3D3D);
  static const Color textPrimary = Color(0xFFFFFFF5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textPrimaryDark = Color(0xFF1A1A1A);
}
```

### Typography

```dart
// lib/app/theme/typography.dart

import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Display Font: Bold, vintage camera branding feel
  static TextStyle displayLarge = GoogleFonts.bebasNeue(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    height: 1.1,
  );
  
  static TextStyle displayMedium = GoogleFonts.bebasNeue(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
  
  // Headlines: Camera names, section titles
  static TextStyle headlineLarge = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static TextStyle headlineMedium = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );
  
  // Body: Descriptions, settings
  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
  
  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  // Labels: Buttons, tags
  static TextStyle labelLarge = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );
  
  // Monospace: Technical specs (ISO, aperture)
  static TextStyle monoMedium = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );
}
```

### Component Specifications

#### 1. Camera Selection Card

```dart
// Visual Design:
// - 3D camera icon on top (generated separately)
// - Camera name in headline font
// - Era badge (vintage ribbon style)
// - Personality tag (film strip design)
// - Pro badge if applicable (gold foil effect)
// - Gradient background matching iconColor
// - Subtle grain texture overlay
// - Pressed state: slight rotation + scale animation

Dimensions: 160 x 220 dp
Border Radius: 16dp
Elevation: 4dp (normal), 12dp (pressed)
Animation Duration: 200ms cubic-bezier(0.4, 0.0, 0.2, 1)
```

#### 2. Shutter Button

```dart
// Design: Concentric circles mimicking real camera shutter
// - Outer ring: 80dp diameter, 4dp border, accentFilmRed
// - Middle ring: 68dp diameter, subtle gradient
// - Inner circle: 56dp diameter, solid white center
// - Press animation: rings collapse inward, haptic feedback
// - Film advance sound effect on capture

Animation:
- Tap: scale(0.9) → scale(1.05) → scale(1.0) in 300ms
- Haptic: HapticFeedback.heavyImpact()
- Sound: film_advance.mp3 (50ms)
```

#### 3. Film Effect Overlay (Real-time Preview)

```dart
// Live preview effects while camera is active:
// - Grain overlay (animated, subtle movement)
// - Vignette (radial gradient, soft edges)
// - Light leaks (for Holga/Diana cameras, subtle animation)
// - Color temperature shift indicator
// - Frame counter (vintage LCD font, top right)

Opacity: 0.6 (adjustable in settings)
Frame Rate: 30 fps for grain animation
Update Rate: Real-time as user switches cameras
```

---

## 📸 Screen Specifications

### 1. Home/Camera Screen (Main Interface)

**Layout:**
```
┌─────────────────────────────────┐
│  ☰  FILMCAM        🎞️  ⚙️       │ <- Header (60dp)
├─────────────────────────────────┤
│                                 │
│         CAMERA VIEWFINDER        │
│      (with real-time effect)    │
│                                 │
│         [3:4 aspect ratio]      │
│                                 │
│         FRAME COUNTER: 24       │
│                                 │
├─────────────────────────────────┤
│  Selected: Kodak Gold 200       │ <- Info Bar (50dp)
│  ISO 200 • Color Negative        │
├─────────────────────────────────┤
│           ⭕ SHUTTER             │ <- Controls (120dp)
│    [📷]            [🔄]          │
│  Gallery        Switch Cam      │
└─────────────────────────────────┘
```

**Features:**
- Real-time film effect preview
- Swipe up to open camera selector
- Tap info bar to see camera details
- Double-tap viewfinder to switch front/back camera
- Volume buttons as shutter (optional in settings)
- Grid overlay toggle (rule of thirds)
- Level indicator for landscape photography

**Gestures:**
- Pinch to zoom
- Tap to focus
- Long-press on shutter for burst mode (if implementing)
- Swipe left/right to cycle through recently used cameras

### 2. Camera Selector Screen

**Layout:**
```
┌─────────────────────────────────┐
│  ← Back    CHOOSE YOUR FILM     │
├─────────────────────────────────┤
│  [Search: "Find a camera..."]   │
├─────────────────────────────────┤
│  FILTERS:                        │
│  [All] [FREE] [PRO] [Color]     │
│  [B&W] [Instant] [Special]       │
├─────────────────────────────────┤
│                                 │
│    🆓 FREE CAMERAS (3)          │
│  ┌───────┐ ┌───────┐ ┌───────┐ │
│  │ Gold  │ │Superia│ │  HP5  │ │
│  │  200  │ │  400  │ │ Plus  │ │
│  └───────┘ └───────┘ └───────┘ │
│                                 │
│    👑 PRO COLOR FILMS (12)      │
│  ┌───────┐ ┌───────┐ ┌───────┐ │
│  │ 🔒    │ │ 🔒    │ │ 🔒    │ │
│  │Portra │ │Ektar  │ │Cinest │ │
│  │ $2.99 │ │ $2.99 │ │ $3.99 │ │
│  └───────┘ └───────┘ └───────┘ │
└─────────────────────────────────┘
```

**Features:**
- Horizontal scrolling grid (2-3 columns)
- Filter chips (sticky header)
- Search functionality
- "Recently Used" section (max 4 cameras)
- "Favorites" section (user can star cameras)
- PRO cameras show lock icon + price until purchased

---

## 📊 Camera Categories Summary

| Category | Count | Price Range |
|----------|-------|-------------|
| **FREE** | 3 | Free |
| **Pro Color** | 12 | $1.99-$4.99 |
| **Pro B&W** | 5 | $1.99-$3.99 |
| **Pro Special** | 5 | $1.99-$4.99 |
| **Pro Instant** | 3 | $2.49-$3.99 |
| **Pro Toy** | 2 | $1.99 |
| **TOTAL** | **30** | |

---

**Continue to Part 2 for complete camera database and data models...**
