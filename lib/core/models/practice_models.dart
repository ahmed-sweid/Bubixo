import 'package:flutter/foundation.dart';

/// Pratik modülü veri modelleri.
///
/// Supabase karşılığı:
/// - [PracticeItem]          -> practice_items(id, type, level_index, order,
///                              title)
/// - soru modelleri          -> practice_questions(id, item_id, payload jsonb)
/// - ilerleme                -> practice_progress(user_id, item_id,
///                              completed_at)
/// TODO(backend): içerik ve ilerleme bu tablolardan gelecek.
enum PracticeType {
  sentenceOrder,
  fillBlank,
  speaking,
  listening,
  matching;

  String get storageValue => switch (this) {
    PracticeType.sentenceOrder => 'sentence_order',
    PracticeType.fillBlank => 'fill_blank',
    PracticeType.speaking => 'speaking',
    PracticeType.listening => 'listening',
    PracticeType.matching => 'matching',
  };
}

@immutable
class PracticeItem {
  const PracticeItem({
    required this.id,
    required this.type,
    required this.levelIndex,
    required this.order,
    required this.title,
    this.completed = false,
  });

  final String id;
  final PracticeType type;
  final int levelIndex;
  final int order;
  final String title;
  final bool completed;
}

/// Cümle sıralama sorusu: [tokens] karışık, [answer] doğru sıra, [hint]
/// cümlenin Türkçe karşılığı.
@immutable
class SentenceOrderQuestion {
  const SentenceOrderQuestion({
    required this.id,
    required this.hint,
    required this.tokens,
    required this.answer,
  });

  final String id;
  final String hint;
  final List<String> tokens;
  final List<String> answer;
}

@immutable
class FillBlankQuestion {
  const FillBlankQuestion({
    required this.id,
    required this.sentence,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String sentence;
  final List<String> options;
  final int correctIndex;
}

@immutable
class SpeakingPrompt {
  const SpeakingPrompt({
    required this.id,
    required this.task,
    required this.phrase,
  });

  final String id;
  final String task;
  final String phrase;
}

@immutable
class ListeningQuestion {
  const ListeningQuestion({
    required this.id,
    required this.audioText,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String audioText;
  final List<String> options;
  final int correctIndex;
}

@immutable
class MatchingPair {
  const MatchingPair({
    required this.id,
    required this.term,
    required this.meaning,
  });

  final String id;
  final String term;
  final String meaning;
}

@immutable
class MatchingQuestion {
  const MatchingQuestion({required this.id, required this.pairs});

  final String id;
  final List<MatchingPair> pairs;
}
