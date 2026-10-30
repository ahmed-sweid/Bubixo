import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Cümle sıralama pratiğindeki kelime çipi; havuzda ve cümlede iki farklı
/// görünüm alır.
class SentenceTokenChip extends StatelessWidget {
  const SentenceTokenChip({
    super.key,
    required this.label,
    required this.placed,
    required this.onTap,
  });

  final String label;
  final bool placed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: placed ? AppColors.primarySoft : AppColors.canvas,
          borderRadius: AppRadius.roundedSm,
          border: Border.all(
            color: placed ? AppColors.primary : AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyLg.copyWith(
            color: placed ? AppColors.primaryPressed : AppColors.body,
          ),
        ),
      ),
    );
  }
}
