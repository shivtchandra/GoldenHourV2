import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';

class StudioScreen extends StatelessWidget {
  final bool isEmbedded;

  const StudioScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        // Background Glow
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withOpacity(0.05),
            ),
          ),
        ),
        
        SafeArea(
          bottom: !isEmbedded,
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeInDown(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 80,
                          color: AppColors.accentGold.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        child: Text(
                          'ROYAL STUDIO',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.accentGold,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeIn(
                        delay: const Duration(milliseconds: 500),
                        child: Text(
                          'AI-POWERED FILM ENHANCEMENT',
                          style: AppTypography.monoSmall.copyWith(
                            color: Colors.white38,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: GlassContainer.clearGlass(
                          height: 60,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(30),
                          borderColor: Colors.transparent, // Fix for assertion
                          child: Center(
                            child: Text(
                              'IMPORT NEGATIVE',
                              style: AppTypography.labelLarge.copyWith(
                                color: Colors.white,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coming Soon to Pro Members',
                        style: AppTypography.bodySmall.copyWith(color: Colors.white24),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isEmbedded) return body;

    return Scaffold(
      backgroundColor: Colors.black,
      body: body,
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (isEmbedded) return const SizedBox(height: 60); // Space for top padding

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          GlassContainer.clearGlass(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
            borderColor: Colors.transparent, // Fix for assertion
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
