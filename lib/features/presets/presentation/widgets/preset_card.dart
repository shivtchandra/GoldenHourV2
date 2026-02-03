import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/preset_model.dart';
import '../../../camera/data/models/pipeline_config.dart';

/// Premium glassmorphic preset selection card
class PresetCard extends StatelessWidget {
  final PresetModel preset;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;

  const PresetCard({
    super.key,
    required this.preset,
    this.isSelected = false,
    this.isFavorite = false,
    required this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: isSelected 
              ? (Matrix4.identity()..scale(1.02))
              : Matrix4.identity(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: preset.category.accentColor.withAlpha(80),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[900]?.withAlpha(200),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      preset.category.accentColor.withAlpha(60),
                      preset.category.accentColor.withAlpha(20),
                      Colors.black.withAlpha(200),
                    ],
                  ),
                  border: Border.all(
                    color: isSelected
                        ? preset.category.accentColor.withAlpha(180)
                        : Colors.white.withAlpha(30),
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Stack(
                  children: [
                    // Visual Preview Background
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.4,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.matrix(preset.pipeline.toColorMatrix()),
                          child: Icon(
                            _getCategoryIcon(),
                            size: 100,
                            color: Colors.white10,
                          ),
                        ),
                      ),
                    ),

                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? Colors.redAccent : Colors.white.withOpacity(0.6),
                            size: 16,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category icon with glow
                          Expanded(
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow behind icon
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: preset.category.accentColor.withAlpha(80),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Preset icon
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          preset.category.accentColor.withAlpha(180),
                                          preset.category.accentColor.withAlpha(100),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(50),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(),
                                      size: 28,
                                      color: Colors.white.withAlpha(230),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Preset Name
                          Text(
                            preset.name,
                            style: AppTypography.headlineMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withAlpha(30),
                              ),
                            ),
                            child: Text(
                              preset.category.displayName,
                              style: AppTypography.monoMedium.copyWith(
                                fontSize: 9,
                                color: preset.category.accentColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Pro/Free Badge
                          _buildBadge(),
                        ],
                      ),
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

  IconData _getCategoryIcon() {
    switch (preset.category) {
      case PresetCategory.cinematic:
        return Icons.movie_rounded;
      case PresetCategory.moody:
        return Icons.cloud_rounded;
      case PresetCategory.brightAiry:
        return Icons.wb_sunny_rounded;
      case PresetCategory.vintageRetro:
        return Icons.auto_awesome_rounded;
      case PresetCategory.shutterSpeed:
        return Icons.shutter_speed_rounded;
      case PresetCategory.film:
        return Icons.camera_roll_rounded;
    }
  }

  Widget _buildBadge() {
    if (preset.isPro) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentGold,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGold.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 10, color: Colors.black),
            const SizedBox(width: 4),
            Text(
              'PRO',
              style: AppTypography.labelLarge.copyWith(
                fontSize: 10,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          'FREE',
          style: AppTypography.labelLarge.copyWith(
            fontSize: 10,
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
    }
  }
}
