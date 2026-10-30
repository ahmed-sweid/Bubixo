import 'package:flutter/material.dart';

import '../../../core/design_system.dart';
import '../../../core/models/word_models.dart';

/// Sonuç sayfasındaki bilinen/bilinmeyen kelime listesi.
class MemorizeWordSection extends StatelessWidget {
  const MemorizeWordSection({
    super.key,
    required this.title,
    required this.words,
  });

  final String title;
  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          title,
          style: AppTypography.labelUppercaseSm.copyWith(
            color: AppColors.bodyMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: AppColors.hairline,
              width: AppSizes.borderWidth,
            ),
          ),
          child: Column(
            children: <Widget>[
              for (int index = 0; index < words.length; index++) ...<Widget>[
                if (index > 0) const Divider(height: AppSizes.hairlineWidth),
                _WordRow(word: words[index]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            word.term,
            style: AppTypography.bodyMd.copyWith(color: AppColors.inkDisplay),
          ),
          Text(
            word.translation,
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
        ],
      ),
    );
  }
}
