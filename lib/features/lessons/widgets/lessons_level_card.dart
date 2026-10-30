import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/lessons_content.dart';
import '../../../core/constants/level_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/lesson_models.dart';
import '../lessons_state.dart';
import 'level_test_tile.dart';
import 'topic_tile.dart';

/// Seviye kartı: başlık, ilerleme çubuğu ve açılınca ders + seviye testi
/// satırları. Ders ve test satırları cubit bağlanana kadar pasiftir.
class LessonsLevelCard extends StatelessWidget {
  const LessonsLevelCard({
    super.key,
    required this.level,
    required this.track,
    required this.expanded,
    required this.onToggle,
    this.onOpenLesson,
    this.onOpenLevelTest,
  });

  final LessonLevel level;
  final LessonTrack track;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<Lesson>? onOpenLesson;
  final VoidCallback? onOpenLevelTest;

  @override
  Widget build(BuildContext context) {
    final List<Lesson> lessons = level.lessonsFor(track);
    final double progress = level.progressFor(track);
    final int completedCount = (progress * lessons.length).round().clamp(
      0,
      lessons.length,
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
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: AppRadius.roundedLg,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
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
                        '%${(progress * 100).round()}',
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
                        value: progress.clamp(0.0, 1.0),
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
              children: [
                if (lessons.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Text(
                      LessonsContent.noLessonsLabel,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                  ),
                for (int i = 0; i < lessons.length; i++)
                  LessonTopicTile(
                    lesson: lessons[i],
                    completed: i < completedCount,
                    onTap: onOpenLesson == null
                        ? null
                        : () => onOpenLesson!(lessons[i]),
                  ),
                LevelTestTile(
                  unlocked: level.levelTestUnlocked,
                  onTap: level.levelTestUnlocked ? onOpenLevelTest : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
