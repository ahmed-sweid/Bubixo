import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import '../common/widgets/option_card.dart';
import 'practice_launcher.dart';
import 'widgets/practice_session_frame.dart';

/// 7.6 — Dinleme pratiği.
///
/// Ses oynatma şimdilik 2 saniyelik simülasyondur; gerçek ses dosyası/TTS
/// backend veya asset ile eklenecek.
/// TODO(backend): dinleme sesi ve tekrar dinleme hakkı.
class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key, required this.questions});

  final List<ListeningQuestion> questions;

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen>
    with SingleTickerProviderStateMixin {
  static const PracticeType _type = PracticeType.listening;

  List<ListeningQuestion> get _questions => widget.questions;

  late final AnimationController _player = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  int _index = 0;
  int? _selected;
  bool _hasPlayed = false;
  bool _checked = false;
  bool _isCorrect = false;
  int _correctCount = 0;

  ListeningQuestion get _question => _questions[_index];

  bool get _isLast => _index == _questions.length - 1;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _play() {
    setState(() => _hasPlayed = true);
    _player.forward(from: 0);
  }

  void _select(int optionIndex) {
    if (_checked) {
      return;
    }
    setState(() => _selected = optionIndex);
  }

  void _check() {
    if (_selected == null) {
      return;
    }
    final bool correct = _selected == _question.correctIndex;
    setState(() {
      _checked = true;
      _isCorrect = correct;
      if (correct) {
        _correctCount++;
      }
    });
  }

  void _advance() {
    if (_isLast) {
      openPracticeResult(
        context,
        _type,
        total: _questions.length,
        correct: _correctCount,
        retryBuilder: (_) => ListeningScreen(questions: _questions),
      );
      return;
    }
    _player.stop();
    setState(() {
      _index++;
      _selected = null;
      _hasPlayed = false;
      _checked = false;
      _isCorrect = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PracticeSessionFrame(
      type: _type,
      index: _index,
      total: _questions.length,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_checked) ...<Widget>[
            PracticeFeedbackBanner(
              correct: _isCorrect,
              message: _isCorrect
                  ? PracticeContent.correctFeedback
                  : PracticeContent.wrongFeedbackTemplate.replaceFirst(
                      '{answer}',
                      _question.options[_question.correctIndex],
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ElevatedButton(
            onPressed: _checked
                ? _advance
                : _hasPlayed && _selected != null
                ? _check
                : null,
            child: Text(
              _checked
                  ? _isLast
                        ? PracticeContent.finishCtaLabel
                        : PracticeContent.nextCtaLabel
                  : PracticeContent.checkCtaLabel,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            PracticeContent.listeningInstruction,
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
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
                Text(
                  PracticeContent.listeningPrompt,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AnimatedBuilder(
                  animation: _player,
                  builder: (BuildContext context, Widget? child) {
                    final bool playing = _player.isAnimating;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: _play,
                          icon: const Icon(Iconsax.play, size: 20),
                          label: Text(
                            playing
                                ? PracticeContent.listeningPlayingLabel
                                : _hasPlayed
                                ? PracticeContent.listeningReplayLabel
                                : PracticeContent.listeningPlayLabel,
                          ),
                        ),
                        if (playing) ...<Widget>[
                          const SizedBox(height: AppSpacing.md),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            child: LinearProgressIndicator(
                              value: _player.value,
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < _question.options.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i < _question.options.length - 1 ? AppSpacing.base : 0,
              ),
              child: OptionCard(
                label: _question.options[i],
                selected: _selected == i,
                onTap: () => _select(i),
              ),
            ),
        ],
      ),
    );
  }
}
