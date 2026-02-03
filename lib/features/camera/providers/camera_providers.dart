import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/camera_model.dart';
import '../data/repositories/camera_repository.dart';

/// Provider for all available cameras
final allCamerasProvider = Provider<List<CameraModel>>((ref) {
  return CameraRepository.getAllCameras();
});

/// Provider for free cameras only
final freeCamerasProvider = Provider<List<CameraModel>>((ref) {
  return CameraRepository.getFreeCameras();
});

/// Provider for PRO cameras only
final proCamerasProvider = Provider<List<CameraModel>>((ref) {
  return CameraRepository.getProCameras();
});

/// Provider for the currently selected camera
final selectedCameraProvider = StateNotifierProvider<SelectedCameraNotifier, CameraModel>((ref) {
  return SelectedCameraNotifier();
});

class SelectedCameraNotifier extends StateNotifier<CameraModel> {
  SelectedCameraNotifier() : super(CameraRepository.getFreeCameras().first);

  void selectCamera(CameraModel camera) {
    state = camera;
  }

  void selectCameraById(String id) {
    final camera = CameraRepository.getCameraById(id);
    if (camera != null) {
      state = camera;
    }
  }
}

/// Provider for unlocked camera IDs
final unlockedCamerasProvider = StateNotifierProvider<UnlockedCamerasNotifier, Set<String>>((ref) {
  return UnlockedCamerasNotifier();
});

class UnlockedCamerasNotifier extends StateNotifier<Set<String>> {
  UnlockedCamerasNotifier() : super({
    // Free cameras are always unlocked
    'kodak_gold_200',
    'fuji_superia_400',
    'ilford_hp5',
  });

  void unlockCamera(String id) {
    state = {...state, id};
  }

  void unlockAll() {
    state = CameraRepository.getAllCameras().map((c) => c.id).toSet();
  }

  bool isUnlocked(String id) {
    return state.contains(id);
  }
}

/// Provider for camera search query
final cameraSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for selected filter category
final selectedCategoryProvider = StateProvider<CameraCategory>((ref) => CameraCategory.all);

/// Provider for filtered cameras based on search and category
final filteredCamerasProvider = Provider<List<CameraModel>>((ref) {
  final allCameras = ref.watch(allCamerasProvider);
  final query = ref.watch(cameraSearchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);

  return allCameras.where((camera) {
    // Category filter
    bool matchesCategory = true;
    switch (category) {
      case CameraCategory.all:
        matchesCategory = true;
        break;
      case CameraCategory.free:
        matchesCategory = !camera.isPro;
        break;
      case CameraCategory.pro:
        matchesCategory = camera.isPro;
        break;
      case CameraCategory.color:
        matchesCategory = camera.type.toLowerCase().contains('color') &&
            !camera.type.toLowerCase().contains('black');
        break;
      case CameraCategory.blackAndWhite:
        matchesCategory = camera.type.toLowerCase().contains('black');
        break;
      case CameraCategory.instant:
        matchesCategory = camera.type.toLowerCase().contains('instant');
        break;
      case CameraCategory.special:
        matchesCategory = camera.type.toLowerCase().contains('redscale') ||
            camera.type.toLowerCase().contains('infrared') ||
            camera.type.toLowerCase().contains('cross') ||
            camera.type.toLowerCase().contains('expired') ||
            camera.type.toLowerCase().contains('color shift');
        break;
      case CameraCategory.toy:
        matchesCategory = camera.type.toLowerCase().contains('toy');
        break;
    }

    // Search filter
    bool matchesSearch = query.isEmpty ||
        camera.name.toLowerCase().contains(query.toLowerCase()) ||
        camera.type.toLowerCase().contains(query.toLowerCase()) ||
        camera.personality.toLowerCase().contains(query.toLowerCase());

    return matchesCategory && matchesSearch;
  }).toList();
});

/// Provider for frame counter
final frameCounterProvider = StateProvider<int>((ref) => 24);

/// Provider for processing state
final isProcessingProvider = StateProvider<bool>((ref) => false);

/// Provider for recently used cameras
final recentlyUsedCamerasProvider = StateNotifierProvider<RecentlyUsedCamerasNotifier, List<String>>((ref) {
  return RecentlyUsedCamerasNotifier();
});

class RecentlyUsedCamerasNotifier extends StateNotifier<List<String>> {
  RecentlyUsedCamerasNotifier() : super([]);

  void addCamera(String id) {
    // Remove if already exists
    final updated = state.where((c) => c != id).toList();
    // Add to front
    updated.insert(0, id);
    // Keep only last 4
    state = updated.take(4).toList();
  }
}
