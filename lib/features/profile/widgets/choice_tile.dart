import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/design_system.dart';

/// Tek seçim satırı: başlık ve seçiliyse onay işareti.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.base,
          horizontal: AppSpacing.xxs,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(
                  color: selected ? AppColors.primaryPressed : AppColors.body,
                ),
              ),
            ),
            Icon(
              selected ? Iconsax.tick_circle : Iconsax.activity,
              size: 20,
              color: selected ? AppColors.primary : AppColors.bodySoft,
            ),
          ],
        ),
      ),
    );
  }
}
