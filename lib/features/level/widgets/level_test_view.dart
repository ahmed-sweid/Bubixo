import 'package:flutter/material.dart';

import '../../../core/constants/level_content.dart';
import '../level_test_state.dart';
import 'level_test_question_view.dart';
import 'level_test_result_view.dart';

/// Seviye testi oturumu: sorular arasında ilerler, bitince sonucu hesaplar
/// ve callback'lerle dışarı bildirir.
class LevelTestView extends StatefulWidget {
  const LevelTestView({
    super.key,
    required this.questions,
    this.onCompleted,
    this.onChooseManually,
  });

  final List<LevelTestQuestion> questions;
  final ValueChanged<int>? onCompleted;
  final VoidCallback? onChooseManually;

  @override
  State<LevelTestView> createState() => _LevelTestViewState();
}

class _LevelTestViewState extends State<LevelTestView> {
  int _questionIndex = 0;
  late final List<int?> _answers = List<int?>.filled(
    widget.questions.length,
    null,
  );
  int? _resultIndex;

  int? get _selectedOption => _answers[_questionIndex];

  void _selectOption(int optionIndex) {
    setState(() => _answers[_questionIndex] = optionIndex);
  }

  void _advance() {
    if (_selectedOption == null) {
      return;
    }
    if (_questionIndex == widget.questions.length - 1) {
      setState(() => _resultIndex = _computeResult());
      return;
    }
    setState(() => _questionIndex++);
  }

  /// Doğru sayısına göre önerilen CEFR basamağı:
  /// 0 doğru → A1; n doğru → (n-1). basamak (6 doğru → C2).
  int _computeResult() {
    int correctCount = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (_answers[i] == widget.questions[i].correctIndex) {
        correctCount++;
      }
    }
    if (correctCount == 0) {
      return 0;
    }
    return (correctCount - 1).clamp(0, LevelContent.cefrLevels.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final int? resultIndex = _resultIndex;
    if (resultIndex != null) {
      return LevelTestResultView(
        levelIndex: resultIndex,
        onConfirm: () => widget.onCompleted?.call(resultIndex),
        onChooseManually: widget.onChooseManually,
      );
    }
    return LevelTestQuestionView(
      question: widget.questions[_questionIndex],
      index: _questionIndex,
      total: widget.questions.length,
      selectedOption: _selectedOption,
      onSelectOption: _selectOption,
      onContinue: _advance,
    );
  }
}
