import 'package:flutter/material.dart';

import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/word_models.dart';

/// Kelime listesinin ezberlemede/ezberlenmiş dağılımını gösteren kart.
class WordsStatsCard extends StatelessWidget {
  const WordsStatsCard({super.key, required this.words});

  final List<Word> words;

  @override
  Widget build(BuildContext context) {
    final int learning = words
        .where((Word word) => word.status == WordStatus.learning)
        .length;
    final int memorized = words.length - learning;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  dotColor: AppColors.primary,
                  value: '$learning',
                  label: WordsContent.learningLabel,
                ),
              ),
              Container(
                width: AppSizes.hairlineWidth,
                height: 44,
                color: AppColors.hairline,
              ),
              Expanded(
                child: _StatTile(
                  dotColor: AppColors.accentBee,
                  value: '$memorized',
                  label: WordsContent.memorizedLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: Stack(
                children: <Widget>[
                  const ColoredBox(
                    color: AppColors.hairline,
                    child: SizedBox.expand(),
                  ),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: words.isEmpty ? 0 : memorized / words.length,
                    child: const ColoredBox(
                      color: AppColors.primary,
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.dotColor,
    required this.value,
    required this.label,
  });

  final Color dotColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.headingMd.copyWith(
                color: AppColors.inkDisplay,
              ),
            ),
          ],
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.labelUppercaseSm.copyWith(
            color: AppColors.bodyMuted,
          ),
        ),
      ],
    );
  }
}
