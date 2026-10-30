import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/profile_models.dart';

/// Mevcut CEFR seviyesi ve seviye testine yeniden girme eylemi.
class ProfileLevelCard extends StatelessWidget {
  const ProfileLevelCard({super.key, required this.profile, this.onRetakeTest});

  final UserProfile profile;
  final VoidCallback? onRetakeTest;

  @override
  Widget build(BuildContext context) {
    final int levelIndex = profile.levelIndex.clamp(
      0,
      LevelContent.cefrLevels.length - 1,
    );
    final String levelCode = LevelContent.cefrLevels[levelIndex];
    final String levelLabel = LevelContent.cefrLevelDescriptions[levelIndex];

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
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySoft,
                ),
                child: Text(
                  levelCode,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.primaryPressed,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      ProfileContent.currentLevelLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      levelLabel,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          OutlinedButton.icon(
            onPressed: onRetakeTest,
            icon: const Icon(Iconsax.convert, size: 18),
            label: const Text(ProfileContent.retakeTestCtaLabel),
          ),
        ],
      ),
    );
  }
}
