import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Premium glowing shutter button with pulse animation
class ShutterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isProcessing;

  const ShutterButton({
    super.key,
    required this.onPressed,
    this.isProcessing = false,
  });

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton>
    with TickerProviderStateMixin {
  AnimationController? _pulseController;
  AnimationController? _pressController;
  Animation<double>? _pulseAnimation;
  Animation<double>? _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Continuous pulse animation for the glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    // Press animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _pressController!,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _pressController?.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.isProcessing) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.isProcessing) return;
    
    setState(() => _isPressed = false);
    HapticFeedback.heavyImpact();
    _pressController?.forward(from: 0);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // Handle case where animations haven't initialized
    if (_pulseAnimation == null || _scaleAnimation == null) {
      return _buildStaticButton();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation!, _scaleAnimation!]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation?.value ?? 1.0,
          child: _buildButtonContent(),
        );
      },
    );
  }

  Widget _buildStaticButton() {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: _buildButtonContent(),
    );
  }

  Widget _buildButtonContent() {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring (Subtle Glow/Reflection)
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
            ),

            // Main Outer Body (Depth)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: -2,
                  ),
                ],
              ),
            ),

            // The Shutter "Plate"
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _isPressed ? 60 : 66,
              height: _isPressed ? 60 : 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Container(
                  width: _isPressed ? 54 : 60,
                  height: _isPressed ? 54 : 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.black.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Processing Indicator
            if (widget.isProcessing)
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
