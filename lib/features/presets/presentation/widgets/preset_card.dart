import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/preset_model.dart';

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
    final tc = context.colors;
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
                  color: tc.cardSurface.withAlpha(200),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      preset.category.accentColor.withAlpha(tc.isDark ? 60 : 40),
                      preset.category.accentColor.withAlpha(tc.isDark ? 20 : 10),
                      tc.isDark ? Colors.black.withAlpha(200) : tc.cardSurface,
                    ],
                  ),
                  border: Border.all(
                    color: isSelected
                        ? preset.category.accentColor.withAlpha(180)
                        : tc.isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(15),
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
                            color: tc.overlayDark,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFavorite ? tc.favorite : tc.iconMuted,
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
                              color: tc.textPrimary,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withAlpha(tc.isDark ? 100 : 30),
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
                              color: tc.isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: tc.isDark ? Colors.white.withAlpha(30) : Colors.black.withAlpha(15),
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
    // PRO badge stays gold in both themes
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
      return Builder(
        builder: (context) {
          final tc = context.colors;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: tc.glassBackground,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: tc.borderMuted),
            ),
            child: Text(
              'FREE',
              style: AppTypography.labelLarge.copyWith(
                fontSize: 10,
                color: tc.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          );
        },
      );
    }
  }
}
