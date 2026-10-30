import 'package:flutter/material.dart';

import '../../../core/constants/lessons_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/lesson_models.dart';
import '../../common/widgets/option_card.dart';

/// Test sorusu görünümü: ilerleme, soru metni, seçenekler ve ilerleme CTA'sı.
class LessonTestQuestionView extends StatelessWidget {
  const LessonTestQuestionView({
    super.key,
    required this.question,
    required this.questionIndex,
    required this.questionCount,
    required this.selectedOption,
    required this.onSelectOption,
    required this.onAdvance,
  });

  final LessonQuestion question;
  final int questionIndex;
  final int questionCount;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final String progress = LessonsContent.questionProgressTemplate
        .replaceFirst('{index}', '${questionIndex + 1}')
        .replaceFirst('{total}', '$questionCount');
    return Column(
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
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: (questionIndex + 1) / questionCount,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          progress,
                          style: AppTypography.labelUppercaseSm.copyWith(
                            color: AppColors.bodyMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      child: Column(
                        key: ValueKey<int>(questionIndex),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            question.prompt,
                            style: AppTypography.headingSm.copyWith(
                              color: AppColors.inkDisplay,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ...List.generate(question.options.length, (int i) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: i < question.options.length - 1
                                    ? AppSpacing.base
                                    : 0,
                              ),
                              child: OptionCard(
                                label: question.options[i],
                                selected: selectedOption == i,
                                onTap: () => onSelectOption(i),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
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
                  onPressed: selectedOption == null ? null : onAdvance,
                  child: Text(LessonsContent.testCtaLabel),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
