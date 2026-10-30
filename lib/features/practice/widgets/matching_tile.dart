import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/design_system.dart';

/// Eşleştirme pratiğindeki tek terim/anlam kutusu.
class MatchingTile extends StatelessWidget {
  const MatchingTile({
    super.key,
    required this.label,
    required this.selected,
    required this.matched,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool matched;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected || matched ? AppColors.primarySoft : AppColors.canvas,
          borderRadius: AppRadius.roundedSm,
          border: Border.all(
            color: selected || matched ? AppColors.primary : AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySm.copyWith(
                  color: selected || matched
                      ? AppColors.primaryPressed
                      : AppColors.body,
                ),
              ),
            ),
            if (matched) ...<Widget>[
              const SizedBox(width: AppSpacing.xxs),
              const Icon(
                Iconsax.tick_circle,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
