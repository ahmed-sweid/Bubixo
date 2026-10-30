import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/lessons_content.dart';
import '../../../core/design_system.dart';

/// Seviye kartının altındaki seviye testi satırı; kilitliyse soluk görünür.
class LevelTestTile extends StatelessWidget {
  const LevelTestTile({super.key, required this.unlocked, this.onTap});

  final bool unlocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.md,
          AppSpacing.base,
          AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              unlocked ? Iconsax.cup : Iconsax.lock,
              size: 20,
              color: unlocked ? AppColors.primary : AppColors.bodySoft,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                LessonsContent.levelTestTileLabel,
                style: AppTypography.bodySm.copyWith(
                  color: unlocked ? AppColors.inkDisplay : AppColors.bodySoft,
                ),
              ),
            ),
            Icon(
              Iconsax.arrow_right_2,
              size: 16,
              color: unlocked ? AppColors.bodyMuted : AppColors.bodySoft,
            ),
          ],
        ),
      ),
    );
  }
}
