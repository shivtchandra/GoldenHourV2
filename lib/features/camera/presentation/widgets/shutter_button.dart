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
    final pulseValue = _pulseAnimation?.value ?? 0.75;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: SizedBox(
        width: 90,
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withAlpha((100 * pulseValue).toInt()),
                    blurRadius: 25,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            // Outer ring
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.red.shade400,
                    Colors.red.shade700,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),

            // Middle ring (metallic)
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade100,
                    Colors.grey.shade300,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Inner button
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _isPressed ? 52 : 58,
              height: _isPressed ? 52 : 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  radius: 0.8,
                  colors: [
                    Colors.white,
                    Colors.grey.shade100,
                  ],
                ),
                boxShadow: _isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(40),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
            ),

            // Processing indicator
            if (widget.isProcessing)
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(Colors.red.shade600),
                ),
              ),

            // Center dot
            if (!widget.isProcessing)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade600,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade600.withAlpha(100),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
