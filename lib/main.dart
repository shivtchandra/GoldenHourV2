import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app/theme/app_theme.dart';
import 'package:film_cam/features/splash/presentation/screens/splash_screen.dart';
import 'package:film_cam/features/home/presentation/screens/home_screen.dart';
import 'package:film_cam/features/camera/data/models/camera_model.dart';
import 'package:film_cam/features/camera/data/repositories/camera_repository.dart';
import 'package:film_cam/features/develop/presentation/screens/develop_screen.dart';
import 'package:film_cam/features/presets/data/models/preset_model.dart';
import 'package:film_cam/features/presets/presentation/screens/presets_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:film_cam/features/settings/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Disable flutter_animate debug logs
  Animate.restartOnHotReload = true;

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const FilmCamApp(),
    ),
  );
}

class FilmCamApp extends StatelessWidget {
  const FilmCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FilmCam',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
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
