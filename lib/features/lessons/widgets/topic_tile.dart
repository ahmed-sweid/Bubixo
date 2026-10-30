import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/design_system.dart';
import '../../../core/models/lesson_models.dart';

/// Seviye kartı içindeki tek ders satırı.
class LessonTopicTile extends StatelessWidget {
  const LessonTopicTile({
    super.key,
    required this.lesson,
    required this.completed,
    this.onTap,
  });

  final Lesson lesson;
  final bool completed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              completed ? Iconsax.tick_circle : Iconsax.more_circle,
              size: 20,
              color: completed ? AppColors.primary : AppColors.bodySoft,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                lesson.title,
                style: AppTypography.bodySm.copyWith(color: AppColors.body),
              ),
            ),
            Icon(Iconsax.arrow_right_2, size: 16, color: AppColors.bodyMuted),
          ],
        ),
      ),
    );
  }
}
