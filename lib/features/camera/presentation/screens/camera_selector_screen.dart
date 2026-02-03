import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/camera_model.dart';
import '../../data/repositories/camera_repository.dart';
import '../widgets/camera_card.dart';
import 'package:animate_do/animate_do.dart';

class CameraSelectorScreen extends StatefulWidget {
  final CameraModel currentCamera;
  final Function(CameraModel)? onCameraSelected;

  const CameraSelectorScreen({
    super.key,
    required this.currentCamera,
    this.onCameraSelected,
  });

  @override
  State<CameraSelectorScreen> createState() => _CameraSelectorScreenState();
}

class _CameraSelectorScreenState extends State<CameraSelectorScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  late List<CameraModel> _allCameras;
  late List<CameraModel> _filteredCameras;

  final Set<String> _unlockedCameraIds = {
    'kodak_gold_200', 'fuji_superia_400', 'ilford_hp5',
    'kodak_portra_400', 'kodak_ektar_100', 'cinestill_800t',
    'fuji_pro_400h', 'kodak_colorplus_200', 'kodak_ultramax_400',
    'fuji_c200', 'fuji_velvia_50', 'fuji_provia_100f',
    'lomo_800', 'agfa_vista_200', 'kodak_vision3_500t',
    'kodak_trix_400', 'kodak_tmax_400', 'ilford_delta_3200',
    'fomapan_400', 'rollei_retro_400s', 'lomo_redscale',
    'lomo_purple', 'aerochrome', 'xpro_slide', 'expired_film',
    'polaroid_600', 'polaroid_sx70', 'fuji_instax',
    'holga_plastic', 'diana_f_plus',
  };

  @override
  void initState() {
    super.initState();
    _allCameras = CameraRepository.getAllCameras();
    _filteredCameras = _allCameras;
  }

  void _filterCameras(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'FREE':
          _filteredCameras = CameraRepository.getFreeCameras();
          break;
        case 'PRO':
          _filteredCameras = CameraRepository.getProCameras();
          break;
        case 'COLOR':
          _filteredCameras = CameraRepository.getAllCameras()
              .where((c) => c.type.toLowerCase().contains('color'))
              .toList();
          break;
        case 'B&W':
          _filteredCameras = CameraRepository.getAllCameras()
              .where((c) => c.type.toLowerCase().contains('black'))
              .toList();
          break;
        case 'LIKED':
          _filteredCameras = CameraRepository.getFavoriteCameras();
          break;
        default:
          _filteredCameras = CameraRepository.getAllCameras();
      }
      if (_searchQuery.isNotEmpty) {
        _filteredCameras = _filteredCameras.where((camera) =>
          camera.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          camera.type.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Stack(
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
          bottom: widget.onCameraSelected == null, // Only safe area bottom if not embedded
          child: Column(
            children: [
              _buildRoyalHeader(),
              _buildRoyalSearchBar(),
              _buildRoyalFilterChips(),
              const SizedBox(height: 12),
              Expanded(
                child: _filteredCameras.isEmpty
                    ? _buildEmptyState()
                    : _buildCameraGrid(),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.onCameraSelected != null) {
      return body; // Return only body if embedded
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: body,
    );
  }

  Widget _buildRoyalHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: FadeInDown(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.onCameraSelected == null)
              _glassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 48),
            Text(
              'FILM VAULT',
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
      borderColor: Colors.transparent, // Fix for assertion
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
        borderColor: Colors.transparent, // Fix for assertion
        child: TextField(
          onChanged: (v) {
            setState(() {
              _searchQuery = v;
              _filterCameras(_selectedFilter);
            });
          },
          style: AppTypography.bodyLarge.copyWith(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search collection...',
            hintStyle: AppTypography.bodyLarge.copyWith(color: Colors.white38),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accentGold),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildRoyalFilterChips() {
    final filters = [
      {'label': 'ALL', 'value': 'ALL'},
      {'label': 'FREE', 'value': 'FREE'},
      {'label': 'PRO', 'value': 'PRO'},
      {'label': 'COLOR', 'value': 'COLOR'},
      {'label': 'B&W', 'value': 'B&W'},
      {'label': 'LIKED', 'value': 'LIKED'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 12),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          return GestureDetector(
            onTap: () => _filterCameras(filter['value']!),
            child: GlassContainer(
              height: 42,
              width: index == 0 ? 80 : 100, // Dynamic width for chips
              padding: const EdgeInsets.symmetric(horizontal: 20),
              borderRadius: BorderRadius.circular(25),
              borderColor: Colors.transparent, // Fix for assertion
              gradient: LinearGradient(
                colors: isSelected 
                  ? [AppColors.accentGold.withOpacity(0.3), AppColors.accentGold.withOpacity(0.1)]
                  : [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.01)],
              ),
              borderGradient: LinearGradient(
                colors: isSelected 
                  ? [AppColors.accentGold, AppColors.accentGold.withOpacity(0.2)]
                  : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
              ),
              child: Center(
                child: Text(
                  filter['label']!,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.accentGold : Colors.white60,
                    letterSpacing: 2,
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
          Icon(Icons.camera_roll_outlined, size: 64, color: AppColors.accentGold.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'VAULT IS EMPTY',
            style: AppTypography.displaySmall.copyWith(color: Colors.white24, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      cacheExtent: 500, // Pre-render some items
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false, // Already added in CameraCard
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredCameras.length,
      itemBuilder: (context, index) {
        final camera = _filteredCameras[index];
        final isUnlocked = _unlockedCameraIds.contains(camera.id);
        final isSelected = camera.id == widget.currentCamera.id;

        return FadeIn(
          duration: const Duration(milliseconds: 200),
          child: CameraCard(
            camera: camera,
            isSelected: isSelected,
            isUnlocked: isUnlocked,
            isFavorite: CameraRepository.isFavorite(camera.id),
            onLike: () {
              setState(() {
                CameraRepository.toggleFavorite(camera.id);
                // Refresh list if we are in 'LIKED' mode
                if (_selectedFilter == 'LIKED') {
                  _filteredCameras = CameraRepository.getFavoriteCameras();
                }
              });
            },
            onTap: () {
              if (isUnlocked) {
                if (widget.onCameraSelected != null) {
                  widget.onCameraSelected!(camera);
                } else {
                  Navigator.pop(context, camera);
                }
              }
            },
          ),
        );
      },
    );
  }
}
