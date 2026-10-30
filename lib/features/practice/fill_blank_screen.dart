import 'package:flutter/material.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import '../common/widgets/option_card.dart';
import 'practice_launcher.dart';
import 'widgets/practice_session_frame.dart';

/// 7.4 — Boşluk doldurma pratiği: cümle ve çoktan seçmeli cevaplar.
class FillBlankScreen extends StatefulWidget {
  const FillBlankScreen({super.key, required this.questions});

  final List<FillBlankQuestion> questions;

  @override
  State<FillBlankScreen> createState() => _FillBlankScreenState();
}

class _FillBlankScreenState extends State<FillBlankScreen> {
  static const PracticeType _type = PracticeType.fillBlank;

  List<FillBlankQuestion> get _questions => widget.questions;

  int _index = 0;
  int? _selected;
  bool _checked = false;
  bool _isCorrect = false;
  int _correctCount = 0;

  FillBlankQuestion get _question => _questions[_index];

  bool get _isLast => _index == _questions.length - 1;

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
        retryBuilder: (_) => FillBlankScreen(questions: _questions),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
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
                : _selected == null
                ? null
                : _check,
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
            PracticeContent.fillBlankInstruction,
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _question.sentence,
            style: AppTypography.headingSm.copyWith(
              color: AppColors.inkDisplay,
              height: 1.5,
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
