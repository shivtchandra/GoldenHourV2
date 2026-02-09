import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presets/data/models/preset_model.dart';
import '../../../presets/data/repositories/preset_repository.dart';
import '../../../../app/theme/colors.dart';

class PresetCarousel extends ConsumerWidget {
  final PresetModel selectedPreset;
  final Function(PresetModel) onPresetSelected;

  const PresetCarousel({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPresets = PresetRepository.getAllPresets();
    final selectedIndex = allPresets.indexWhere((p) => p.id == selectedPreset.id);

    return Container(
      height: 140, // Slightly taller for better spacing
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: RotatedBox(
        quarterTurns: -1,
        child: ListWheelScrollView.useDelegate(
          controller: FixedExtentScrollController(initialItem: selectedIndex >= 0 ? selectedIndex : 0),
          itemExtent: 150, // Width of each item
          perspective: 0.003,
          diameterRatio: 2.0,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            HapticFeedback.selectionClick();
            onPresetSelected(allPresets[index]);
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: allPresets.length,
            builder: (context, index) {
              final preset = allPresets[index];
              final isSelected = preset.id == selectedPreset.id;

              return RotatedBox(
                quarterTurns: 1,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 300),
                  scale: isSelected ? 1.0 : 0.85,
                  child: _buildPresetCard(preset, isSelected),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPresetCard(PresetModel preset, bool isSelected) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
            ? preset.category.accentColor.withOpacity(0.8)
            : Colors.white.withOpacity(0.1),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Category badge - centered
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: preset.category.accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              preset.category.displayName,
              style: TextStyle(
                color: preset.category.accentColor,
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Preset name - clean and centered
          Text(
            preset.name.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white38,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
