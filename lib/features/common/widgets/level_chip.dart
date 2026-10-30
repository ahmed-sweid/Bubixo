import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Seviye (CEFR) filtresi için seçilebilir yuvarlak çip.
class LevelChip extends StatelessWidget {
  const LevelChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.canvas,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySm.copyWith(
            color: selected ? AppColors.primaryPressed : AppColors.bodyMuted,
          ),
        ),
      ),
    );
  }
}
