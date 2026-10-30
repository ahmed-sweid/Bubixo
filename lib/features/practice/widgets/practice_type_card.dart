import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/practice_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/practice_models.dart';
import '../practice_state.dart';

/// Pratikler listesindeki tür kartı: ikon, başlık, açıklama ve ilerleme.
class PracticeTypeCard extends StatelessWidget {
  const PracticeTypeCard({super.key, required this.progress, this.onTap});

  final PracticeTypeProgress progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final PracticeType type = progress.type;
    final Color color = PracticeContent.typeColors[type]!;
    final String progressText = PracticeContent.progressTemplate
        .replaceFirst('{done}', '${progress.completedCount}')
        .replaceFirst('{total}', '${progress.totalCount}');

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: Icon(
                    PracticeContent.typeIcons[type],
                    size: 26,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              PracticeContent.typeTitles[type]!,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.inkDisplay,
                              ),
                            ),
                          ),
                          Icon(
                            Iconsax.arrow_right_2,
                            size: 16,
                            color: AppColors.bodyMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        PracticeContent.typeDescriptions[type]!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: SizedBox(
                      height: 8,
                      child: LinearProgressIndicator(
                        value: progress.progress,
                        color: color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  progressText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
