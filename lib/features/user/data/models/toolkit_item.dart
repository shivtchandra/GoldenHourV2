import 'package:flutter/material.dart';
import '../../../camera/data/models/camera_model.dart';
import '../../../camera/data/models/pipeline_config.dart';
import '../../../presets/data/models/preset_model.dart';

/// Unified model for toolkit items (cameras and presets)
/// This allows users to favorite both cameras and presets in a single collection
enum ToolkitItemType { camera, preset }

class ToolkitItem {
  final String id;
  final String name;
  final String description;
  final ToolkitItemType type;
  final Color accentColor;
  final PipelineConfig pipeline;
  final bool isPro;
  final String? category; // Film type or preset category

  const ToolkitItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.accentColor,
    required this.pipeline,
    this.isPro = false,
    this.category,
  });

  /// Create from CameraModel
  factory ToolkitItem.fromCamera(CameraModel camera) {
    return ToolkitItem(
      id: 'camera_${camera.id}',
      name: camera.name,
      description: camera.personality,
      type: ToolkitItemType.camera,
      accentColor: camera.iconColor,
      pipeline: camera.pipeline,
      isPro: camera.isPro,
      category: camera.type,
    );
  }

  /// Create from PresetModel
  factory ToolkitItem.fromPreset(PresetModel preset) {
    return ToolkitItem(
      id: 'preset_${preset.id}',
      name: preset.name,
      description: preset.description,
      type: ToolkitItemType.preset,
      accentColor: preset.category.accentColor,
      pipeline: preset.pipeline,
      isPro: preset.isPro,
      category: preset.category.displayName,
    );
  }

  /// Get the original ID without prefix
  String get originalId {
    if (id.startsWith('camera_')) {
      return id.substring(7);
    } else if (id.startsWith('preset_')) {
      return id.substring(7);
    }
    return id;
  }

  /// Get display icon based on type
  IconData get icon {
    switch (type) {
      case ToolkitItemType.camera:
        return Icons.camera_roll_rounded;
      case ToolkitItemType.preset:
        return Icons.auto_awesome_rounded;
    }
  }

  /// Get type label
  String get typeLabel {
    switch (type) {
      case ToolkitItemType.camera:
        return 'FILM';
      case ToolkitItemType.preset:
        return 'PRESET';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToolkitItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
