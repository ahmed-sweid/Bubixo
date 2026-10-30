import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/design_system.dart';

/// Seviye seçim ızgarasındaki tek CEFR kartı; kademeli giriş animasyonuyla
/// belirir ve seçilince büyüyüp vurgulanır.
class LevelSelectCard extends StatelessWidget {
  const LevelSelectCard({
    super.key,
    required this.index,
    required this.selectedLevel,
    required this.entrance,
    required this.onSelected,
  });

  final int index;
  final int? selectedLevel;
  final AnimationController entrance;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedLevel;
    final Color ink = isSelected
        ? AppColors.primaryPressed
        : AppColors.inkDisplay;
    final Animation<double> appear = CurvedAnimation(
      parent: entrance,
      curve: Interval(
        index * 0.08,
        (index * 0.08 + 0.55).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: appear,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: appear.value,
        child: Transform.translate(
          offset: Offset(0, (1 - appear.value) * 16),
          child: child,
        ),
      ),
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: () => onSelected(index),
          borderRadius: AppRadius.roundedLg,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 84,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primarySoft : AppColors.canvas,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.hairline,
                width: AppSizes.borderWidth,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LevelContent.cefrLevels[index],
                        style: AppTypography.headingSm.copyWith(color: ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LevelContent.cefrLevelDescriptions[index],
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? AppColors.primaryPressed
                              : AppColors.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1 : 0,
                    child: Icon(
                      Iconsax.tick_circle,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
