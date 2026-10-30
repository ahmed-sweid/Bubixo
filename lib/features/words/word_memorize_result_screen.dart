import 'package:flutter/material.dart';

import '../../core/constants/words_content.dart';
import '../../core/design_system.dart';
import '../../core/models/word_models.dart';
import 'widgets/memorize_result_summary.dart';
import 'widgets/memorize_word_section.dart';
import 'word_memorize_screen.dart';

/// Ezberleme oturumu sonuç sayfası: özet ve bilinen/bilinmeyen kelimeler.
///
/// ANA SAYFAYA DÖN birikmiş bilinen id'leriyle geri döner; DEVAM ET yalnızca
/// bilinmeyen kelimelerle yeni oturum açar.
class WordMemorizeResultScreen extends StatelessWidget {
  const WordMemorizeResultScreen({
    super.key,
    required this.knownWords,
    required this.unknownWords,
    required this.allKnownIds,
  });

  final List<Word> knownWords;
  final List<Word> unknownWords;

  /// Önceki oturumlar dahil tüm bilinen kelime id'leri (ana sayfaya iletilir).
  final List<String> allKnownIds;

  int get _total => knownWords.length + unknownWords.length;

  void _goHome(BuildContext context) {
    Navigator.of(context).pop(allKnownIds);
  }

  void _continue(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<List<String>>(
        builder: (_) => WordMemorizeScreen(
          words: unknownWords,
          initialKnownIds: allKnownIds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text(WordsContent.memorizeResultTitle)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    MemorizeResultSummary(
                      total: _total,
                      known: knownWords.length,
                      unknown: unknownWords.length,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      WordsContent.resultSummaryTemplate
                          .replaceFirst('{total}', '$_total')
                          .replaceFirst('{known}', '${knownWords.length}'),
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (knownWords.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      MemorizeWordSection(
                        title: WordsContent.knownSectionLabel,
                        words: knownWords,
                      ),
                    ],
                    if (unknownWords.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.lg),
                      MemorizeWordSection(
                        title: WordsContent.unknownSectionLabel,
                        words: unknownWords,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _goHome(context),
                      child: const Text(WordsContent.homeCtaLabel),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: unknownWords.isEmpty
                          ? null
                          : () => _continue(context),
                      child: const Text(WordsContent.continueCtaLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
