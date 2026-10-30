import 'package:flutter/material.dart';

import '../../core/constants/level_content.dart';
import '../../core/constants/lessons_content.dart';
import '../../core/design_system.dart';
import '../../core/models/lesson_models.dart';
import 'lesson_test_screen.dart';

/// Konu detay sayfası: başlık, anlatım metni ve teste geçiş butonu.
class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(LevelContent.cefrLevels[lesson.levelIndex])),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          lesson.title,
                          style: AppTypography.headingMd.copyWith(
                            color: AppColors.inkDisplay,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        for (int i = 0; i < lesson.body.length; i++) ...[
                          Text(
                            lesson.body[i],
                            style: AppTypography.bodyLg.copyWith(
                              color: AppColors.body,
                              height: 1.6,
                            ),
                          ),
                          if (i < lesson.body.length - 1)
                            const SizedBox(height: AppSpacing.base),
                        ],
                        const SizedBox(height: AppSpacing.section),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => LessonTestScreen(lesson: lesson),
                          ),
                        );
                      },
                      child: Text(LessonsContent.detailCtaLabel),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
