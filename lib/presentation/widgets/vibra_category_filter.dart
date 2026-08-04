import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/vibra_colors.dart';
import '../../core/theme/vibra_text_styles.dart';
import '../../core/theme/vibra_spacing.dart';

class VibraCategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const VibraCategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  String _getEmojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'tutti': return '🎵';
      case 'electronic': return '🎹';
      case 'indie': return '🎸';
      case 'house': return '🏠';
      case 'rap': return '🎤';
      case 'alternative': return '✨';
      default: return '🎧';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VibraSpacing.lg),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          final emoji = _getEmojiForCategory(category);
          
          Widget chip = AnimatedContainer(
            duration: VibraSpacing.animFast,
            padding: const EdgeInsets.symmetric(horizontal: VibraSpacing.xl, vertical: VibraSpacing.sm),
            decoration: BoxDecoration(
              gradient: isSelected ? const LinearGradient(colors: [VibraColors.primary, VibraColors.accent]) : null,
              color: isSelected ? null : VibraColors.surfaceVariant,
              borderRadius: BorderRadius.circular(VibraSpacing.radiusFull),
              border: Border.all(
                color: isSelected ? Colors.transparent : VibraColors.glassBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji),
                const SizedBox(width: VibraSpacing.sm),
                Text(
                  category,
                  style: VibraTextStyles.labelMedium.copyWith(
                    color: isSelected ? Colors.white : VibraColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );

          if (isSelected) {
            chip = chip.animate().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: VibraSpacing.animFast);
          }

          return Padding(
            padding: const EdgeInsets.only(right: VibraSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelected(category),
              child: chip,
            ),
          );
        },
      ),
    );
  }
}
