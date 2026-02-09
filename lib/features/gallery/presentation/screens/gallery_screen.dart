import 'dart:io';
import 'package:film_cam/app/theme/colors.dart';
import 'package:film_cam/app/theme/theme_colors.dart';
import 'package:film_cam/app/theme/typography.dart';
import 'package:film_cam/core/services/photo_storage_service.dart';
import 'package:film_cam/features/camera/data/repositories/camera_repository.dart';
import 'package:film_cam/features/presets/data/repositories/preset_repository.dart';
import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<PhotoInfo> _photos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final photos = await PhotoStorageService.instance.getAllPhotos();
      if (mounted) {
        setState(() {
          _photos = photos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = context.colors;
    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AdaptiveGlass(
          height: 100,
          width: double.infinity,
          borderRadius: BorderRadius.zero,
          borderWidth: 0,
          borderColor: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.iconPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'GALLERY',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 18,
                    color: tc.accent,
                    letterSpacing: 6,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: tc.iconPrimary, size: 20),
                  onPressed: _loadPhotos,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final tc = context.colors;
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: tc.accent),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: tc.error, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage', style: TextStyle(color: tc.textPrimary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPhotos,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_photos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildPhotoGrid();
  }

  Widget _buildEmptyState() {
    final tc = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_mosaic_outlined,
            size: 80,
            color: tc.accentMuted,
          ),
          const SizedBox(height: 32),
          Text(
            'STORY UNTOLD',
            style: AppTypography.displayMedium.copyWith(
              color: tc.accentSecondary,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your masterpiece collection is empty.',
            style: AppTypography.bodySmall.copyWith(
              color: tc.textMuted,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    final tc = context.colors;
    return RefreshIndicator(
      onRefresh: _loadPhotos,
      color: tc.accent,
      backgroundColor: tc.scaffoldBackground,
      child: GridView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 80,
          left: 2,
          right: 2,
          bottom: 40,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1.0,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          final photo = _photos[index];
          return FadeInUp(
            delay: Duration(milliseconds: index * 50),
            child: _buildPhotoTile(photo),
          );
        },
      ),
    );
  }

  Widget _buildPhotoTile(PhotoInfo photo) {
    final file = File(photo.path);
    final exists = file.existsSync();

    return GestureDetector(
      onTap: () {
        if (exists) {
          _openPhotoViewer(photo);
        }
      },
      onLongPress: () => _showDeleteDialog(photo),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: context.colors.scaffoldBackground,
            child: exists
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    errorBuilder: (_, error, __) {
                      return Center(child: Icon(Icons.broken_image, color: context.colors.textGhost));
                    },
                  )
                : Center(child: Icon(Icons.image_not_supported, color: context.colors.textGhost)),
          ),
          // Info Overlay
          Positioned(
            bottom: 6,
            left: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getPhotoLabel(photo.cameraId),
                style: AppTypography.monoSmall.copyWith(
                  fontSize: 7,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPhotoViewer(PhotoInfo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenViewer(
          photo: photo,
          onDelete: _loadPhotos,
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(PhotoInfo photo) async {
    final tc = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.dialogBackground,
        title: Text('DELETE ARTWORK?', style: AppTypography.labelLarge.copyWith(color: context.colors.textPrimary)),
        content: Text('This will permanently remove the memory.', style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL', style: AppTypography.labelMedium.copyWith(color: context.colors.textTertiary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: AppTypography.labelMedium.copyWith(color: context.colors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PhotoStorageService.instance.deletePhoto(photo.path);
      _loadPhotos();
    }
  }

  String _getPhotoLabel(String id) {
    // First check if it's a camera
    final camera = CameraRepository.getCameraById(id);
    if (camera != null) {
      return camera.name.toUpperCase();
    }
    
    // Then check if it's a preset
    final preset = PresetRepository.getPresetById(id);
    if (preset != null) {
      return preset.name.toUpperCase();
    }
    
    // Fallback
    return 'KODAK';
  }
}

class _FullScreenViewer extends StatelessWidget {
  final PhotoInfo photo;
  final VoidCallback onDelete;

  const _FullScreenViewer({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    // Full screen photo viewer stays dark - industry standard
    final camera = CameraRepository.getCameraById(photo.cameraId);
    final preset = PresetRepository.getPresetById(photo.cameraId);
    final file = File(photo.path);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              camera?.name.toUpperCase() ?? preset?.name.toUpperCase() ?? 'PHOTO',
              style: AppTypography.labelLarge.copyWith(color: Colors.white, fontSize: 14, letterSpacing: 2),
            ),
            Text(
              photo.formattedTime,
              style: AppTypography.monoSmall.copyWith(color: Colors.white54),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: ctx.colors.dialogBackground,
                  title: Text('REMOVE?', style: AppTypography.labelLarge.copyWith(color: ctx.colors.textPrimary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('DELETE', style: TextStyle(color: ctx.colors.error)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await PhotoStorageService.instance.deletePhoto(photo.path);
                onDelete();
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: file.existsSync()
              ? Image.file(file, fit: BoxFit.contain)
              : const Icon(Icons.broken_image, color: Colors.white10, size: 100),
        ),
      ),
    );
  }
}
