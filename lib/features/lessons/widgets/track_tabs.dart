import 'package:flutter/material.dart';

import '../../../core/constants/lessons_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/lesson_models.dart';

/// Gramer/Dersler arasında geçiş yapan iki seçenekli sekme çubuğu.
class TrackTabs extends StatelessWidget {
  const TrackTabs({super.key, required this.selected, required this.onChanged});

  final LessonTrack selected;
  final ValueChanged<LessonTrack> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Row(
        children:
            <(LessonTrack, String)>[
              (LessonTrack.grammar, LessonsContent.grammarTabLabel),
              (LessonTrack.lessons, LessonsContent.lessonsTabLabel),
            ].map(((LessonTrack, String) item) {
              final bool isSelected = item.$1 == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySoft
                          : AppColors.canvas,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: AppSizes.borderWidth,
                      ),
                    ),
                    child: Text(
                      item.$2,
                      style: AppTypography.labelUppercaseSm.copyWith(
                        color: isSelected
                            ? AppColors.primaryPressed
                            : AppColors.bodyMuted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
