import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/models/level_test_models.dart';

part 'level_test_state.dart';

/// Seviye belirleme testinin oturum yönetimi: sorular arasında ilerleme,
/// cevap toplama ve sonuç hesaplama. Veri katmanı bağlanınca sorular bu
/// cubit üzerinden yüklenecek.
class LevelTestCubit extends Cubit<LevelTestState> {
  LevelTestCubit({LevelTestState initialState = const LevelTestLoading()})
    : super(initialState);

  void selectOption(int optionIndex) {
    final LevelTestState current = state;
    if (current is! LevelTestReady) {
      return;
    }
    final List<int?> answers = List<int?>.generate(
      current.questions.length,
      (int index) =>
          index < current.answers.length ? current.answers[index] : null,
    );
    answers[current.questionIndex] = optionIndex;
    emit(
      LevelTestReady(
        questions: current.questions,
        questionIndex: current.questionIndex,
        answers: answers,
      ),
    );
  }

  void advance() {
    final LevelTestState current = state;
    if (current is! LevelTestReady || current.selectedOption == null) {
      return;
    }
    if (current.questionIndex >= current.questions.length - 1) {
      emit(LevelTestResult(levelIndex: _computeResult(current)));
      return;
    }
    emit(
      LevelTestReady(
        questions: current.questions,
        questionIndex: current.questionIndex + 1,
        answers: current.answers,
      ),
    );
  }

  /// Doğru sayısına göre önerilen CEFR basamağı:
  /// 0 doğru → A1; n doğru → (n-1). basamak (6 doğru → C2).
  int _computeResult(LevelTestReady session) {
    int correctCount = 0;
    for (int index = 0; index < session.questions.length; index++) {
      final int? answer = index < session.answers.length
          ? session.answers[index]
          : null;
      if (answer == session.questions[index].correctIndex) {
        correctCount++;
      }
    }
    if (correctCount == 0) {
      return 0;
    }
    return (correctCount - 1).clamp(0, LevelContent.cefrLevels.length - 1);
  }
}
