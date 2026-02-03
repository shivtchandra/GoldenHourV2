import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/camera_model.dart';
import '../../data/models/pipeline_config.dart';

/// Premium glassmorphic camera selection card
class CameraCard extends StatelessWidget {
  final CameraModel camera;
  final bool isSelected;
  final bool isUnlocked;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onLike;

  const CameraCard({
    super.key,
    required this.camera,
    this.isSelected = false,
    this.isUnlocked = true,
    this.isFavorite = false,
    required this.onTap,
    this.onLike,
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
                    color: camera.iconColor.withAlpha(80),
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
                    colors: isUnlocked
                        ? [
                            camera.iconColor.withAlpha(60),
                            camera.iconColor.withAlpha(20),
                            Colors.black.withAlpha(200),
                          ]
                        : [
                            Colors.white.withAlpha(10),
                            Colors.black.withAlpha(150),
                          ],
                  ),
                  border: Border.all(
                    color: isSelected
                        ? camera.iconColor.withAlpha(180)
                        : Colors.white.withAlpha(30),
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Stack(
                  children: [
                    // Visual Preview Background - Using a more efficient approach
                    Positioned.fill(
                      child: isUnlocked 
                        ? Opacity(
                            opacity: 0.4,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.matrix(camera.pipeline.toColorMatrix()),
                              child: const Icon(
                                Icons.camera_roll_rounded, 
                                size: 100, 
                                color: Colors.white10
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    ),

                    // Like Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onLike,
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
                          // Camera Icon with glow
                          Expanded(
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Glow behind icon
                                  if (isUnlocked)
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: camera.iconColor.withAlpha(80),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  // Camera icon
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: isUnlocked
                                            ? [
                                                camera.iconColor.withAlpha(180),
                                                camera.iconColor.withAlpha(100),
                                              ]
                                            : [
                                                Colors.grey.shade600,
                                                Colors.grey.shade700,
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
                                      Icons.camera_alt_rounded,
                                      size: 36,
                                      color: Colors.white.withAlpha(230),
                                    ),
                                  ),
                                  // Lock overlay
                                  if (!isUnlocked)
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withAlpha(120),
                                      ),
                                      child: const Icon(
                                        Icons.lock_rounded,
                                        color: Colors.white70,
                                        size: 28,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Camera Name
                          Text(
                            camera.name,
                            style: AppTypography.headlineMedium.copyWith(
                              fontSize: 14,
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

                          // ISO Badge with glass effect
                          if (camera.iso != null)
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
                                'ISO ${camera.iso}',
                                style: AppTypography.monoMedium.copyWith(
                                  fontSize: 11,
                                  color: Colors.white.withAlpha(220),
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

  Widget _buildBadge() {
    if (camera.isPro) {
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
