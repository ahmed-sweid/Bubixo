import 'package:flutter/material.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/level_test_content.dart';
import '../../../core/design_system.dart';

/// Test sonucu: önerilen seviye, bilgilendirme ve iki çıkış.
class LevelTestResultView extends StatelessWidget {
  const LevelTestResultView({
    super.key,
    required this.levelIndex,
    this.onConfirm,
    this.onChooseManually,
  });

  final int levelIndex;
  final VoidCallback? onConfirm;
  final VoidCallback? onChooseManually;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.xl),
              Text(
                LevelTestContent.resultBadgeLabel,
                style: AppTypography.labelUppercaseSm.copyWith(
                  color: AppColors.bodyMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value.clamp(0, 1), child: child),
                  );
                },
                child: Text(
                  LevelContent.cefrLevels[levelIndex],
                  style: AppTypography.displayLg.copyWith(
                    fontSize: 72,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                LevelTestContent.resultInfos[levelIndex],
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.bodyMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: onConfirm,
                child: const Text(LevelTestContent.confirmLabel),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onChooseManually,
                  child: const Text(LevelTestContent.chooseManuallyLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
