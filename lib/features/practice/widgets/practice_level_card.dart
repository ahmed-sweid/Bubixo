import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/practice_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/practice_models.dart';
import '../practice_state.dart';
import 'practice_item_tile.dart';

/// Pratik detayındaki seviye kartı: ilerleme çubuğu ve açılınca içerik
/// listesi.
class PracticeLevelCard extends StatelessWidget {
  const PracticeLevelCard({
    super.key,
    required this.level,
    required this.expanded,
    required this.onToggle,
    this.onOpenItem,
  });

  final PracticeLevelProgress level;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<PracticeItem>? onOpenItem;

  @override
  Widget build(BuildContext context) {
    final String percent = PracticeContent.percentTemplate.replaceFirst(
      '{percent}',
      '${(level.progress * 100).round()}',
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.roundedLg,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        LevelContent.cefrLevels[level.levelIndex],
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.inkDisplay,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        LevelContent.cefrLevelDescriptions[level.levelIndex],
                        style: AppTypography.caption.copyWith(
                          color: AppColors.bodyMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        percent,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.bodyMuted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Iconsax.arrow_down_2,
                          size: 18,
                          color: AppColors.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: SizedBox(
                      height: 10,
                      child: LinearProgressIndicator(
                        value: level.progress.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: AppColors.hairline,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeOut,
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final PracticeItem item in level.items)
                  PracticeItemTile(
                    item: item,
                    onTap: onOpenItem == null ? null : () => onOpenItem!(item),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
