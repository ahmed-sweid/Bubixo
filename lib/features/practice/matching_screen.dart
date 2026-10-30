import 'package:flutter/material.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import 'practice_launcher.dart';
import 'widgets/matching_tile.dart';
import 'widgets/practice_session_frame.dart';

/// 7.7 — Eşleştirme pratiği: İngilizce terim ile Türkçe anlamı eşleştirilir.
///
/// Her set tek soru sayılır; hatalı deneme yapılan set yanlış olarak işlenir.
class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key, required this.questions});

  final List<MatchingQuestion> questions;

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  static const PracticeType _type = PracticeType.matching;

  List<MatchingQuestion> get _questions => widget.questions;

  int _index = 0;
  final Set<String> _matched = <String>{};
  String? _selectedTerm;
  String? _selectedMeaning;
  bool _mismatch = false;
  bool _mistakeThisRound = false;
  bool _scored = false;
  int _correctCount = 0;

  MatchingQuestion get _question => _questions[_index];

  bool get _isLast => _index == _questions.length - 1;

  bool get _complete => _matched.length == _question.pairs.length;

  void _selectTerm(String pairId) {
    if (_complete || _matched.contains(pairId)) {
      return;
    }
    setState(() {
      _selectedTerm = _selectedTerm == pairId ? null : pairId;
      _mismatch = false;
      _resolveSelection();
    });
  }

  void _selectMeaning(String pairId) {
    if (_complete || _matched.contains(pairId)) {
      return;
    }
    setState(() {
      _selectedMeaning = _selectedMeaning == pairId ? null : pairId;
      _mismatch = false;
      _resolveSelection();
    });
  }

  void _resolveSelection() {
    if (_selectedTerm == null || _selectedMeaning == null) {
      return;
    }
    if (_selectedTerm == _selectedMeaning) {
      _matched.add(_selectedTerm!);
      _selectedTerm = null;
      _selectedMeaning = null;
      if (_complete && !_scored) {
        _scored = true;
        if (!_mistakeThisRound) {
          _correctCount++;
        }
      }
    } else {
      _mismatch = true;
      _mistakeThisRound = true;
      _selectedTerm = null;
      _selectedMeaning = null;
    }
  }

  void _advance() {
    if (_isLast) {
      openPracticeResult(
        context,
        _type,
        total: _questions.length,
        correct: _correctCount,
        retryBuilder: (_) => MatchingScreen(questions: _questions),
      );
      return;
    }
    setState(() {
      _index++;
      _matched.clear();
      _selectedTerm = null;
      _selectedMeaning = null;
      _mismatch = false;
      _mistakeThisRound = false;
      _scored = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<MatchingPair> meanings = _question.pairs.reversed.toList(
      growable: false,
    );
    final String progress = PracticeContent.matchingProgressTemplate
        .replaceFirst('{matched}', '${_matched.length}')
        .replaceFirst('{total}', '${_question.pairs.length}');

    return PracticeSessionFrame(
      type: _type,
      index: _index,
      total: _questions.length,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (_complete) ...<Widget>[
            const PracticeFeedbackBanner(
              correct: true,
              message: PracticeContent.matchingComplete,
            ),
            const SizedBox(height: AppSpacing.md),
          ] else if (_mismatch) ...<Widget>[
            const PracticeFeedbackBanner(
              correct: false,
              message: PracticeContent.matchingMismatch,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ElevatedButton(
            onPressed: _complete ? _advance : null,
            child: Text(
              _isLast
                  ? PracticeContent.finishCtaLabel
                  : PracticeContent.nextCtaLabel,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            PracticeContent.matchingInstruction,
            style: AppTypography.headingSm.copyWith(
              color: AppColors.inkDisplay,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            progress,
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    for (final MatchingPair pair in _question.pairs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MatchingTile(
                          label: pair.term,
                          selected: _selectedTerm == pair.id,
                          matched: _matched.contains(pair.id),
                          onTap: _complete ? null : () => _selectTerm(pair.id),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  children: <Widget>[
                    for (final MatchingPair pair in meanings)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: MatchingTile(
                          label: pair.meaning,
                          selected: _selectedMeaning == pair.id,
                          matched: _matched.contains(pair.id),
                          onTap: _complete
                              ? null
                              : () => _selectMeaning(pair.id),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
