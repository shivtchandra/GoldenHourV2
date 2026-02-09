import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../app/theme/typography.dart';
import '../../../../app/theme/theme_colors.dart';
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
    final tc = context.colors;
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
              color: tc.accent.withOpacity(0.05),
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
                    _buildRoyalSectionHeader('APPEARANCE'),
                    _buildRoyalSettingsTile(
                      icon: Icons.brightness_6_rounded,
                      title: 'Theme Mode',
                      subtitle: _getThemeDisplayName(settings.themeMode),
                      onTap: () => _showThemeModePicker(),
                    ),

                    const SizedBox(height: 32),
                    _buildRoyalSectionHeader('CAMERA PREFERENCES'),
                    _buildRoyalSettingsTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Default Preset',
                      subtitle: activeCamera.name,
                      onTap: () => _showDefaultCameraPicker(),
                    ),
                    _buildRoyalSettingsTile(
                      icon: Icons.route_rounded,
                      title: 'Preferred Workflow',
                      subtitle: _getWorkflowDisplayName(settings.preferredWorkflow),
                      onTap: () => _showWorkflowPicker(),
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
                      icon: Icons.auto_fix_high_rounded,
                      title: 'Instant Develop',
                      subtitle: 'Skip manual development stage',
                      value: settings.autoSave,
                      onChanged: (v) => ref.read(settingsProvider.notifier).setAutoSave(v),
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
                      title: 'About GoldenHour',
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
      backgroundColor: tc.scaffoldBackground,
      body: body,
    );
  }

  void _showRestoreMembershipDialog() {
    final tc = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: tc.dialogBackground,
        title: Text('Restore Membership', style: TextStyle(color: tc.accent)),
        content: Text('Checking with App Store / Play Store for previous purchases...', style: TextStyle(color: tc.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('No active membership found.'), backgroundColor: tc.cardSurface),
              );
            },
            child: Text('Cancel', style: TextStyle(color: tc.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(userProfileProvider.notifier).upgradeToPro();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Membership restored! Welcome back.'), backgroundColor: tc.accent),
              );
            },
            child: Text('Check', style: TextStyle(color: tc.accent)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    final tc = context.colors;
    showAboutDialog(
      context: context,
      applicationName: 'GoldenHour',
      applicationVersion: '1.2.0 Royal Edition',
      applicationIcon: Icon(Icons.camera_roll_rounded, color: tc.accent, size: 48),
      children: [
        const Text('\nA cinematic camera experience refined for the modern era. Capturing the soul of analog film.', style: TextStyle(fontSize: 12)),
        const Text('\nBuilt with passion for photography.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
      ],
    );
  }


  Widget _buildRoyalHeader() {
    final tc = context.colors;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FadeInDown(
        child: Row(
          children: [
            if (!widget.isEmbedded)
              AdaptiveGlass(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(24),
                borderColor: Colors.transparent,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, color: tc.iconPrimary, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              )
            else
              const SizedBox(width: 48),
            Expanded(
              child: Center(
                child: Text(
                  'PREFERENCES',
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
            const SizedBox(width: 48), // Balance
          ],
        ),
      ),
    );
  }

  Widget _buildRoyalSectionHeader(String title) {
    final tc = context.colors;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: tc.accentMuted,
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
    final tc = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AdaptiveGlass(
        height: 72,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: tc.iconSecondary),
          title: Text(title, style: AppTypography.bodyLarge.copyWith(color: tc.textPrimary, letterSpacing: 1)),
          subtitle: subtitle != null ? Text(subtitle, style: AppTypography.monoSmall.copyWith(color: tc.textMuted)) : null,
          trailing: Icon(Icons.chevron_right_rounded, color: tc.textFaint),
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
    final tc = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: AdaptiveGlass(
        height: 72,
        borderRadius: BorderRadius.circular(16),
        borderColor: Colors.transparent,
        child: SwitchListTile(
          secondary: Icon(icon, color: tc.iconSecondary),
          title: Text(title, style: AppTypography.bodyLarge.copyWith(color: tc.textPrimary, letterSpacing: 1)),
          subtitle: Text(subtitle, style: AppTypography.monoSmall.copyWith(color: tc.textMuted)),
          value: value,
          onChanged: onChanged,
          activeColor: tc.accent,
        ),
      ),
    );
  }

  Widget _buildBottomSheetContainer({required double height, required Widget child}) {
    final tc = context.colors;
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        gradient: LinearGradient(colors: [tc.sheetGradientStart, tc.sheetGradientEnd]),
        border: Border.all(color: tc.borderSubtle),
      ),
      child: SafeArea(
        bottom: true,
        child: child,
      ),
    );
  }

  Widget _buildSheetHandle() {
    final tc = context.colors;
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: tc.textFaint, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getThemeDisplayName(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'system':
        return 'System';
      default:
        return 'Dark';
    }
  }

  void _showThemeModePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final settings = ref.watch(settingsProvider);
          final sheetColors = context.colors;
          final modes = [
            {'id': 'dark', 'name': 'Dark', 'icon': Icons.dark_mode_rounded},
            {'id': 'light', 'name': 'Light', 'icon': Icons.light_mode_rounded},
            {'id': 'system', 'name': 'System', 'icon': Icons.settings_brightness_rounded},
          ];
          return Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              gradient: LinearGradient(colors: [sheetColors.sheetGradientStart, sheetColors.sheetGradientEnd]),
              border: Border.all(color: sheetColors.borderSubtle),
            ),
            child: SafeArea(
              bottom: true,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: sheetColors.textFaint, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 24),
                  Text('THEME MODE', style: AppTypography.labelLarge.copyWith(color: sheetColors.accent, letterSpacing: 4)),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: modes.map((mode) => ListTile(
                        leading: Icon(
                          mode['icon'] as IconData,
                          color: settings.themeMode == mode['id']
                            ? sheetColors.accent
                            : sheetColors.textTertiary,
                        ),
                        title: Text(
                          mode['name'] as String,
                          style: TextStyle(
                            color: settings.themeMode == mode['id']
                              ? sheetColors.accent
                              : sheetColors.textPrimary,
                          ),
                        ),
                        trailing: settings.themeMode == mode['id']
                          ? Icon(Icons.check_circle_rounded, color: sheetColors.accent)
                          : null,
                        onTap: () {
                          ref.read(settingsProvider.notifier).setThemeMode(mode['id'] as String);
                          Navigator.pop(context);
                        },
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
          final sheetColors = context.colors;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 420,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(colors: [sheetColors.sheetGradientStart, sheetColors.sheetGradientEnd]),
                border: Border.all(color: sheetColors.borderSubtle),
              ),
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: sheetColors.textFaint, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Text('CHOOSE PRESET', style: AppTypography.labelLarge.copyWith(color: sheetColors.accent, letterSpacing: 4)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: CameraRepository.getFreeCameras().map((camera) => ListTile(
                          title: Text(camera.name, style: TextStyle(color: sheetColors.textPrimary)),
                          trailing: settings.activeCameraId == camera.id ? Icon(Icons.check_circle_rounded, color: sheetColors.accent) : null,
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
          final sheetColors = context.colors;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 420,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(colors: [sheetColors.sheetGradientStart, sheetColors.sheetGradientEnd]),
                border: Border.all(color: sheetColors.borderSubtle),
              ),
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: sheetColors.textFaint, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 24),
                    Text('OUTPUT QUALITY', style: AppTypography.labelLarge.copyWith(color: sheetColors.accent, letterSpacing: 4)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: ['Low', 'Medium', 'High', 'Maximum'].map((q) => ListTile(
                          title: Text(q, style: TextStyle(color: sheetColors.textPrimary)),
                          trailing: settings.imageQuality == q ? Icon(Icons.check_circle_rounded, color: sheetColors.accent) : null,
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

  String _getWorkflowDisplayName(String workflow) {
    switch (workflow) {
      case 'camera_explorer':
        return 'Camera Explorer';
      case 'quick_presets':
        return 'Quick Presets';
      case 'balanced':
        return 'Balanced Studio';
      default:
        return 'Balanced Studio';
    }
  }

  void _showWorkflowPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final settings = ref.watch(settingsProvider);
          final sheetColors = context.colors;
          final workflows = [
            {
              'id': 'camera_explorer',
              'name': 'Camera Explorer',
              'subtitle': 'Lens-first workflow',
              'icon': Icons.auto_awesome_motion_rounded,
            },
            {
              'id': 'quick_presets',
              'name': 'Quick Presets',
              'subtitle': 'Preset-first workflow',
              'icon': Icons.auto_awesome_rounded,
            },
            {
              'id': 'balanced',
              'name': 'Balanced Studio',
              'subtitle': 'Home-centered workflow',
              'icon': Icons.home_rounded,
            },
          ];

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: 420,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(colors: [sheetColors.sheetGradientStart, sheetColors.sheetGradientEnd]),
                border: Border.all(color: sheetColors.borderSubtle),
              ),
              child: SafeArea(
                bottom: true,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sheetColors.textFaint,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'WORKFLOW PREFERENCE',
                      style: AppTypography.labelLarge.copyWith(
                        color: sheetColors.accent,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: workflows.map((workflow) => ListTile(
                          leading: Icon(
                            workflow['icon'] as IconData,
                            color: settings.preferredWorkflow == workflow['id']
                              ? sheetColors.accent
                              : sheetColors.textTertiary,
                          ),
                          title: Text(
                            workflow['name'] as String,
                            style: TextStyle(
                              color: settings.preferredWorkflow == workflow['id']
                                ? sheetColors.accent
                                : sheetColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            workflow['subtitle'] as String,
                            style: TextStyle(
                              color: sheetColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          trailing: settings.preferredWorkflow == workflow['id']
                            ? Icon(Icons.check_circle_rounded, color: sheetColors.accent)
                            : null,
                          onTap: () {
                            ref.read(settingsProvider.notifier).setPreferredWorkflow(workflow['id'] as String);
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
