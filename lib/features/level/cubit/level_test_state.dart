part of 'level_test_cubit.dart';

sealed class LevelTestState extends Equatable {
  const LevelTestState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LevelTestLoading extends LevelTestState {
  const LevelTestLoading();
}

final class LevelTestError extends LevelTestState {
  const LevelTestError();
}

final class LevelTestEmpty extends LevelTestState {
  const LevelTestEmpty();
}

final class LevelTestReady extends LevelTestState {
  const LevelTestReady({
    required this.questions,
    this.questionIndex = 0,
    this.answers = const <int?>[],
  });

  final List<LevelTestQuestion> questions;
  final int questionIndex;
  final List<int?> answers;

  int? get selectedOption =>
      questionIndex < answers.length ? answers[questionIndex] : null;

  @override
  List<Object?> get props => <Object?>[questions, questionIndex, answers];
}

final class LevelTestResult extends LevelTestState {
  const LevelTestResult({required this.levelIndex});

  final int levelIndex;

  @override
  List<Object?> get props => <Object?>[levelIndex];
}
