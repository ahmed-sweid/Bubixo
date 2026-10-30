import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/nav_content.dart';
import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/word_models.dart';
import 'suggested_words.dart';
import 'translate_card.dart';
import 'words_stats_card.dart';

/// Kelimeler sekmesinin hazır durum görünümü: istatistikler, hızlı çeviri,
/// öneriler ve sabit ezberleme eylemi.
class WordsView extends StatefulWidget {
  const WordsView({
    super.key,
    required this.words,
    this.suggestedWords = const <PoolWord>[],
    this.translation,
  });

  final List<Word> words;
  final List<PoolWord> suggestedWords;
  final WordTranslation? translation;

  @override
  State<WordsView> createState() => _WordsViewState();
}

class _WordsViewState extends State<WordsView> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.base,
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null,
            icon: const Icon(Iconsax.book_saved),
            label: const Text(WordsContent.startCtaLabel),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                NavContent.wordsTitle,
                                style: AppTypography.headingMd.copyWith(
                                  color: AppColors.inkDisplay,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Tooltip(
                              message: WordsContent.discoverCardTitle,
                              child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Iconsax.add_circle, size: 20),
                                label: const Text(
                                  WordsContent.discoverCtaLabel,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          NavContent.wordsDescription,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.bodyMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StatsHeaderDelegate(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: WordsStatsCard(words: widget.words),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.base,
                    ),
                    child: Text(
                      WordsContent.translateSectionLabel,
                      style: AppTypography.labelUppercaseSm.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: TranslateCard(
                      controller: _inputController,
                      result: widget.translation,
                    ),
                  ),
                ),
                if (widget.suggestedWords.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: SuggestedWords(words: widget.suggestedWords),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StatsHeaderDelegate({required this.child});

  final Widget child;

  static const double height = 140;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: ColoredBox(color: AppColors.canvas, child: child),
    );
  }

  @override
  bool shouldRebuild(_StatsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
