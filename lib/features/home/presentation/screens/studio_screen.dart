import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';

class StudioScreen extends StatelessWidget {
  final bool isEmbedded;

  const StudioScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
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
              color: tc.accentSubtle,
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
                          color: tc.accentMuted,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInUp(
                        child: Text(
                          'ROYAL STUDIO',
                          style: AppTypography.displayMedium.copyWith(
                            color: tc.accent,
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
                            color: tc.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: AdaptiveGlass(
                          height: 60,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(30),
                          borderColor: Colors.transparent,
                          child: Center(
                            child: Text(
                              'IMPORT NEGATIVE',
                              style: AppTypography.labelLarge.copyWith(
                                color: tc.textPrimary,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coming Soon to Pro Members',
                        style: AppTypography.bodySmall.copyWith(color: tc.textFaint),
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
      backgroundColor: tc.scaffoldBackground,
      body: body,
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (isEmbedded) return const SizedBox(height: 60);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          AdaptiveGlass(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.circular(24),
            borderColor: Colors.transparent,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.iconPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
