import 'dart:io';
import 'package:film_cam/app/theme/colors.dart';
import 'package:film_cam/app/theme/typography.dart';
import 'package:film_cam/core/services/photo_storage_service.dart';
import 'package:film_cam/features/camera/data/repositories/camera_repository.dart';
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
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: GlassContainer.clearGlass(
          height: 100,
          width: double.infinity,
          borderRadius: BorderRadius.zero,
          borderWidth: 0,
          borderColor: Colors.transparent, // Fix for assertion
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'GALLERY',
                  style: AppTypography.displayMedium.copyWith(
                    fontSize: 18,
                    color: AppColors.accentGold,
                    letterSpacing: 6,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $_errorMessage', style: const TextStyle(color: Colors.white)),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_mosaic_outlined,
            size: 80,
            color: AppColors.accentGold.withOpacity(0.2),
          ),
          const SizedBox(height: 32),
          Text(
            'STORY UNTOLD',
            style: AppTypography.displayMedium.copyWith(
              color: AppColors.accentGold.withOpacity(0.6),
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your masterpiece collection is empty.',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white30,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return RefreshIndicator(
      onRefresh: _loadPhotos,
      color: AppColors.accentGold,
      backgroundColor: Colors.black,
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
      child: Container(
        color: Colors.black,
        child: exists
            ? Image.file(
                file,
                fit: BoxFit.cover,
                cacheWidth: 400,
                errorBuilder: (_, error, __) {
                  return const Center(child: Icon(Icons.broken_image, color: Colors.white10));
                },
              )
            : const Center(child: Icon(Icons.image_not_supported, color: Colors.white10)),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('DELETE ARTWORK?', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
        content: Text('This will permanently remove the memory.', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('CANCEL', style: AppTypography.labelMedium.copyWith(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('DELETE', style: AppTypography.labelMedium.copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PhotoStorageService.instance.deletePhoto(photo.path);
      _loadPhotos();
    }
  }
}

class _FullScreenViewer extends StatelessWidget {
  final PhotoInfo photo;
  final VoidCallback onDelete;

  const _FullScreenViewer({required this.photo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final camera = CameraRepository.getCameraById(photo.cameraId);
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
              camera?.name.toUpperCase() ?? 'PHOTO',
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
                  backgroundColor: Colors.grey.shade900,
                  title: Text('REMOVE?', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
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
