import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/theme_colors.dart';
import '../../../../app/theme/typography.dart';
import '../../data/models/camera_model.dart';
import '../../data/repositories/camera_repository.dart';
import '../widgets/camera_card.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../../settings/providers/user_provider.dart';
import '../../../settings/presentation/screens/profile_screen.dart';

class CameraSelectorScreen extends ConsumerStatefulWidget {
  final CameraModel currentCamera;
  final Function(CameraModel)? onCameraSelected;

  const CameraSelectorScreen({
    super.key,
    required this.currentCamera,
    this.onCameraSelected,
  });

  @override
  ConsumerState<CameraSelectorScreen> createState() => _CameraSelectorScreenState();
}

class _CameraSelectorScreenState extends ConsumerState<CameraSelectorScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  late List<CameraModel> _allCameras;
  late List<CameraModel> _filteredCameras;

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
    final tc = context.colors;
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
              color: tc.accentSubtle,
            ),
          ),
        ),

        SafeArea(
          bottom: widget.onCameraSelected == null,
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
      return body;
    }

    return Scaffold(
      backgroundColor: tc.scaffoldBackground,
      body: body,
    );
  }

  Widget _buildRoyalHeader() {
    final tc = context.colors;
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
                color: tc.accent,
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
    return AdaptiveGlass(
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(24),
      borderColor: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, color: context.colors.iconPrimary, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildRoyalSearchBar() {
    final tc = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: AdaptiveGlass(
        height: 56,
        width: double.infinity,
        borderRadius: BorderRadius.circular(28),
        borderColor: Colors.transparent,
        child: TextField(
          onChanged: (v) {
            setState(() {
              _searchQuery = v;
              _filterCameras(_selectedFilter);
            });
          },
          style: AppTypography.bodyLarge.copyWith(color: tc.textPrimary),
          decoration: InputDecoration(
            hintText: 'Search collection...',
            hintStyle: AppTypography.bodyLarge.copyWith(color: tc.textMuted),
            prefixIcon: Icon(Icons.search_rounded, color: tc.accent),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildRoyalFilterChips() {
    final tc = context.colors;
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
              width: index == 0 ? 80 : 100,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              borderRadius: BorderRadius.circular(25),
              borderColor: Colors.transparent,
              gradient: LinearGradient(
                colors: isSelected
                  ? [tc.accent.withOpacity(0.3), tc.accent.withOpacity(0.1)]
                  : [tc.glassBackground, tc.glassBackground.withOpacity(0.01)],
              ),
              borderGradient: LinearGradient(
                colors: isSelected
                  ? [tc.accent, tc.accent.withOpacity(0.2)]
                  : [tc.glassBorder, tc.glassBorder.withOpacity(0.5)],
              ),
              child: Center(
                child: Text(
                  filter['label']!,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? tc.accent : tc.iconMuted,
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
    final tc = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_roll_outlined, size: 64, color: tc.accentSubtle),
          const SizedBox(height: 16),
          Text(
            'VAULT IS EMPTY',
            style: AppTypography.displaySmall.copyWith(color: tc.textFaint, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraGrid() {
    final user = ref.watch(userProfileProvider);

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
        final isUnlocked = !camera.isPro || user.isPro;
        final isSelected = camera.id == widget.currentCamera.id;

        return FadeIn(
          duration: const Duration(milliseconds: 200),
          child: CameraCard(
            camera: camera,
            isSelected: isSelected,
            isUnlocked: isUnlocked,
            isFavorite: CameraRepository.isFavorite(camera.id),
            onLike: () async {
              await CameraRepository.toggleFavorite(camera.id);
              if (mounted) {
                setState(() {
                  // Refresh list if we are in 'LIKED' mode
                  if (_selectedFilter == 'LIKED') {
                    _filteredCameras = CameraRepository.getFavoriteCameras();
                  }
                });
              }
            },
            onTap: () {
              if (isUnlocked) {
                if (widget.onCameraSelected != null) {
                  widget.onCameraSelected!(camera);
                } else {
                  Navigator.pop(context, camera);
                }
              } else {
                _showUpgradeDialog(context);
              }
            },
          ),
        );
      },
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.scaffoldBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('ROYAL UPGRADE REQUIRED', 
          style: AppTypography.displaySmall.copyWith(fontSize: 18, color: context.colors.accent, letterSpacing: 2)),
        content: Text('Unlock the full creative vault with a Royal Membership. Access all 30 premium film stocks, unlimited captures, and high-res development.',
          style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('LATER', style: AppTypography.monoMedium.copyWith(color: context.colors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('UPGRADE NOW', style: AppTypography.monoMedium.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
