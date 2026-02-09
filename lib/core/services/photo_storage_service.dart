import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;
import 'image_processing_service.dart';
import '../../features/camera/data/models/pipeline_config.dart';
import '../../features/camera/data/repositories/camera_repository.dart';

/// Service to save and manage captured photos with film effects applied
class PhotoStorageService {
  PhotoStorageService._();
  static final PhotoStorageService _instance = PhotoStorageService._();
  static PhotoStorageService get instance => _instance;

  final _photosChangedController = StreamController<void>.broadcast();
  Stream<void> get photosChanged => _photosChangedController.stream;

  final Uuid _uuid = const Uuid();
  final ImageProcessingService _processingService = ImageProcessingService();

  /// Get the photos directory
  Future<Directory> get _photosDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/goldenhour_photos');
    
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    
    return photosDir;
  }

  /// Save a photo with film effects applied
  Future<String?> savePhoto({
    required String sourcePath,
    required String cameraName,
    required String cameraId,
  }) async {
    try {
      debugPrint('PhotoStorage: Starting save for $cameraId');
      
      final photosDir = await _photosDir;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final photoId = _uuid.v4().substring(0, 8);
      
      // Get camera pipeline config
      final camera = CameraRepository.getCameraById(cameraId);
      final pipeline = camera?.pipeline ?? PipelineConfig.defaultConfig();
      
      debugPrint('PhotoStorage: Applying film effect "${camera?.name ?? cameraId}"');
      
      // Read source image
      final sourceFile = File(sourcePath);
      final imageBytes = await sourceFile.readAsBytes();
      
      // Decode image
      img.Image? inputImage = img.decodeImage(imageBytes);
      if (inputImage == null) {
        debugPrint('PhotoStorage: Failed to decode image');
        return null;
      }
      
      debugPrint('PhotoStorage: Image decoded ${inputImage.width}x${inputImage.height}');
      
      // No longer resizing - keep full resolution for maximum quality
      
      // Apply film effect using the processing service
      debugPrint('PhotoStorage: Applying effects...');
      final processedImage = await _processingService.applyFilmEffect(
        inputImage: inputImage,
        pipeline: pipeline,
      );
      debugPrint('PhotoStorage: Effects applied');
      
      // Encode to JPEG
      final processedBytes = img.encodeJpg(processedImage, quality: 92);
      
      // Save processed image
      final filename = 'photo__${timestamp}__${cameraId}__$photoId.jpg';
      final destinationPath = '${photosDir.path}/$filename';
      
      final destFile = File(destinationPath);
      await destFile.writeAsBytes(processedBytes);
      
      debugPrint('PhotoStorage: Saved processed photo to $destinationPath');
      
      _photosChangedController.add(null);
      
      return destinationPath;
    } catch (e, stack) {
      debugPrint('PhotoStorage: Error saving photo: $e');
      debugPrint('PhotoStorage: Stack: $stack');
      return null;
    }
  }

  /// Save a photo that has already been processed (e.g., from DevelopScreen)
  Future<String?> saveProcessedPhoto({
    required Uint8List bytes,
    required String cameraId,
  }) async {
    try {
      final photosDir = await _photosDir;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final photoId = _uuid.v4().substring(0, 8);
      
      final filename = 'photo__${timestamp}__${cameraId}__$photoId.jpg';
      final destinationPath = '${photosDir.path}/$filename';
      
      final destFile = File(destinationPath);
      await destFile.writeAsBytes(bytes);
      
      debugPrint('PhotoStorage: Saved pre-processed photo to $destinationPath');
      _photosChangedController.add(null);
      return destinationPath;
    } catch (e) {
      debugPrint('PhotoStorage: Error saving processed photo: $e');
      return null;
    }
  }

  /// Get all saved photos
  Future<List<PhotoInfo>> getAllPhotos() async {
    try {
      final photosDir = await _photosDir;
      
      if (!await photosDir.exists()) {
        return [];
      }
      
      final entities = await photosDir.list().toList();
      final files = entities.whereType<File>().toList();
      
      // Sort by modification time (newest first)
      files.sort((a, b) {
        try {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified);
        } catch (e) {
          return 0;
        }
      });
      
      final photos = <PhotoInfo>[];
      
      for (final file in files) {
        final filename = file.path.split('/').last;
        
        // Parse filename: photo__TIMESTAMP__CAMERAID__UUID.ext
        String cameraId = 'kodak_gold_200';
        DateTime timestamp = file.statSync().modified;
        
        if (filename.startsWith('photo__')) {
          final parts = filename.replaceAll('photo__', '').split('__');
          if (parts.length >= 3) {
            final timestampMs = int.tryParse(parts[0]);
            if (timestampMs != null) {
              timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
            }
            cameraId = parts[1];
          }
        } else if (filename.startsWith('filmcam_') || filename.startsWith('goldenhour_')) {
          // Legacy/Alternate format
          final parts = filename.contains('filmcam_') 
              ? filename.replaceAll('filmcam_', '').split('_')
              : filename.replaceAll('goldenhour_', '').split('_');
          if (parts.length >= 3) {
            for (int i = 0; i < parts.length; i++) {
              final maybeTimestamp = int.tryParse(parts[i]);
              if (maybeTimestamp != null && maybeTimestamp > 1700000000000) {
                cameraId = parts.sublist(0, i).join('_');
                timestamp = DateTime.fromMillisecondsSinceEpoch(maybeTimestamp);
                break;
              }
            }
          }
        }
        
        photos.add(PhotoInfo(
          id: filename,
          path: file.path,
          cameraId: cameraId,
          timestamp: timestamp,
        ));
      }
      
      debugPrint('PhotoStorage: Found ${photos.length} photos');
      return photos;
    } catch (e) {
      debugPrint('PhotoStorage: Error getting photos: $e');
      return [];
    }
  }

  /// Delete a photo
  Future<bool> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('PhotoStorage: Deleted $path');
        _photosChangedController.add(null);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('PhotoStorage: Error deleting photo: $e');
      return false;
    }
  }

  /// Get photo count
  Future<int> getPhotoCount() async {
    final photos = await getAllPhotos();
    return photos.length;
  }
}

/// Photo metadata
class PhotoInfo {
  final String id;
  final String path;
  final String cameraId;
  final DateTime timestamp;

  const PhotoInfo({
    required this.id,
    required this.path,
    required this.cameraId,
    required this.timestamp,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
