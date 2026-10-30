import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/profile_models.dart';

/// Günlük çalışma hedefi ve bugün tamamlanan etkinlik sayısı.
class ProfileGoalCard extends StatelessWidget {
  const ProfileGoalCard({
    super.key,
    required this.settings,
    required this.doneToday,
    this.onChangeGoal,
  });

  final ProfileSettings settings;
  final int doneToday;
  final VoidCallback? onChangeGoal;

  static const double _ringSize = 72;

  @override
  Widget build(BuildContext context) {
    final int target = settings.dailyGoal.count;
    final double progress = (doneToday / target).clamp(0.0, 1.0);
    final String goalLabel = ProfileContent.goalLabels[settings.dailyGoal]!;
    final String progressLabel = ProfileContent.goalProgressTemplate
        .replaceFirst('{done}', '$doneToday')
        .replaceFirst('{total}', '$target')
        .replaceFirst('{unit}', ProfileContent.goalUnit);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: _ringSize,
                height: _ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: _ringSize,
                      height: _ringSize,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: AppColors.hairline,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      '$doneToday/$target',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      goalLabel,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.primaryPressed,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      progressLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      ProfileContent.goalHint,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.bodySoft,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          TextButton.icon(
            onPressed: onChangeGoal,
            icon: const Icon(Iconsax.setting, size: 18),
            label: const Text(ProfileContent.goalChangeCtaLabel),
          ),
        ],
      ),
    );
  }
}
