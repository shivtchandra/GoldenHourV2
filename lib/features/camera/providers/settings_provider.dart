import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:film_cam/features/settings/providers/user_provider.dart';

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsNotifier(prefs);
});

class AppSettings {
  final bool volumeShutter;
  final bool gridOverlay;
  final bool hapticFeedback;
  final bool saveOriginal;
  final double effectOpacity;
  final String imageQuality;
  final String activeCameraId;
  final String aspectRatio;
  final String preferredWorkflow;
  final String themeMode;
  final List<String> toolkitCameraIds;
  final bool autoSave;

  const AppSettings({
    this.volumeShutter = false,
    this.gridOverlay = true,
    this.hapticFeedback = true,
    this.saveOriginal = false,
    this.effectOpacity = 0.6,
    this.imageQuality = 'High',
    this.activeCameraId = 'kodak_gold_200',
    this.aspectRatio = '3:4',
    this.preferredWorkflow = 'balanced',
    this.themeMode = 'dark',
    this.toolkitCameraIds = const [],
    this.autoSave = false,
  });

  AppSettings copyWith({
    bool? volumeShutter,
    bool? gridOverlay,
    bool? hapticFeedback,
    bool? saveOriginal,
    double? effectOpacity,
    String? imageQuality,
    String? activeCameraId,
    String? aspectRatio,
    String? preferredWorkflow,
    String? themeMode,
    List<String>? toolkitCameraIds,
    bool? autoSave,
  }) {
    return AppSettings(
      volumeShutter: volumeShutter ?? this.volumeShutter,
      gridOverlay: gridOverlay ?? this.gridOverlay,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      saveOriginal: saveOriginal ?? this.saveOriginal,
      effectOpacity: effectOpacity ?? this.effectOpacity,
      imageQuality: imageQuality ?? this.imageQuality,
      activeCameraId: activeCameraId ?? this.activeCameraId,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      preferredWorkflow: preferredWorkflow ?? this.preferredWorkflow,
      themeMode: themeMode ?? this.themeMode,
      toolkitCameraIds: toolkitCameraIds ?? this.toolkitCameraIds,
      autoSave: autoSave ?? this.autoSave,
    );
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const AppSettings()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = AppSettings(
      volumeShutter: _prefs.getBool('volumeShutter') ?? false,
      gridOverlay: _prefs.getBool('gridOverlay') ?? true,
      hapticFeedback: _prefs.getBool('hapticFeedback') ?? true,
      saveOriginal: _prefs.getBool('saveOriginal') ?? false,
      effectOpacity: _prefs.getDouble('effectOpacity') ?? 0.6,
      imageQuality: _prefs.getString('imageQuality') ?? 'High',
      activeCameraId: _prefs.getString('activeCameraId') ?? 'kodak_gold_200',
      aspectRatio: _prefs.getString('aspectRatio') ?? '3:4',
      preferredWorkflow: _prefs.getString('preferredWorkflow') ?? 'balanced',
      themeMode: _prefs.getString('themeMode') ?? 'dark',
      toolkitCameraIds: _prefs.getStringList('toolkitCameraIds') ?? [],
      autoSave: _prefs.getBool('autoSave') ?? false,
    );
  }

  Future<void> _saveSettings() async {
    await _prefs.setBool('volumeShutter', state.volumeShutter);
    await _prefs.setBool('gridOverlay', state.gridOverlay);
    await _prefs.setBool('hapticFeedback', state.hapticFeedback);
    await _prefs.setBool('saveOriginal', state.saveOriginal);
    await _prefs.setDouble('effectOpacity', state.effectOpacity);
    await _prefs.setString('imageQuality', state.imageQuality);
    await _prefs.setString('activeCameraId', state.activeCameraId);
    await _prefs.setString('aspectRatio', state.aspectRatio);
    await _prefs.setString('preferredWorkflow', state.preferredWorkflow);
    await _prefs.setString('themeMode', state.themeMode);
    await _prefs.setStringList('toolkitCameraIds', state.toolkitCameraIds);
    await _prefs.setBool('autoSave', state.autoSave);
  }

  void setVolumeShutter(bool value) {
    state = state.copyWith(volumeShutter: value);
    _saveSettings();
  }

  void setGridOverlay(bool value) {
    state = state.copyWith(gridOverlay: value);
    _saveSettings();
  }

  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
    _saveSettings();
  }

  void setSaveOriginal(bool value) {
    state = state.copyWith(saveOriginal: value);
    _saveSettings();
  }

  void setEffectOpacity(double value) {
    state = state.copyWith(effectOpacity: value);
    _saveSettings();
  }

  void setImageQuality(String value) {
    state = state.copyWith(imageQuality: value);
    _saveSettings();
  }

  void setActiveCamera(String id) {
    state = state.copyWith(activeCameraId: id);
    _saveSettings();
  }

  void setAspectRatio(String ratio) {
    state = state.copyWith(aspectRatio: ratio);
    _saveSettings();
  }

  void setPreferredWorkflow(String value) {
    state = state.copyWith(preferredWorkflow: value);
    _saveSettings();
  }

  void setThemeMode(String value) {
    state = state.copyWith(themeMode: value);
    _saveSettings();
  }

  void setToolkitCameras(List<String> ids) {
    state = state.copyWith(toolkitCameraIds: ids);
    _saveSettings();
  }

  void setAutoSave(bool value) {
    state = state.copyWith(autoSave: value);
    _saveSettings();
  }
}

