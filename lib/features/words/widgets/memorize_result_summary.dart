import 'package:flutter/material.dart';

import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';

/// Ezberleme sonucunun özet kartı: toplam, bilinen ve bilinmeyen sayıları.
class MemorizeResultSummary extends StatelessWidget {
  const MemorizeResultSummary({
    super.key,
    required this.total,
    required this.known,
    required this.unknown,
  });

  final int total;
  final int known;
  final int unknown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _SummaryTile(
              value: '$total',
              label: WordsContent.totalLabel,
              valueColor: AppColors.inkDisplay,
            ),
          ),
          Expanded(
            child: _SummaryTile(
              value: '$known',
              label: WordsContent.knownLabel,
              valueColor: AppColors.primary,
            ),
          ),
          Expanded(
            child: _SummaryTile(
              value: '$unknown',
              label: WordsContent.unknownLabel,
              valueColor: AppColors.accentCardinal,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(value, style: AppTypography.headingMd.copyWith(color: valueColor)),
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
