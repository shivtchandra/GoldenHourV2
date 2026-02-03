# 📷 FilmCam - Complete Screen Architecture & Design Specification
## Personalized Onboarding + All App Screens

---

## 🎨 Design Philosophy

**Visual Language**: **Analog-Digital Fusion**
- Warm, tactile film photography aesthetic meets modern digital interface
- Real camera imagery integrated with UI elements
- Golden hour lighting and warm gradients throughout
- Vintage photography studio meets contemporary app design

**Typography System:**
```dart
Primary Display: Warbler Deck Regular (or similar serif with character)
- Headlines, camera names, dramatic moments
- Gives sophisticated, editorial magazine feel

Secondary: DM Sans or Manrope
- Body text, descriptions, UI labels
- Clean, readable, modern

Accent: Cutive Mono or JetBrains Mono
- Technical specs (ISO, aperture, shutter speed)
- Frame counters, timestamps
```

**Color Palette:**
```dart
// Golden Hour Theme
warmGold: #F4C542
deepAmber: #D4A049
sunsetOrange: #FF6B35
filmRed: #FF4444
darkroom: #1A1510
creamPaper: #FFF8E7
charcoal: #2D2824

// Accent Colors
vintageBlue: #5B9BD5
forestGreen: #4A7C59
dustyRose: #C9ADA7
```

---

## 📱 Complete Screen Flow

```
Launch → Splash → Onboarding (4 screens) → Home → Camera/Presets/Develop/Favorites/Gallery/Settings
```

---

## 1️⃣ SPLASH SCREEN

### Visual Design
```
┌─────────────────────────────────┐
│                                 │
│                                 │
│                                 │
│                                 │
│          [Animated]             │
│       🎞️ FilmCam Logo           │
│                                 │
│     "Capture Life on Film"      │
│                                 │
│                                 │
│          ○ ○ ○ ○ ○              │ <- Loading dots
│                                 │
└─────────────────────────────────┘
```

