import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/word_models.dart';

/// Kullanıcının listesinde olmayan kelime önerileri.
class SuggestedWords extends StatelessWidget {
  const SuggestedWords({super.key, required this.words, this.onAdd});

  final List<PoolWord> words;
  final ValueChanged<PoolWord>? onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          WordsContent.suggestedSectionLabel,
          style: AppTypography.labelUppercaseSm.copyWith(
            color: AppColors.bodyMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.base),
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
                _SuggestedWordRow(
                  word: words[index],
                  onAdd: onAdd == null ? null : () => onAdd!(words[index]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestedWordRow extends StatelessWidget {
  const _SuggestedWordRow({required this.word, this.onAdd});

  final PoolWord word;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  word.term,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${word.translation} · '
                  '${LevelContent.cefrLevels[word.levelIndex]}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onAdd,
            tooltip: WordsContent.addSuggestedTooltip,
            icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
