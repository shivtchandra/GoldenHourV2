# 📷 FilmCam - Complete Screen Specifications Part 2
## Main App Screens: Home, Presets, Develop, Favorites, Gallery, Settings

---

## **ONBOARDING 4: Personalized Camera Collection (Completion)**

```dart
class OnboardingScreen4 extends StatelessWidget {
  final Set<String> selectedStyles;
  final String selectedFormat;
  
  const OnboardingScreen4({
    required this.selectedStyles,
    required this.selectedFormat,
  });

  List<CameraModel> _getRecommendedCameras() {
    // Logic to determine recommended cameras based on user preferences
    List<CameraModel> recommended = [];
    
    if (selectedStyles.contains('warm')) {
      recommended.add(CameraRepository.getCameraById('kodak_gold_200')!);
    }
    if (selectedStyles.contains('cool')) {
      recommended.add(CameraRepository.getCameraById('fuji_superia_400')!);
    }
    if (selectedStyles.contains('bw') || recommended.length < 2) {
      recommended.add(CameraRepository.getCameraById('ilford_hp5')!);
    }
    
    // Always ensure 3 free cameras
    while (recommended.length < 3) {
      final freeCameras = CameraRepository.getFreeCameras();
      for (var camera in freeCameras) {
        if (!recommended.contains(camera)) {
          recommended.add(camera);
          break;
        }
      }
    }
    
    return recommended.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recommendedCameras = _getRecommendedCameras();
    
    return Scaffold(
      backgroundColor: Color(0xFF1A1510),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              
              // Title with animation
              TweenAnimationBuilder(
                duration: Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Personalized\nFilm Collection',
                      style: GoogleFonts.warblerDeckRegular(
                        fontSize: 38,
                        color: Color(0xFFF4C542),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Based on your preferences, we\'ve selected\nthese cameras just for you:',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: Color(0xFFFFF8E7).withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40),
              
              // Recommended cameras
              Expanded(
                child: Column(
                  children: [
                    // First two cameras in a row
                    Row(
                      children: [
                        Expanded(
                          child: _buildCameraCard(recommendedCameras[0], 0),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildCameraCard(recommendedCameras[1], 1),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Third camera centered
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.48,
                      child: _buildCameraCard(recommendedCameras[2], 2),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Pro teaser
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF4C542).withOpacity(0.1),
                      Color(0xFFD4A049).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xFFF4C542).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Color(0xFFF4C542),
                      size: 28,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Plus 27 more cameras',
                            style: GoogleFonts.warblerDeckRegular(
                              fontSize: 18,
                              color: Color(0xFFFFF8E7),
                            ),
                          ),
                          Text(
                            'Available in PRO',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Color(0xFFFFF8E7).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // Start button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Save preferences and navigate to home
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          recommendedCameras: recommendedCameras,
                          preferredFormat: selectedFormat,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF4C542),
                    foregroundColor: Color(0xFF1A1510),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    'Let\'s Start Shooting!',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '4 of 4',
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
                        color: Color(0xFFF4C542),
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
  
  Widget _buildCameraCard(CameraModel camera, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              camera.iconColor.withOpacity(0.2),
              camera.iconColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: camera.iconColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2D2824),
              ),
              child: Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: camera.iconColor,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              camera.name,
              style: GoogleFonts.warblerDeckRegular(
                fontSize: 16,
                color: Color(0xFFFFF8E7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            SizedBox(height: 4),
            if (camera.iso != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ISO ${camera.iso}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: Color(0xFFF4C542),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 3️⃣ HOME SCREEN (Main Hub)

### Visual Design
```
┌─────────────────────────────────┐
│  ☰  FilmCam          [Profile]  │
│                                 │
│  Good Evening, Sarah 🌅         │ <- Personalized greeting
│                                 │
│  ┌─────────────────────────┐   │
│  │  [Hero Camera Preview]  │   │
│  │   Currently Selected:   │   │
│  │   Kodak Gold 200        │   │
│  │   [Large 3D Icon]       │   │
│  │   [Tap to Shoot →]      │   │
│  └─────────────────────────┘   │
│                                 │
│  Quick Actions                  │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐  │
│  │📷  │ │🎨  │ │🖼️  │ │⭐  │  │
│  │Cam │ │Pre │ │Gal │ │Fav │  │
│  └────┘ └────┘ └────┘ └────┘  │
│                                 │
│  Recent Shots                   │
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐ →    │
│  │   │ │   │ │   │ │   │      │
│  └───┘ └───┘ └───┘ └───┘      │
│                                 │
│  Recommended for You            │
│  ┌─────────┐ ┌─────────┐       │
│  │ Portra  │ │Cinestill│       │
│  │   400   │ │  800T   │       │
│  │  $2.99  │ │  $3.99  │       │
│  └─────────┘ └─────────┘       │
│                                 │
│  ─────────────────────────      │
│  Camera  Develop  Profile      │ <- Bottom Nav
└─────────────────────────────────┘
```

```dart
class HomeScreen extends StatefulWidget {
  final List<CameraModel>? recommendedCameras;
  final String? preferredFormat;
  
