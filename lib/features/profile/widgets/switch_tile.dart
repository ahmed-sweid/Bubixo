import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Açık/kapalı tercih satırı.
class SwitchTile extends StatelessWidget {
  const SwitchTile({
    super.key,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.body),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
