import 'package:flutter/material.dart';

import '../../../core/constants/practice_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/practice_models.dart';
import 'practice_summary_tile.dart';

/// Ortak pratik sonuç görünümü; konuşmada doğru/yanlış yerine tamamlanan
/// ifade sayısı gösterilir.
class PracticeResultView extends StatelessWidget {
  const PracticeResultView({
    super.key,
    required this.type,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.onRetry,
    required this.onGoHome,
  });

  final PracticeType type;
  final int total;
  final int correct;
  final int wrong;
  final VoidCallback onRetry;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    final bool isSpeaking = type == PracticeType.speaking;
    final String message = isSpeaking
        ? PracticeContent.speakingResultSummaryTemplate.replaceFirst(
            '{completed}',
            '$correct',
          )
        : wrong == 0
        ? PracticeContent.perfectResultMessage
        : PracticeContent.resultSummaryTemplate
              .replaceFirst('{correct}', '$correct')
              .replaceFirst('{wrong}', '$wrong');

    return SafeArea(
      child: Column(
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
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        PracticeContent.typeTitles[type]!,
                        textAlign: TextAlign.center,
                        style: AppTypography.headingMd.copyWith(
                          color: AppColors.inkDisplay,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: AppRadius.roundedLg,
                          border: Border.all(
                            color: AppColors.hairline,
                            width: AppSizes.borderWidth,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: PracticeSummaryTile(
                                value: '$total',
                                label: PracticeContent.totalLabel,
                                color: AppColors.inkDisplay,
                              ),
                            ),
                            Expanded(
                              child: PracticeSummaryTile(
                                value: '$correct',
                                label: isSpeaking
                                    ? PracticeContent.completedLabel
                                    : PracticeContent.correctLabel,
                                color: AppColors.primary,
                              ),
                            ),
                            if (!isSpeaking)
                              Expanded(
                                child: PracticeSummaryTile(
                                  value: '$wrong',
                                  label: PracticeContent.wrongLabel,
                                  color: AppColors.accentCardinal,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.bodyMuted,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onRetry,
                        child: const Text(PracticeContent.retryCtaLabel),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onGoHome,
                        child: const Text(PracticeContent.homeCtaLabel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
