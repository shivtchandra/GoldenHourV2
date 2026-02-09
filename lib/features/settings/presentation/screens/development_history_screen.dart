import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../../../core/services/photo_storage_service.dart';
import '../../../camera/data/repositories/camera_repository.dart';

class DevelopmentHistoryScreen extends StatefulWidget {
  const DevelopmentHistoryScreen({super.key});

  @override
  State<DevelopmentHistoryScreen> createState() => _DevelopmentHistoryScreenState();
}

class _DevelopmentHistoryScreenState extends State<DevelopmentHistoryScreen> {
  List<PhotoInfo> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final photos = await PhotoStorageService.instance.getAllPhotos();
    if (mounted) {
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      body: Stack(
        children: [
          _buildBackgroundGlow(context),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: tc.accent))
                      : _photos.isEmpty
                          ? _buildEmptyState(context)
                          : _buildHistoryList(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.accentSubtle,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final tc = context.colors;
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
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.iconPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'DEVELOPMENT LOG',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 18,
                  letterSpacing: 4,
                  color: tc.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final tc = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: tc.textGhost),
          const SizedBox(height: 16),
          Text(
            'NO HISTORY RECORDED',
            style: AppTypography.displaySmall.copyWith(color: tc.textFaint, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final tc = context.colors;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        final photo = _photos[index];
        final camera = CameraRepository.getCameraById(photo.cameraId);

        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: index * 50),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AdaptiveGlass(
              height: 100,
              width: double.infinity,
              borderRadius: BorderRadius.circular(20),
              borderColor: tc.borderSubtle,
              child: Row(
                children: [
                  // Photo Thumbnail
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(photo.path), fit: BoxFit.cover),
                    ),
                  ),

                  // Metadata
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            camera?.name.toUpperCase() ?? 'UNKNOWN FILM',
                            style: AppTypography.labelLarge.copyWith(color: tc.accent, fontSize: 13, letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            photo.formattedTime.toUpperCase(),
                            style: AppTypography.monoSmall.copyWith(color: tc.textTertiary, fontSize: 10),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, color: tc.success.withOpacity(0.6), size: 14),
                              const SizedBox(width: 4),
                              Text('DEVELOPED', style: AppTypography.labelMedium.copyWith(color: tc.textMuted, fontSize: 9, letterSpacing: 1)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
