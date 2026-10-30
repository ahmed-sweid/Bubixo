import 'package:flutter/material.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import 'practice_launcher.dart';
import 'widgets/practice_session_frame.dart';
import 'widgets/sentence_token_chip.dart';

/// 7.3 — Karışık kelimeleri doğru sıraya dizme pratiği.
class SentenceOrderScreen extends StatefulWidget {
  const SentenceOrderScreen({super.key, required this.questions});

  final List<SentenceOrderQuestion> questions;

  @override
  State<SentenceOrderScreen> createState() => _SentenceOrderScreenState();
}

class _SentenceOrderScreenState extends State<SentenceOrderScreen> {
  static const PracticeType _type = PracticeType.sentenceOrder;

  List<SentenceOrderQuestion> get _questions => widget.questions;

  int _index = 0;
  late List<int> _pool;
  late List<int> _placed;
  bool _checked = false;
  bool _isCorrect = false;
  int _correctCount = 0;

  SentenceOrderQuestion get _question => _questions[_index];

  bool get _isLast => _index == _questions.length - 1;

  @override
  void initState() {
    super.initState();
    _resetQuestion();
  }

  void _resetQuestion() {
    _pool = List<int>.generate(_question.tokens.length, (int i) => i);
    _placed = <int>[];
    _checked = false;
    _isCorrect = false;
  }

  void _place(int tokenIndex) {
    if (_checked) {
      return;
    }
    setState(() {
      _pool.remove(tokenIndex);
      _placed.add(tokenIndex);
    });
  }

  void _remove(int tokenIndex) {
    if (_checked) {
      return;
    }
    setState(() {
      _placed.remove(tokenIndex);
      _pool.add(tokenIndex);
    });
  }

  void _check() {
    final String attempt = _placed
        .map((int index) => _question.tokens[index])
        .join(' ');
    final bool correct = attempt == _question.answer.join(' ');
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
        retryBuilder: (_) => SentenceOrderScreen(questions: _questions),
      );
      return;
    }
    setState(() {
      _index++;
      _resetQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PracticeSessionFrame(
      type: _type,
      index: _index,
      total: _questions.length,
      footer: _buildFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            PracticeContent.sentenceOrderInstruction,
            style: AppTypography.headingSm.copyWith(
              color: AppColors.inkDisplay,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            PracticeContent.sentenceOrderHintTemplate.replaceFirst(
              '{hint}',
              _question.hint,
            ),
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            constraints: const BoxConstraints(minHeight: 88),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceHover,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(
                color: AppColors.hairline,
                width: AppSizes.borderWidth,
              ),
            ),
            child: _placed.isEmpty
                ? Center(
                    child: Text(
                      PracticeContent.sentenceEmptyHint,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                  )
                : Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: <Widget>[
                      for (final int tokenIndex in _placed)
                        SentenceTokenChip(
                          label: _question.tokens[tokenIndex],
                          placed: true,
                          onTap: () => _remove(tokenIndex),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            PracticeContent.sentencePoolHint,
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              for (final int tokenIndex in _pool)
                SentenceTokenChip(
                  label: _question.tokens[tokenIndex],
                  placed: false,
                  onTap: () => _place(tokenIndex),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
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
                    _question.answer.join(' '),
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ElevatedButton(
          onPressed: _checked
              ? _advance
              : _placed.length == _question.tokens.length
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
    );
  }
}
