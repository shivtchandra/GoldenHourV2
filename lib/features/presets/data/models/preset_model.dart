import 'package:flutter/material.dart';
import '../../../camera/data/models/pipeline_config.dart';

/// Categories for organizing presets
enum PresetCategory {
  cinematic,
  moody,
  brightAiry,
  vintageRetro,
  shutterSpeed,
  film,
}

extension PresetCategoryExtension on PresetCategory {
  String get displayName {
    switch (this) {
      case PresetCategory.cinematic:
        return 'CINEMATIC';
      case PresetCategory.moody:
        return 'MOODY';
      case PresetCategory.brightAiry:
        return 'BRIGHT';
      case PresetCategory.vintageRetro:
        return 'VINTAGE';
      case PresetCategory.shutterSpeed:
        return 'SHUTTER';
      case PresetCategory.film:
        return 'FILM';
    }
  }

  Color get accentColor {
    switch (this) {
      case PresetCategory.cinematic:
        return const Color(0xFF00CED1); // Teal
      case PresetCategory.moody:
        return const Color(0xFF800080); // Purple
      case PresetCategory.brightAiry:
        return const Color(0xFFFFD700); // Gold
      case PresetCategory.vintageRetro:
        return const Color(0xFFFF6347); // Tomato
      case PresetCategory.shutterSpeed:
        return const Color(0xFF4169E1); // Royal Blue
      case PresetCategory.film:
        return const Color(0xFFF4C542); // Kodak Gold
    }
  }
}

/// Model representing an editing preset
class PresetModel {
  final String id;
  final String name;
  final String description;
  final PresetCategory category;
  final PipelineConfig pipeline;
  final bool isPro;

  const PresetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.pipeline,
    this.isPro = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresetModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
