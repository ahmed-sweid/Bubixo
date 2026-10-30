import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Çoktan seçmeli soru seçenek kartı; seçili durumda yeşil soft dolgu ve
/// yeşil kenarlık alır. Seviye testi ve ders testleri ortak kullanır.
class OptionCard extends StatelessWidget {
  const OptionCard({
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
      borderRadius: AppRadius.roundedSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: AppSizes.inputHeight + 8),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.base,
          horizontal: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.canvas,
          borderRadius: AppRadius.roundedSm,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodyLg.copyWith(
            color: selected ? AppColors.primaryPressed : AppColors.body,
          ),
        ),
      ),
    );
  }
}
