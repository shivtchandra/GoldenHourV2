import 'package:flutter/material.dart';
import 'pipeline_config.dart';

/// Represents a film camera preset with its characteristics and processing pipeline
class CameraModel {
  final String id;
  final String name;
  final String era;
  final String type;
  final int? iso;
  final String personality;
  final bool isPro;
  final String? price;
  final Color iconColor;
  final List<String> bestFor;
  final String description;
  final PipelineConfig pipeline;
  final String? icon3DAssetPath;

  const CameraModel({
    required this.id,
    required this.name,
    required this.era,
    required this.type,
    this.iso,
    required this.personality,
    required this.isPro,
    this.price,
    required this.iconColor,
    required this.bestFor,
    required this.description,
    required this.pipeline,
    this.icon3DAssetPath,
  });

  /// Create a copy with modified fields
  CameraModel copyWith({
    String? id,
    String? name,
    String? era,
    String? type,
    int? iso,
    String? personality,
    bool? isPro,
    String? price,
    Color? iconColor,
    List<String>? bestFor,
    String? description,
    PipelineConfig? pipeline,
    String? icon3DAssetPath,
  }) {
    return CameraModel(
      id: id ?? this.id,
      name: name ?? this.name,
      era: era ?? this.era,
      type: type ?? this.type,
      iso: iso ?? this.iso,
      personality: personality ?? this.personality,
      isPro: isPro ?? this.isPro,
      price: price ?? this.price,
      iconColor: iconColor ?? this.iconColor,
      bestFor: bestFor ?? this.bestFor,
      description: description ?? this.description,
      pipeline: pipeline ?? this.pipeline,
      icon3DAssetPath: icon3DAssetPath ?? this.icon3DAssetPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'era': era,
        'type': type,
        'iso': iso,
        'personality': personality,
        'isPro': isPro,
        'price': price,
        'iconColor': iconColor.value,
        'bestFor': bestFor,
        'description': description,
        'pipeline': pipeline.toJson(),
        'icon3DAssetPath': icon3DAssetPath,
      };

  factory CameraModel.fromJson(Map<String, dynamic> json) {
    return CameraModel(
      id: json['id'] as String,
      name: json['name'] as String,
      era: json['era'] as String,
      type: json['type'] as String,
      iso: json['iso'] as int?,
      personality: json['personality'] as String,
      isPro: json['isPro'] as bool,
      price: json['price'] as String?,
      iconColor: Color(json['iconColor'] as int),
      bestFor: List<String>.from(json['bestFor'] as List),
      description: json['description'] as String,
      pipeline: PipelineConfig.fromJson(json['pipeline'] as Map<String, dynamic>),
      icon3DAssetPath: json['icon3DAssetPath'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Camera categories for filtering
enum CameraCategory {
  all,
  free,
  pro,
  color,
  blackAndWhite,
  instant,
  special,
  toy,
}

extension CameraCategoryExtension on CameraCategory {
  String get displayName {
    switch (this) {
      case CameraCategory.all:
        return 'All';
      case CameraCategory.free:
        return 'FREE';
      case CameraCategory.pro:
        return 'PRO';
      case CameraCategory.color:
        return 'Color';
      case CameraCategory.blackAndWhite:
        return 'B&W';
      case CameraCategory.instant:
        return 'Instant';
      case CameraCategory.special:
        return 'Special';
      case CameraCategory.toy:
        return 'Toy';
    }
  }
}
