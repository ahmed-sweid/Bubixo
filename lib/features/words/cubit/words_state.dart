part of 'words_cubit.dart';

sealed class WordsState extends Equatable {
  const WordsState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class WordsLoading extends WordsState {
  const WordsLoading();
}

final class WordsError extends WordsState {
  const WordsError();
}

final class WordsEmpty extends WordsState {
  const WordsEmpty();
}

final class WordsReady extends WordsState {
  const WordsReady({
    required this.words,
    this.suggestedWords = const <PoolWord>[],
    this.translation,
    this.enToTr = true,
  });

  final List<Word> words;
  final List<PoolWord> suggestedWords;
  final WordTranslation? translation;
  final bool enToTr;

  @override
  List<Object?> get props => <Object?>[
    words,
    suggestedWords,
    translation,
    enToTr,
  ];
}
