import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme/app_theme.dart';
import 'package:film_cam/features/splash/presentation/screens/splash_screen.dart';
import 'package:film_cam/features/camera/data/repositories/camera_repository.dart';
import 'package:film_cam/features/presets/data/repositories/preset_repository.dart';
import 'package:film_cam/features/develop/presentation/screens/develop_screen.dart';
import 'package:film_cam/features/presets/data/models/preset_model.dart';
import 'package:film_cam/features/presets/presentation/screens/presets_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:film_cam/features/settings/providers/user_provider.dart';
import 'package:film_cam/features/camera/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize CameraRepository for persistent favorites
  await CameraRepository.init(prefs);
  await PresetRepository.init(prefs);

  // Disable flutter_animate debug logs
  Animate.restartOnHotReload = true;

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const GoldenHourApp(),
    ),
  );
}

class GoldenHourApp extends ConsumerWidget {
  const GoldenHourApp({super.key});

  ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'GoldenHour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _resolveThemeMode(settings.themeMode),
      home: const SplashScreen(),
      routes: {
        '/presets': (context) => const PresetsScreen(),
        '/develop': (context) {
          final preset = ModalRoute.of(context)?.settings.arguments as PresetModel?;
          return DevelopScreen(initialCamera: preset != null ? CameraRepository.getCameraById(preset.id) : null);
        },
      },
    );
  }
}
