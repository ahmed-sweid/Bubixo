import 'package:flutter/foundation.dart';

/// Kelime modülü veri modelleri.
///
/// Alanlar Supabase şemasıyla birebir eşleşir:
/// - [Word] -> words(id, user_id, term, translation, status, created_at);
///   created_at backend'de `now()` default olduğu için istemci modelinde
///   taşınmaz.
/// - [PoolWord] -> word_pool(id, term, translation, category, level_index).
enum WordStatus {
  learning,
  memorized;

  String get storageValue => switch (this) {
    WordStatus.learning => 'learning',
    WordStatus.memorized => 'memorized',
  };
}

@immutable
class Word {
  const Word({
    required this.id,
    required this.term,
    required this.translation,
    required this.status,
  });

  final String id;
  final String term;
  final String translation;
  final WordStatus status;
}

/// Kullanıcının seçip kendi listesine ekleyebildiği ortak kelime havuzu.
@immutable
class PoolWord {
  const PoolWord({
    required this.id,
    required this.term,
    required this.translation,
    required this.category,
    required this.levelIndex,
  });

  final String id;
  final String term;
  final String translation;
  final String category;

  /// 0 = A1 … 5 = C2 ([LevelContent.cefrLevels] sırasıyla birebir).
  final int levelIndex;
}

/// Hızlı çeviri kartının gösterdiği son sonuç.
@immutable
class WordTranslation {
  const WordTranslation({required this.term, this.translation});

  final String term;
  final String? translation;
}
