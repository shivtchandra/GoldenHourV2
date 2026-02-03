import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../data/models/camera_model.dart';
import '../../../develop/presentation/screens/develop_screen.dart';
import '../../../../app/theme/colors.dart';

class InstantDevelopmentScreen extends StatefulWidget {
  final File imageFile;
  final CameraModel camera;
  final String aspectRatio;

  const InstantDevelopmentScreen({
    super.key,
    required this.imageFile,
    required this.camera,
    required this.aspectRatio,
  });

  @override
  State<InstantDevelopmentScreen> createState() => _InstantDevelopmentScreenState();
}

class _InstantDevelopmentScreenState extends State<InstantDevelopmentScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  bool _isDeveloping = false;
  bool _isFullyDeveloped = false;
  bool _isCollected = false;
  late final String _capturedDate;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _capturedDate = DateTime.now().toString().split(' ')[0];

    _slideAnimation = Tween<double>(begin: -100, end: 180).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Whirrr effect during ejection
    _controller.addListener(() {
      if (_controller.value > 0 && _controller.isAnimating) {
        HapticFeedback.lightImpact(); // Rapid small pulses to simulate motor whirrr
      }
    });

    // Start ejection after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _controller.forward().then((_) {
          setState(() => _isDeveloping = true);
          // Wait for 4 seconds of chemical reaction (same as image opacity duration)
          Future.delayed(const Duration(seconds: 4), () {
            if (mounted) setState(() => _isFullyDeveloped = true);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _collectPhoto() {
    setState(() => _isCollected = true);
    HapticFeedback.mediumImpact();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DevelopScreen(
              imageFile: widget.imageFile,
              initialCamera: widget.camera,
              initialAspectRatio: widget.aspectRatio,
              date: _capturedDate,
              showInstantBorder: true,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow (Refined)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    AppColors.accentGold.withOpacity(0.08),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildRoyalHeader(),
                const Spacer(),
                
                // The Interaction Area
                SizedBox(
                  height: 600,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      // The Photo (sliding out)
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 150 + _slideAnimation.value, // Slides out from the bottom slot
                            child: Hero(tag: 'photo_card', child: child!),
                          );
                        },
                        child: _buildPolaroidPhoto(),
                      ),

                      // The Camera Face
                      _buildCameraBody(),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Action Area
                if (_isDeveloping)
                  FadeInUp(
                    duration: const Duration(seconds: 1),
                    from: 20,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isFullyDeveloped)
                            _buildDevelopingIndicator()
                          else
                            _buildDoneIndicator(),
                          const SizedBox(height: 32),
                          _buildCollectButton(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoneIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: AppColors.accentGold, size: 14),
        const SizedBox(width: 8),
        Text(
          'DEVELOPMENT COMPLETE',
          style: GoogleFonts.spaceMono(
            color: AppColors.accentGold,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRoyalHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 1000),
      child: Column(
        children: [
          Text(
            widget.camera.name,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.accentGold.withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentGold.withOpacity(0.5)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'DEVELOPING CHEMICALS',
          style: GoogleFonts.spaceMono(
            color: AppColors.accentGold.withOpacity(0.7),
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCollectButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _isFullyDeveloped ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: _isFullyDeveloped ? _collectPhoto : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.accentGold,
            borderRadius: BorderRadius.circular(2), // Match the polaroid's sharp edges
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            'COLLECT MEMORY',
            style: GoogleFonts.cinzel(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBody() {
    return Container(
      width: 300,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E4D9),
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF5F3ED),
            const Color(0xFFDED9CD),
          ],
        ),
        boxShadow: [
          // Physical shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 60,
            offset: const Offset(0, 30),
          ),
          // Subtle inner highlight
          const BoxShadow(
            color: Colors.white,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Intricate Rainbow Detail
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  height: 2,
                  color: Colors.white24, // Top specular highlight
                ),
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      _rainbowPart(const Color(0xFFE94B3C)),
                      _rainbowPart(const Color(0xFFF39237)),
                      _rainbowPart(const Color(0xFFFBDB4C)),
                      _rainbowPart(const Color(0xFF5BB259)),
                      _rainbowPart(const Color(0xFF2D8ED6)),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.black12, // Shadow anchor
                ),
              ],
            ),
          ),
          
          // Lens Unit (The Masterpiece)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildCameraComponent(
                      width: 50,
                      height: 70,
                      child: _buildFlashUnit(),
                    ),
                    const SizedBox(width: 15),
                    _buildLensUnit(),
                    const SizedBox(width: 15),
                    _buildCameraComponent(
                      width: 44,
                      height: 44,
                      child: _buildViewfinder(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // The Mechanical Slot (Bottom)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Text(
                  'POLAROID ORIGINALS',
                  style: GoogleFonts.spaceMono(
                    color: Colors.black12,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.white10,
                        offset: Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rainbowPart(Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraComponent({required double width, required double height, required Widget child}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(2, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 0,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  Widget _buildFlashUnit() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemBuilder: (c, i) => Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        itemCount: 12,
      ),
    );
  }

  Widget _buildLensUnit() {
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0F0F0F),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(5, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 0,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFF1F1F1F),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.deepPurple.withOpacity(0.1),
                  Colors.black,
                ],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinder() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white10),
      ),
      child: Center(
        child: Container(
          width: 8,
          height: 8,
          color: Colors.blueGrey.shade900,
        ),
      ),
    );
  }

  Widget _buildPolaroidPhoto() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF5),
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          // Depth shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          // Edging
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: const Color(0xFF121212),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Subtle card texture
                  Opacity(
                    opacity: 0.1,
                    child: Image.network(
                      'https://www.transparenttextures.com/patterns/natural-paper.png',
                      repeat: ImageRepeat.repeat,
                    ),
                  ),
                  // The Developing Photo
                  AnimatedOpacity(
                    duration: const Duration(seconds: 4),
                    opacity: _isDeveloping ? 1.0 : 0.0,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(widget.camera.pipeline.toColorMatrix()),
                      child: Image.file(
                        widget.imageFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Chemical haze overlay
                  if (!_isDeveloping)
                    Container(
                      color: Colors.white.withOpacity(0.05),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36), // Authentic thick polaroid bottom
          Text(
            _capturedDate,
            style: GoogleFonts.permanentMarker(
              color: Colors.black12,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
