import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/lessons_content.dart';
import '../../../core/design_system.dart';
import 'score_badge.dart';

/// Test sonucu: doğru/yanlış sayıları, tekrar dene ve ana sayfaya dön.
class LessonTestResultView extends StatelessWidget {
  const LessonTestResultView({
    super.key,
    required this.correctCount,
    required this.wrongCount,
    required this.onRetry,
    required this.onBackToHome,
  });

  final int correctCount;
  final int wrongCount;
  final VoidCallback onRetry;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                LessonsContent.resultTitle,
                style: AppTypography.headingMd.copyWith(
                  color: AppColors.inkDisplay,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: ScoreBadge(
                      icon: Iconsax.tick_circle,
                      color: AppColors.primary,
                      label: LessonsContent.correctLabel,
                      value: correctCount,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  Expanded(
                    child: ScoreBadge(
                      icon: Iconsax.close_circle,
                      color: AppColors.accentCardinal,
                      label: LessonsContent.wrongLabel,
                      value: wrongCount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(LessonsContent.retryLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onBackToHome,
                  child: Text(LessonsContent.homeLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
