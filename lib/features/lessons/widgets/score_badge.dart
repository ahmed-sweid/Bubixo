import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Test sonucundaki doğru/yanlış sayılarını gösteren kutu.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: AppSpacing.sm),
          Text('$value', style: AppTypography.displayLg.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.labelUppercaseSm.copyWith(
              color: AppColors.bodyMuted,
            ),
          ),
        ],
      ),
    );
  }
}
