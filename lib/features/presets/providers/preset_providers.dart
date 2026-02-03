import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/preset_model.dart';
import '../data/repositories/preset_repository.dart';

/// Provider for all presets
final allPresetsProvider = Provider<List<PresetModel>>((ref) {
  return PresetRepository.getAllPresets();
});

/// Provider for the currently selected preset (for editing)
final selectedPresetProvider = StateProvider<PresetModel?>((ref) => null);

/// Provider for preset category filter
final presetCategoryFilterProvider = StateProvider<PresetCategory?>((ref) => null);

/// Provider for preset search query
final presetSearchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for filtered presets based on category and search
final filteredPresetsProvider = Provider<List<PresetModel>>((ref) {
  final allPresets = ref.watch(allPresetsProvider);
  final category = ref.watch(presetCategoryFilterProvider);
  final searchQuery = ref.watch(presetSearchQueryProvider);

  var filtered = allPresets;

  // Filter by category
  if (category != null) {
    filtered = filtered.where((p) => p.category == category).toList();
  }

  // Filter by search query
  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered = filtered.where((p) =>
      p.name.toLowerCase().contains(query) ||
      p.description.toLowerCase().contains(query)
    ).toList();
  }

  return filtered;
});

/// State notifier for managing favorite preset IDs
class FavoritePresetsNotifier extends StateNotifier<Set<String>> {
  FavoritePresetsNotifier() : super({});

  void toggle(String presetId) {
    if (state.contains(presetId)) {
      state = {...state}..remove(presetId);
      PresetRepository.toggleFavorite(presetId);
    } else {
      state = {...state, presetId};
      PresetRepository.toggleFavorite(presetId);
    }
  }

  bool isFavorite(String presetId) => state.contains(presetId);
}

/// Provider for favorite presets
final favoritePresetIdsProvider = StateNotifierProvider<FavoritePresetsNotifier, Set<String>>((ref) {
  return FavoritePresetsNotifier();
});

/// Provider for favorite preset models
final favoritePresetsProvider = Provider<List<PresetModel>>((ref) {
  final favoriteIds = ref.watch(favoritePresetIdsProvider);
  final allPresets = ref.watch(allPresetsProvider);
  return allPresets.where((p) => favoriteIds.contains(p.id)).toList();
});

/// Provider for presets by category
final presetsByCategoryProvider = Provider.family<List<PresetModel>, PresetCategory>((ref, category) {
  return PresetRepository.getPresetsByCategory(category);
});
