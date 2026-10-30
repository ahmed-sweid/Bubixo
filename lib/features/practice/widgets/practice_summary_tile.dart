import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Sonuç kartındaki tek sayı + etiket sütunu.
class PracticeSummaryTile extends StatelessWidget {
  const PracticeSummaryTile({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: AppTypography.headingMd.copyWith(color: color)),
        Text(
          label,
          style: AppTypography.labelUppercaseSm.copyWith(
            color: AppColors.bodyMuted,
          ),
        ),
      ],
    );
  }
}
