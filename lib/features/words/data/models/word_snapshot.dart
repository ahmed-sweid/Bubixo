import 'package:flutter/foundation.dart';

import '../../../../core/models/word_models.dart';

/// Kelimeler sekmesinin tek okumada gelen hâli.
///
/// İki liste birlikte üretilir çünkü ikisi de aynı kelime havuzu ve aynı
/// ilerleme satırlarından türemektedir; ayrı metodlar olsa aynı sorgular iki
/// kez atılırdı.
@immutable
class WordSnapshot {
  const WordSnapshot({
    required this.words,
    required this.suggestedWords,
  });

  /// Kullanıcının ezber listesi: `vocabulary_word_progress` satırlarının
  /// `vocabulary_words` içeriğiyle eşleşmesi.
  final List<Word> words;

  /// Havuzda olup kullanıcının listesinde olmayan kelimeler.
  final List<PoolWord> suggestedWords;

  bool get isEmpty => words.isEmpty && suggestedWords.isEmpty;
}