  const HomeScreen({
    this.recommendedCameras,
    this.preferredFormat,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  CameraModel? _selectedCamera;
  
  @override
  void initState() {
    super.initState();
    _selectedCamera = widget.recommendedCameras?.first ?? 
                      CameraRepository.getFreeCameras().first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF8E7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    SizedBox(height: 24),
                    _buildHeroCamera(),
                    SizedBox(height: 32),
                    _buildQuickActions(),
                    SizedBox(height: 32),
                    _buildRecentShots(),
                    SizedBox(height: 32),
                    _buildRecommendedCameras(),
                    SizedBox(height: 100), // Bottom nav padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF1A1510), size: 28),
            onPressed: () {
              // Open drawer
            },
          ),
          Text(
            'FilmCam',
            style: GoogleFonts.warblerDeckRegular(
              fontSize: 24,
              color: Color(0xFF1A1510),
              letterSpacing: 1,
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF4C542),
            child: Text(
              'S',
              style: GoogleFonts.warblerDeckRegular(
                fontSize: 18,
                color: Color(0xFF1A1510),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 
        ? 'Good Morning' 
        : hour < 17 
            ? 'Good Afternoon' 
            : 'Good Evening';
    String emoji = hour < 12 
        ? '🌅' 
        : hour < 17 
            ? '☀️' 
            : '🌇';
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting $emoji',
            style: GoogleFonts.warblerDeckRegular(
              fontSize: 32,
              color: Color(0xFF1A1510),
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Ready to capture some memories?',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Color(0xFF1A1510).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHeroCamera() {
    if (_selectedCamera == null) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _selectedCamera!.iconColor.withOpacity(0.3),
            _selectedCamera!.iconColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _selectedCamera!.iconColor.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Currently Selected',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Color(0xFF1A1510).withOpacity(0.6),
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 16),
          
          // Camera 3D Icon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.5),
            ),
            child: Center(
              child: Icon(
                Icons.camera_alt,
                size: 70,
                color: _selectedCamera!.iconColor,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          Text(
            _selectedCamera!.name,
            style: GoogleFonts.warblerDeckRegular(
              fontSize: 28,
              color: Color(0xFF1A1510),
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedCamera!.iso != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ISO ${_selectedCamera!.iso}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: Color(0xFFF4C542),
                    ),
                  ),
                ),
                SizedBox(width: 8),
              ],
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1510).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedCamera!.type,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Color(0xFF1A1510),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          // Shoot button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CameraScreen(
                      selectedCamera: _selectedCamera!,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1A1510),
                foregroundColor: Color(0xFFF4C542),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Tap to Shoot',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions() {
    final actions = [
      QuickAction('Camera', Icons.camera_alt, Color(0xFFFF6B35), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CameraScreen()),
        );
      }),
      QuickAction('Presets', Icons.palette, Color(0xFF5B9BD5), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PresetsScreen()),
        );
      }),
      QuickAction('Gallery', Icons.photo_library, Color(0xFF4A7C59), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GalleryScreen()),
        );
      }),
      QuickAction('Favorites', Icons.star, Color(0xFFF4C542), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FavoritesScreen()),
        );
      }),
    ];
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.warblerDeckRegular(
              fontSize: 20,
              color: Color(0xFF1A1510),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((action) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: action.onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: action.color.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: action.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action.icon,
                              color: action.color,
                              size: 24,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            action.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Color(0xFF1A1510),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentShots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Shots',
                style: GoogleFonts.warblerDeckRegular(
                  fontSize: 20,
                  color: Color(0xFF1A1510),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GalleryScreen()),
                  );
                },
                child: Text(
                  'View All →',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Color(0xFFF4C542),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF2D2824),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage('assets/sample/shot_$index.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecommendedCameras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Recommended for You',
            style: GoogleFonts.warblerDeckRegular(
              fontSize: 20,
              color: Color(0xFF1A1510),
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            itemBuilder: (context, index) {
              final camera = CameraRepository.getProCameras()[index];
              return Container(
                width: 160,
                margin: EdgeInsets.only(right: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      camera.iconColor.withOpacity(0.2),
                      camera.iconColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: camera.iconColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: camera.iconColor,
                    ),
                    Column(
                      children: [
                        Text(
                          camera.name,
                          style: GoogleFonts.warblerDeckRegular(
                            fontSize: 16,
                            color: Color(0xFF1A1510),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFF4C542),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            camera.price ?? 'PRO',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1510),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.camera_alt, 'Camera', 1),
              _buildNavItem(Icons.developer_board, 'Develop', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        // Navigate to respective screen
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFFF4C542) : Color(0xFF1A1510).withOpacity(0.4),
            size: 26,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: isSelected ? Color(0xFFF4C542) : Color(0xFF1A1510).withOpacity(0.4),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction(this.label, this.icon, this.color, this.onTap);
}
```

---

Due to length constraints, I'll create additional parts for the remaining screens. Let me continue:
