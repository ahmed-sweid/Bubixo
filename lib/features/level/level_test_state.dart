/// Seviye belirleme testinin cubit'e hazır durum modeli.
class LevelTestQuestion {
  const LevelTestQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

sealed class LevelTestState {
  const LevelTestState();
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
  const LevelTestReady({required this.questions});

  final List<LevelTestQuestion> questions;
}
