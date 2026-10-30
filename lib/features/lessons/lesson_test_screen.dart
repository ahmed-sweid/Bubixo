import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../../core/models/lesson_models.dart';
import 'widgets/lesson_test_question_view.dart';
import 'widgets/lesson_test_result_view.dart';

/// Konu testi: sorular ilerleme göstergesiyle sorulur, bitince doğru/yanlış
/// sayıları gösterilir. Sorular ve sonuç yerel oturum durumudur.
class LessonTestScreen extends StatefulWidget {
  const LessonTestScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonTestScreen> createState() => _LessonTestScreenState();
}

class _LessonTestScreenState extends State<LessonTestScreen> {
  int _questionIndex = 0;
  late final List<int?> _answers = List<int?>.filled(
    widget.lesson.questions.length,
    null,
  );
  bool _finished = false;

  int get _correctCount {
    int count = 0;
    for (int i = 0; i < widget.lesson.questions.length; i++) {
      if (_answers[i] == widget.lesson.questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  int get _wrongCount => widget.lesson.questions.length - _correctCount;

  int? get _selectedOption => _answers[_questionIndex];

  bool get _isLastQuestion =>
      _questionIndex == widget.lesson.questions.length - 1;

  void _selectOption(int optionIndex) {
    setState(() => _answers[_questionIndex] = optionIndex);
  }

  void _advance() {
    if (_selectedOption == null) {
      return;
    }
    if (_isLastQuestion) {
      // TODO(backend): sonucu lesson_progress tablosuna kaydet.
      setState(() => _finished = true);
      return;
    }
    setState(() => _questionIndex++);
  }

  void _retry() {
    setState(() {
      for (int i = 0; i < _answers.length; i++) {
        _answers[i] = null;
      }
      _questionIndex = 0;
      _finished = false;
    });
  }

  void _backToHome() {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: SafeArea(
        child: _finished
            ? LessonTestResultView(
                correctCount: _correctCount,
                wrongCount: _wrongCount,
                onRetry: _retry,
                onBackToHome: _backToHome,
              )
            : LessonTestQuestionView(
                question: widget.lesson.questions[_questionIndex],
                questionIndex: _questionIndex,
                questionCount: widget.lesson.questions.length,
                selectedOption: _selectedOption,
                onSelectOption: _selectOption,
                onAdvance: _advance,
              ),
      ),
    );
  }
}
