import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/words_content.dart';
import '../../core/design_system.dart';
import '../../core/models/word_models.dart';
import 'widgets/dashed_progress.dart';
import 'word_memorize_result_screen.dart';

/// Kelime ezberleme oturumu: dokununca dönen kart, sağa kaydırınca "bildim",
/// sola kaydırınca "bilemedim".
///
/// Oturum bitince bilinen kelime id'leriyle geri döner; durum güncellemesi
/// çağıran sayfada yapılır.
/// TODO(backend): bilinen kelimeler words.status = 'memorized' olarak
/// Supabase'e yazılacak.
class WordMemorizeScreen extends StatefulWidget {
  const WordMemorizeScreen({
    super.key,
    required this.words,
    this.initialKnownIds = const <String>[],
  });

  final List<Word> words;

  /// Devam oturumlarında önceki oturumlardan birikmiş bilinen kelimeler;
  /// sonuç sayfasından ana sayfaya dönüşte toplu olarak iletilir.
  final List<String> initialKnownIds;

  @override
  State<WordMemorizeScreen> createState() => _WordMemorizeScreenState();
}

class _WordMemorizeScreenState extends State<WordMemorizeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exitController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  int _index = 0;
  double _dragX = 0;
  bool _swipeKnown = true;
  late final List<String> _knownIds = <String>[...widget.initialKnownIds];

  int get _total => widget.words.length;
  bool get _finished => _index >= _total;

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  void _onDragEnd() {
    if (_dragX.abs() >= 100) {
      _swipeKnown = _dragX > 0;
      _exitController.forward(from: 0).then((_) => _advance());
    } else {
      setState(() => _dragX = 0);
    }
  }

  void _advance() {
    if (!mounted) {
      return;
    }
    final bool lastCard = _index + 1 >= _total;
    setState(() {
      if (_swipeKnown) {
        _knownIds.add(widget.words[_index].id);
      }
      _index++;
      _dragX = 0;
    });
    _exitController.value = 0;
    if (lastCard) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openResult());
    }
  }

  void _openResult() {
    if (!mounted) {
      return;
    }
    final List<Word> knownWords = widget.words
        .where((Word word) => _knownIds.contains(word.id))
        .toList();
    final List<Word> unknownWords = widget.words
        .where((Word word) => !_knownIds.contains(word.id))
        .toList();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<List<String>>(
        builder: (_) => WordMemorizeResultScreen(
          knownWords: knownWords,
          unknownWords: unknownWords,
          allKnownIds: _knownIds,
        ),
      ),
    );
  }

  void _finish() {
    Navigator.of(context).pop(_knownIds);
  }

  @override
  Widget build(BuildContext context) {
    final String progressLabel = WordsContent.memorizeProgressTemplate
        .replaceFirst('{done}', '${_index.clamp(0, _total)}')
        .replaceFirst('{total}', '$_total');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text(WordsContent.memorizeScreenTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: DashedProgress(done: _index, total: _total),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    progressLabel,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.bodyMuted,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: _total == 0
                    ? Center(
                        child: Text(
                          WordsContent.memorizeEmptyMessage,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.bodyMuted,
                          ),
                        ),
                      )
                    : _finished
                    ? Center(
                        child: Text(
                          WordsContent.memorizeSummaryTemplate
                              .replaceFirst('{known}', '${_knownIds.length}')
                              .replaceFirst(
                                '{unknown}',
                                '${_total - _knownIds.length}',
                              ),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.bodyMuted,
                          ),
                        ),
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: AspectRatio(
                            aspectRatio: 0.9,
                            child: _buildCard(widget.words[_index]),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _finish,
                  child: const Text(WordsContent.memorizeFinishCtaLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Word word) {
    return AnimatedBuilder(
      animation: _exitController,
      builder: (BuildContext context, Widget? child) {
        final double exit = _exitController.value;
        final bool knownEffect = exit > 0 ? _swipeKnown : _dragX >= 0;
        final double effect = ((_dragX.abs() / 120) + exit).clamp(0.0, 1.0);
        final double offsetX = _dragX + exit * 600 * (_swipeKnown ? 1 : -1);

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Opacity(
                opacity: effect,
                child: Container(
                  decoration: BoxDecoration(
                    color: knownEffect
                        ? AppColors.primary
                        : AppColors.accentCardinal,
                    borderRadius: AppRadius.roundedLg,
                  ),
                  child: Center(
                    child: Icon(
                      knownEffect ? Iconsax.tick_circle : Iconsax.close_circle,
                      size: 64,
                      color: AppColors.canvas,
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: 1 - exit,
              child: Transform.translate(
                offset: Offset(offsetX, 0),
                child: Transform.rotate(
                  angle: offsetX / 1200,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      if (exit == 0) {
                        setState(() => _dragX += details.delta.dx);
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      if (exit == 0) {
                        _onDragEnd();
                      }
                    },
                    child: FlipCard(
                      key: ValueKey<String>(word.id),
                      front: _cardContent(word, false),
                      back: _cardContent(word, true),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _cardContent(Word word, bool showBack) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: showBack
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  word.translation,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.primaryPressed,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  word.term,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingMd.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  WordsContent.cardFlipHint,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
              ],
            ),
    );
  }
}
