import 'package:flutter/material.dart';
import 'package:english_conversation_app/domain/entities/level.dart';

/// Selecteur de niveau CEFR (chips).
class LevelSelector extends StatelessWidget {
  const LevelSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CefrLevel? selected;
  final ValueChanged<CefrLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CefrLevel.values.map((level) {
        final active = level == selected;
        return ChoiceChip(
          label: Text(level.label),
          selected: active,
          onSelected: (_) => onSelected(level),
        );
      }).toList(),
    );
  }
}
