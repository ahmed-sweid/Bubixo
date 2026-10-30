import 'package:flutter/material.dart';

import '../../../core/constants/level_test_content.dart';
import '../../../core/design_system.dart';
import '../../common/widgets/option_card.dart';
import '../../../core/models/level_test_models.dart';

/// Tek soruluk test görünümü: ilerleme, soru, seçenekler ve DEVAM butonu.
class LevelTestQuestionView extends StatelessWidget {
  const LevelTestQuestionView({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.selectedOption,
    required this.onSelectOption,
    required this.onContinue,
  });

  final LevelTestQuestion question;
  final int index;
  final int total;
  final int? selectedOption;
  final ValueChanged<int> onSelectOption;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final String progress = LevelTestContent.questionProgressTemplate
        .replaceFirst('{index}', '${index + 1}')
        .replaceFirst('{total}', '$total');

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: SizedBox(
                              height: 10,
                              child: LinearProgressIndicator(
                                value: (index + 1) / total,
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
                        key: ValueKey<int>(index),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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
                  onPressed: selectedOption == null ? null : onContinue,
                  child: const Text(LevelTestContent.ctaLabel),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
