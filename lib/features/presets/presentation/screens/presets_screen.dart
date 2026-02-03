import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/preset_model.dart';
import '../../data/repositories/preset_repository.dart';
import '../widgets/preset_card.dart';

class PresetsScreen extends StatefulWidget {
  final Function(PresetModel)? onPresetSelected;

  const PresetsScreen({
    super.key,
    this.onPresetSelected,
  });

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  Object? _selectedCategory; // Can be PresetCategory or String (_likedMarker)

  String _searchQuery = '';
  late List<PresetModel> _allPresets;
  late List<PresetModel> _filteredPresets;

  @override
  void initState() {
    super.initState();
    _allPresets = PresetRepository.getAllPresets();
    _filteredPresets = _allPresets;
  }

  void _filterPresets() {
    setState(() {
      if (_selectedCategory == null) {
        // Handle "ALL" or query-only filter
        _filteredPresets = _allPresets;
      } else if (_selectedCategory == _likedMarker) {
        _filteredPresets = PresetRepository.getFavoritePresets();
      } else if (_selectedCategory is PresetCategory) {
        _filteredPresets = PresetRepository.getPresetsByCategory(_selectedCategory as PresetCategory);
      }

      // Filter by search query

      if (_searchQuery.isNotEmpty) {
        _filteredPresets = _filteredPresets.where((p) =>
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
    });
  }

  // Placeholder value for "LIKED" filter in the local categories list
  static const _likedMarker = "LIKED_MARKER";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentGold.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            bottom: widget.onPresetSelected == null,
            child: Column(
              children: [
                _buildRoyalHeader(),
                _buildRoyalSearchBar(),
                _buildRoyalFilterChips(),
                const SizedBox(height: 12),
                Expanded(
                  child: _filteredPresets.isEmpty
                      ? _buildEmptyState()
                      : _buildRoyalPresetGrid(),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildRoyalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: FadeInDown(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.onPresetSelected == null)
              _glassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 48),
            Text(
              'PRESET VAULT',
              style: AppTypography.displayMedium.copyWith(
                fontSize: 18,
                letterSpacing: 4,
                color: AppColors.accentGold,
              ),
            ),
            _glassIconButton(
              icon: Icons.tune_rounded,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, required VoidCallback onPressed}) {
    return GlassContainer.clearGlass(
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(24),
      borderColor: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }


  Widget _buildRoyalSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassContainer.clearGlass(
        height: 56,
        width: double.infinity,
        borderRadius: BorderRadius.circular(28),
        borderColor: Colors.transparent,
        child: TextField(
          onChanged: (v) {
            _searchQuery = v;
            _filterPresets();
          },
          style: AppTypography.bodyLarge.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search presets...',
            hintStyle: AppTypography.bodyLarge.copyWith(color: Colors.white38),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentGold),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }


  // _likedMarker moved up

  Widget _buildRoyalFilterChips() {
    final categories = [
      {'label': 'ALL', 'value': null},
      {'label': 'LIKED', 'value': _likedMarker},
      {'label': 'FILM', 'value': PresetCategory.film},
      {'label': 'CINEMATIC', 'value': PresetCategory.cinematic},
      {'label': 'MOODY', 'value': PresetCategory.moody},
      {'label': 'BRIGHT', 'value': PresetCategory.brightAiry},
      {'label': 'VINTAGE', 'value': PresetCategory.vintageRetro},
      {'label': 'SHUTTER', 'value': PresetCategory.shutterSpeed},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['value'];

          final accentColor = (category['value'] is PresetCategory)
              ? (category['value'] as PresetCategory).accentColor
              : AppColors.accentGold;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['value'];
                _filterPresets();
              });
            },

            child: GlassContainer(
              height: 42,
              width: index == 0 ? 80 : 100, // Dynamic width for chips
              padding: const EdgeInsets.symmetric(horizontal: 20),
              borderRadius: BorderRadius.circular(25),
              borderColor: Colors.transparent,
              gradient: LinearGradient(
                colors: isSelected 
                  ? [accentColor.withOpacity(0.3), accentColor.withOpacity(0.1)]
                  : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01)],
              ),
              borderGradient: LinearGradient(
                colors: isSelected 
                  ? [accentColor, accentColor.withOpacity(0.2)]
                  : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
              ),
              child: Center(
                child: Text(
                  category['label'] as String,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? accentColor : Colors.white60,
                    letterSpacing: 2,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.palette_outlined,
            size: 64,
            color: AppColors.accentGold.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'NO PRESETS FOUND',
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white24,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoyalPresetGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      cacheExtent: 500, // Pre-render some items
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false, // Already added in PresetCard
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72, // Matched with CameraSelector
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredPresets.length,
      itemBuilder: (context, index) {
        final preset = _filteredPresets[index];
        final isFavorite = PresetRepository.isFavorite(preset.id);

        return FadeIn(
          duration: const Duration(milliseconds: 200),
          child: PresetCard(
            preset: preset,
            isSelected: false,
            isFavorite: isFavorite,
            onTap: () {
              if (widget.onPresetSelected != null) {
                widget.onPresetSelected!(preset);
              } else {
                // Navigate to develop screen with this preset
                Navigator.pushNamed(
                  context,
                  '/develop',
                  arguments: preset,
                );
              }
            },
            onFavorite: () {
              setState(() {
                PresetRepository.toggleFavorite(preset.id);
                // Refresh list if we are in 'LIKED' mode
                if (_selectedCategory == _likedMarker) {
                  _filteredPresets = PresetRepository.getFavoritePresets();
                }
              });
            },

          ),
        );
      },
    );
  }

}
