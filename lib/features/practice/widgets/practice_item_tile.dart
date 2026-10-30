import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/design_system.dart';
import '../../../core/models/practice_models.dart';

/// Pratik detayındaki tek içerik satırı; tamamlananlar tik ile işaretlenir.
class PracticeItemTile extends StatelessWidget {
  const PracticeItemTile({super.key, required this.item, this.onTap});

  final PracticeItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.sm,
          AppSpacing.base,
          AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.surfaceHover,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${item.order}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.bodyMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.title,
                style: AppTypography.bodySm.copyWith(color: AppColors.body),
              ),
            ),
            Icon(
              item.completed ? Iconsax.tick_circle : Iconsax.arrow_right_2,
              size: 20,
              color: item.completed ? AppColors.primary : AppColors.bodyMuted,
            ),
          ],
        ),
      ),
    );
  }
}
