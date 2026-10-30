import '../../core/models/word_models.dart';

/// Kelimeler sekmesinin Cubit'e hazır durum kümesi.
sealed class WordsState {
  const WordsState();
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
}

/// Hızlı çeviri kartının gösterdiği son sonuç.
class WordTranslation {
  const WordTranslation({required this.term, this.translation});

  final String term;
  final String? translation;
}