### Implementation
```dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.5)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
    
    // Navigate to onboarding after animation
    Future.delayed(Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
              OnboardingScreen1(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A1810),
              Color(0xFF1A1510),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Film reel icon animation
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFF4C542).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/filmcam_logo.png',
                        ),
                      ),
                      
                      SizedBox(height: 32),
                      
                      Text(
                        'FilmCam',
                        style: GoogleFonts.warblerDeckRegular(
                          fontSize: 48,
                          color: Color(0xFFF4C542),
                          letterSpacing: 2,
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      Text(
                        'Capture Life on Film',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Color(0xFFFFF8E7),
                          letterSpacing: 1,
                        ),
                      ),
                      
                      SizedBox(height: 60),
                      
                      // Loading dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedDot(delay: index * 200),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

---

## 2️⃣ ONBOARDING SCREENS (Personalized Experience)

### **ONBOARDING 1: Welcome with Golden Hour Camera**

```
┌─────────────────────────────────┐
│                                 │
│     [Real camera photo with     │
│      golden hour lighting]      │
│                                 │
│      📷 Vintage camera on       │
│      warm wooden surface,       │
│      sunset light streaming     │
│                                 │
├─────────────────────────────────┤
│  [Gradient overlay: warm gold]  │
│                                 │
│       Welcome to FilmCam        │ <- Warbler Deck Regular
│                                 │
│   Transform your digital photos │
│   into timeless film memories   │
│                                 │
│            [Continue →]         │
│                                 │
│         Skip to App →           │
└─────────────────────────────────┘
```

```dart
class OnboardingScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background: Real camera photo
          Positioned.fill(
            child: Image.asset(
              'assets/onboarding/golden_hour_camera.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFF1A1510).withOpacity(0.7),
                    Color(0xFF1A1510),
                  ],
                  stops: [0.0, 0.5, 0.9],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Spacer(flex: 2),
                  
                  // Title
                  Text(
                    'Welcome to FilmCam',
                    style: GoogleFonts.warblerDeckRegular(
                      fontSize: 42,
                      color: Color(0xFFF4C542),
                      height: 1.2,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Transform your digital photos\ninto timeless film memories',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      color: Color(0xFFFFF8E7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  Spacer(),
                  
                  // Continue button
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OnboardingScreen2()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4C542),
                      foregroundColor: Color(0xFF1A1510),
                      padding: EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Continue',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Skip button
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                    ),
                    child: Text(
                      'Skip to App →',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Color(0xFFFFF8E7).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### **ONBOARDING 2: Photo Style Preferences**

```
┌─────────────────────────────────┐
│  ← Back                         │
│                                 │
│   How would you like            │
│   your photos?                  │ <- Warbler Deck
│                                 │
│   [Visual selection cards]      │
│                                 │
│   ┌─────────┐  ┌─────────┐     │
│   │  Warm   │  │  Cool   │     │
│   │ Nostalgic│  │ Modern  │     │
│   │         │  │         │     │
│   │ [Photo] │  │ [Photo] │     │
│   └─────────┘  └─────────┘     │
│                                 │
│   ┌─────────┐  ┌─────────┐     │
│   │Vibrant  │  │ Muted   │     │
│   │& Punchy │  │& Subtle │     │
│   │         │  │         │     │
│   │ [Photo] │  │ [Photo] │     │
│   └─────────┘  └─────────┘     │
│                                 │
│   ┌─────────┐  ┌─────────┐     │
│   │  B&W    │  │ Vintage │     │
│   │ Classic │  │ Colors  │     │
│   │         │  │         │     │
│   │ [Photo] │  │ [Photo] │     │
│   └─────────┘  └─────────┘     │
│                                 │
│          [Continue →]           │
│      2 of 4  ● ● ○ ○           │
└─────────────────────────────────┘
```

```dart
class OnboardingScreen2 extends StatefulWidget {
  @override
  State<OnboardingScreen2> createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> {
  Set<String> selectedStyles = {};
  
  final List<StyleOption> styles = [
    StyleOption(
      id: 'warm',
      title: 'Warm Nostalgic',
      description: 'Golden, sunny tones',
      imagePath: 'assets/onboarding/style_warm.jpg',
      recommendedCameras: ['kodak_gold_200', 'kodak_colorplus_200'],
    ),
    StyleOption(
      id: 'cool',
      title: 'Cool Modern',
      description: 'Blue-green vibes',
      imagePath: 'assets/onboarding/style_cool.jpg',
      recommendedCameras: ['fuji_superia_400', 'fuji_c200'],
    ),
    StyleOption(
      id: 'vibrant',
      title: 'Vibrant & Punchy',
      description: 'Bold, saturated colors',
      imagePath: 'assets/onboarding/style_vibrant.jpg',
      recommendedCameras: ['kodak_ektar_100', 'fuji_velvia_50'],
    ),
    StyleOption(
      id: 'muted',
      title: 'Muted & Subtle',
      description: 'Soft, pastel tones',
      imagePath: 'assets/onboarding/style_muted.jpg',
      recommendedCameras: ['fuji_pro_400h', 'kodak_portra_400'],
    ),
    StyleOption(
      id: 'bw',
      title: 'B&W Classic',
      description: 'Timeless monochrome',
      imagePath: 'assets/onboarding/style_bw.jpg',
      recommendedCameras: ['ilford_hp5', 'kodak_trix_400'],
    ),
    StyleOption(
      id: 'vintage',
      title: 'Vintage Colors',
      description: 'Retro film look',
      imagePath: 'assets/onboarding/style_vintage.jpg',
      recommendedCameras: ['agfa_vista_200', 'lomo_800'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFF8E7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'How would you like\nyour photos?',
                style: GoogleFonts.warblerDeckRegular(
                  fontSize: 36,
                  color: Color(0xFFF4C542),
                  height: 1.2,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'Select all that apply',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Color(0xFFFFF8E7).withOpacity(0.7),
                ),
              ),
              
              SizedBox(height: 32),
              
              // Style grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: styles.length,
                  itemBuilder: (context, index) {
                    final style = styles[index];
                    final isSelected = selectedStyles.contains(style.id);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedStyles.remove(style.id);
                          } else {
                            selectedStyles.add(style.id);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? Color(0xFFF4C542) 
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Color(0xFFF4C542).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ] : [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background image
                              Image.asset(
                                style.imagePath,
                                fit: BoxFit.cover,
                              ),
                              
                              // Gradient overlay
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Text
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      style.title,
                                      style: GoogleFonts.warblerDeckRegular(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      style.description,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Checkmark
                              if (isSelected)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF4C542),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 20,
                                      color: Color(0xFF1A1510),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 24),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedStyles.isEmpty ? null : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingScreen3(
                          selectedStyles: selectedStyles,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF4C542),
                    foregroundColor: Color(0xFF1A1510),
                    disabledBackgroundColor: Color(0xFF3D3D3D),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '2 of 4',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Color(0xFFFFF8E7).withOpacity(0.5),
                    ),
                  ),
                  SizedBox(width: 16),
                  ...List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < 2 
                            ? Color(0xFFF4C542) 
                            : Color(0xFF3D3D3D),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StyleOption {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final List<String> recommendedCameras;

  StyleOption({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.recommendedCameras,
  });
}
```

---

### **ONBOARDING 3: Photo Format & Aspect Ratio**

```
┌─────────────────────────────────┐
│  ← Back                         │
│                                 │
│   What format do you            │
│   prefer for photos?            │
│                                 │
│   ┌─────────────────────────┐   │
│   │    [3:4 Portrait]       │   │
│   │   ┌───────────┐         │   │
│   │   │           │         │   │
│   │   │  Sample   │         │   │
│   │   │   Photo   │         │   │
│   │   │           │         │   │
│   │   └───────────┘         │   │
│   │  Instagram Stories      │   │
│   │  Portrait Photography   │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │    [1:1 Square]         │   │
│   │   ┌──────────┐          │   │
│   │   │          │          │   │
│   │   │  Sample  │          │   │
│   │   │          │          │   │
│   │   └──────────┘          │   │
│   │  Instagram Feed         │   │
│   │  Classic Format         │   │
│   └─────────────────────────┘   │
│                                 │
│   ┌─────────────────────────┐   │
│   │  [16:9 Landscape]       │   │
│   │  ┌──────────────────┐   │   │
│   │  │    Sample Photo  │   │   │
│   │  └──────────────────┘   │   │
│   │  Widescreen             │   │
│   │  Cinematic Look         │   │
│   └─────────────────────────┘   │
│                                 │
│          [Continue →]           │
│      3 of 4  ● ● ● ○           │
└─────────────────────────────────┘
```

```dart
class OnboardingScreen3 extends StatefulWidget {
  final Set<String> selectedStyles;
  
  const OnboardingScreen3({required this.selectedStyles});

  @override
  State<OnboardingScreen3> createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> {
  String selectedFormat = '3:4';
  
  final List<FormatOption> formats = [
    FormatOption(
      ratio: '3:4',
      title: '3:4 Portrait',
      description: 'Instagram Stories\nPortrait Photography',
      icon: Icons.phone_android,
    ),
    FormatOption(
      ratio: '1:1',
      title: '1:1 Square',
      description: 'Instagram Feed\nClassic Format',
      icon: Icons.crop_square,
    ),
    FormatOption(
      ratio: '16:9',
      title: '16:9 Landscape',
      description: 'Widescreen\nCinematic Look',
      icon: Icons.crop_landscape,
    ),
    FormatOption(
      ratio: '4:3',
      title: '4:3 Classic',
      description: 'Traditional Film\nVintage Format',
      icon: Icons.camera,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFFF8E7)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What format do you\nprefer for photos?',
                style: GoogleFonts.warblerDeckRegular(
                  fontSize: 36,
                  color: Color(0xFFF4C542),
                  height: 1.2,
                ),
              ),
              
              SizedBox(height: 8),
              
              Text(
                'You can always change this later',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Color(0xFFFFF8E7).withOpacity(0.7),
                ),
              ),
              
              SizedBox(height: 32),
              
              Expanded(
                child: ListView.builder(
                  itemCount: formats.length,
                  itemBuilder: (context, index) {
                    final format = formats[index];
                    final isSelected = selectedFormat == format.ratio;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: GestureDetector(
                        onTap: () => setState(() => selectedFormat = format.ratio),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Color(0xFFF4C542).withOpacity(0.1)
                                : Color(0xFF2D2824),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? Color(0xFFF4C542) 
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Format preview
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1510),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  format.icon,
                                  size: 40,
                                  color: isSelected 
                                      ? Color(0xFFF4C542) 
                                      : Color(0xFFFFF8E7).withOpacity(0.5),
                                ),
                              ),
                              
                              SizedBox(width: 20),
                              
                              // Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      format.title,
                                      style: GoogleFonts.warblerDeckRegular(
                                        fontSize: 20,
                                        color: Color(0xFFFFF8E7),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      format.description,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        color: Color(0xFFFFF8E7).withOpacity(0.6),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Radio button
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? Color(0xFFF4C542) 
                                        : Color(0xFFFFF8E7).withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: isSelected 
                                    ? Center(
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFFF4C542),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingScreen4(
                          selectedStyles: widget.selectedStyles,
                          selectedFormat: selectedFormat,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF4C542),
                    foregroundColor: Color(0xFF1A1510),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '3 of 4',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Color(0xFFFFF8E7).withOpacity(0.5),
                    ),
                  ),
                  SizedBox(width: 16),
                  ...List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < 3 
                            ? Color(0xFFF4C542) 
                            : Color(0xFF3D3D3D),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormatOption {
  final String ratio;
  final String title;
  final String description;
  final IconData icon;

  FormatOption({
    required this.ratio,
    required this.title,
    required this.description,
    required this.icon,
  });
}
```

---

### **ONBOARDING 4: Your Personalized Camera Collection**

```
┌─────────────────────────────────┐
│  ← Back                         │
│                                 │
│   Your Personalized             │
│   Film Collection               │
│                                 │
│   Based on your preferences,    │
│   we've selected these free     │
│   cameras just for you:         │
│                                 │
│   ┌─────────┐ ┌─────────┐      │
│   │  Camera │ │  Camera │      │
│   │    1    │ │    2    │      │
│   │  [Icon] │ │  [Icon] │      │
│   │  Gold   │ │ Superia │      │
│   │   200   │ │   400   │      │
│   └─────────┘ └─────────┘      │
│                                 │
│   ┌─────────┐                   │
│   │  Camera │                   │
│   │    3    │                   │
│   │  [Icon] │                   │
│   │  HP5+   │                   │
│   └─────────┘                   │
│                                 │
│   ✨ Plus 27 more cameras       │
│      available in PRO           │
│                                 │
│      [Let's Start Shooting!]    │
│                                 │
│      4 of 4  ● ● ● ●           │
└─────────────────────────────────┘
```

I'll create a comprehensive document with ALL the remaining screens. Let me continue:
