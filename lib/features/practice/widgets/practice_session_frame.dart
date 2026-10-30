import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/practice_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/practice_models.dart';

/// Beş pratik türünün ortak iskeleti: başlık, ilerleme, kaydırılabilir
/// içerik ve sabit alt eylem alanı.
class PracticeSessionFrame extends StatelessWidget {
  const PracticeSessionFrame({
    super.key,
    required this.type,
    required this.index,
    required this.total,
    required this.child,
    required this.footer,
  });

  final PracticeType type;
  final int index;
  final int total;
  final Widget child;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final String progress = PracticeContent.questionProgressTemplate
        .replaceFirst('{index}', '${index + 1}')
        .replaceFirst('{total}', '$total');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(PracticeContent.typeTitles[type]!)),
      body: SafeArea(
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
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
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
                        child,
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
                  child: footer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Doğru/yanlış geri bildirimi; renk tek başına anlam taşımasın diye ikon ve
/// metinle birlikte verilir.
class PracticeFeedbackBanner extends StatelessWidget {
  const PracticeFeedbackBanner({
    super.key,
    required this.correct,
    required this.message,
  });

  final bool correct;
  final String message;

  @override
  Widget build(BuildContext context) {
    final Color color = correct
        ? AppColors.primaryPressed
        : AppColors.accentCardinal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: color, width: AppSizes.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            correct ? Iconsax.tick_circle : Iconsax.close_circle,
            size: 20,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyStrong),
            ),
          ),
        ],
      ),
    );
  }
}
