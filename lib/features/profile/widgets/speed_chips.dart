import 'package:flutter/material.dart';

import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';

/// Sesli okuma hızı seçenekleri.
class SpeedChips extends StatelessWidget {
  const SpeedChips({super.key, required this.speed, required this.onChanged});

  final double speed;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: <Widget>[
        for (final double value in ProfileContent.audioSpeeds)
          ChoiceChip(
            label: Text(
              ProfileContent.speedTemplate.replaceFirst(
                '{speed}',
                value.toStringAsFixed(2),
              ),
            ),
            selected: value == speed,
            onSelected: (bool _) => onChanged(value),
            labelStyle: AppTypography.bodySm.copyWith(
              color: value == speed
                  ? AppColors.primaryPressed
                  : AppColors.bodyMuted,
            ),
            side: BorderSide(
              color: value == speed ? AppColors.primary : AppColors.hairline,
              width: AppSizes.borderWidth,
            ),
          ),
      ],
    );
  }
}
