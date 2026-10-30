import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';
import '../words_state.dart';

/// Hızlı çeviri kartı: dil yönü, giriş alanı ve isteğe bağlı sonuç.
class TranslateCard extends StatelessWidget {
  const TranslateCard({
    super.key,
    required this.controller,
    required this.result,
    this.enToTr = true,
    this.onSwap,
    this.onTranslate,
    this.onClearResult,
    this.onAddToMemorize,
  });

  final TextEditingController controller;
  final WordTranslation? result;
  final bool enToTr;
  final VoidCallback? onSwap;
  final ValueChanged<String>? onTranslate;
  final VoidCallback? onClearResult;
  final VoidCallback? onAddToMemorize;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: controller,
            onSubmitted: onTranslate,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: WordsContent.translateInputHint,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: onTranslate == null
                      ? null
                      : () => onTranslate!(controller.text),
                  child: const Text(WordsContent.translateCtaLabel),
                ),
              ),
              IconButton(
                onPressed: onSwap,
                tooltip: WordsContent.swapLanguagesTooltip,
                icon: const Icon(Iconsax.arrow_swap_horizontal, size: 22),
              ),
            ],
          ),
          if (result != null) ...<Widget>[
            const SizedBox(height: AppSpacing.base),
            _ResultCard(
              result: result!,
              onRemove: onClearResult,
              onAddToMemorize: onAddToMemorize,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    this.onRemove,
    this.onAddToMemorize,
  });

  final WordTranslation result;
  final VoidCallback? onRemove;
  final VoidCallback? onAddToMemorize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: AppRadius.roundedSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      result.term,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      result.translation ?? WordsContent.notFoundMessage,
                      style: AppTypography.bodyLg.copyWith(
                        color: result.translation == null
                            ? AppColors.bodyMuted
                            : AppColors.primaryPressed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(
                    Iconsax.close_circle,
                    size: 22,
                    color: AppColors.bodyMuted,
                  ),
                ),
              ),
            ],
          ),
          if (onAddToMemorize != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: onAddToMemorize,
              child: const Text(WordsContent.addToMemorizeLabel),
            ),
          ],
        ],
      ),
    );
  }
}
