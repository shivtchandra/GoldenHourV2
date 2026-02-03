import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/colors.dart';
import '../../../../app/theme/typography.dart';
import 'package:film_cam/features/camera/providers/settings_provider.dart';
import 'package:film_cam/features/camera/data/repositories/camera_repository.dart';
import 'package:film_cam/features/settings/providers/user_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final bool isEmbedded;
  const SettingsScreen({super.key, this.isEmbedded = false});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final activeCamera = CameraRepository.getAllCameras().firstWhere(
      (c) => c.id == settings.activeCameraId,
      orElse: () => CameraRepository.getAllCameras().first,
    );
    final body = Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withOpacity(0.05),
            ),
          ),
        ),
        SafeArea(
          bottom: !widget.isEmbedded,
          child: Column(
            children: [
              _buildRoyalHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    _buildRoyalSectionHeader('CAMERA PREFERENCES'),
                    _buildRoyalSettingsTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Default Preset',
                      subtitle: activeCamera.name,
                      onTap: () => _showDefaultCameraPicker(),
                    ),
                    _buildRoyalSwitchTile(
                      icon: Icons.volume_up_outlined,
                      title: 'Volume Shutter',
                      subtitle: 'Use physical buttons to snap',
                      value: settings.volumeShutter,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setVolumeShutter(v),
                    ),
                    _buildRoyalSwitchTile(
                      icon: Icons.grid_3x3_outlined,
                      title: 'Composition Grid',
                      subtitle: 'Rule of thirds overlay',
                      value: settings.gridOverlay,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setGridOverlay(v),
                    ),
                    
                    const SizedBox(height: 32),
                    _buildRoyalSectionHeader('IMAGE PRODUCTION'),
                    _buildRoyalSettingsTile(
                      icon: Icons.high_quality_outlined,
                      title: 'Output Quality',
                      subtitle: settings.imageQuality,
                      onTap: () => _showQualityPicker(),
                    ),
                    _buildRoyalSwitchTile(
                      icon: Icons.history_edu_outlined,
                      title: 'Archive Originals',
                      subtitle: 'Save unfiltered negatives',
                      value: settings.saveOriginal,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setSaveOriginal(v),
                    ),

                    const SizedBox(height: 32),
                    _buildRoyalSectionHeader('AUTHENTICATION & CLUB'),
                    _buildRoyalSettingsTile(
                      icon: Icons.star_border_rounded,
                      title: 'Restore Membership',
                      onTap: () => _showRestoreMembershipDialog(),
                    ),
                    _buildRoyalSettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About FilmCam',
                      subtitle: 'Version 1.2.0 Royal Edition',
                      onTap: () => _showAboutDialog(),
                    ),
                    if (widget.isEmbedded) const SizedBox(height: 100), // Dock space
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.isEmbedded) return body;

    return Scaffold(
      backgroundColor: Colors.black,
      body: body,
    );
  }

  void _showRestoreMembershipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Restore Membership', style: TextStyle(color: AppColors.accentGold)),
        content: const Text('Checking with App Store / Play Store for previous purchases...', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No active membership found.'), backgroundColor: Colors.black87),
              );
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(userProfileProvider.notifier).upgradeToPro();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membership restored! Welcome back.'), backgroundColor: AppColors.accentGold),
              );
            },
            child: const Text('Check', style: TextStyle(color: AppColors.accentGold)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'FilmCam',
      applicationVersion: '1.2.0 Royal Edition',
      applicationIcon: const Icon(Icons.camera_roll_rounded, color: AppColors.accentGold, size: 48),
      children: [
        const Text('\nA cinematic camera experience refined for the modern era. Capturing the soul of analog film.', style: TextStyle(fontSize: 12)),
        const Text('\nBuilt with passion for photography.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
      ],
    );
  }


  Widget _buildRoyalHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FadeInDown(
        child: Row(
          children: [
            if (!widget.isEmbedded)
              _glassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 48),
            const Expanded(
              child: Center(
                child: Text(
                  'PREFERENCES',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 18,
                    letterSpacing: 4,
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48), // Balance
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

  Widget _buildRoyalSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.accentGold.withOpacity(0.5),
          letterSpacing: 2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRoyalSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer.clearGlass(
        height: 72,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.transparent, // Fix for assertion
        child: ListTile(
          leading: Icon(icon, color: Colors.white70),
          title: Text(title, style: AppTypography.bodyLarge.copyWith(color: Colors.white, letterSpacing: 1)),
          subtitle: subtitle != null ? Text(subtitle, style: AppTypography.monoSmall.copyWith(color: Colors.white38)) : null,
          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildRoyalSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer.clearGlass(
        height: 72,
        width: double.infinity,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.transparent, // Fix for assertion
        child: SwitchListTile(
          secondary: Icon(icon, color: Colors.white70),
          title: Text(title, style: AppTypography.bodyLarge.copyWith(color: Colors.white, letterSpacing: 1)),
          subtitle: Text(subtitle, style: AppTypography.monoSmall.copyWith(color: Colors.white38)),
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accentGold,
        ),
      ),
    );
  }

  void _showDefaultCameraPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final settings = ref.watch(settingsProvider);
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GlassContainer(
              height: 420,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              gradient: LinearGradient(colors: [Colors.black, Colors.grey.shade900]),
              borderColor: Colors.white10,
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Text('CHOOSE PRESET', style: AppTypography.labelLarge.copyWith(color: AppColors.accentGold, letterSpacing: 4)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: CameraRepository.getFreeCameras().map((camera) => ListTile(
                          title: Text(camera.name, style: const TextStyle(color: Colors.white)),
                          trailing: settings.activeCameraId == camera.id ? const Icon(Icons.check_circle_rounded, color: AppColors.accentGold) : null,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setActiveCamera(camera.id);
                            Navigator.pop(context);
                          },
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showQualityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final settings = ref.watch(settingsProvider);
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: GlassContainer(
              height: 420,
              width: double.infinity,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              gradient: LinearGradient(colors: [Colors.black, Colors.grey.shade900]),
              borderColor: Colors.white10,
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Text('OUTPUT QUALITY', style: AppTypography.labelLarge.copyWith(color: AppColors.accentGold, letterSpacing: 4)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: ['Low', 'Medium', 'High', 'Maximum'].map((q) => ListTile(
                          title: Text(q, style: const TextStyle(color: Colors.white)),
                          trailing: settings.imageQuality == q ? const Icon(Icons.check_circle_rounded, color: AppColors.accentGold) : null,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setImageQuality(q);
                            Navigator.pop(context);
                          },
                        )).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
