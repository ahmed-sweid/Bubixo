import 'package:flutter/foundation.dart';

/// Ders modülü veri modelleri.
///
/// Alanlar Supabase şemasıyla birebir eşleşir:
/// - [Lesson]        -> lessons(id, level_index, track, type, title, body,
///                              order); seviye testlerinde track null,
///                              type 'level_test'
/// - [LessonQuestion] -> `questions(id, lesson_id, prompt, options jsonb,
///                                     correct_index)`
/// İlerleme -> lesson_progress(user_id, lesson_id, score, completed_at).
enum LessonTrack {
  grammar,
  lessons;

  String get storageValue => switch (this) {
    LessonTrack.grammar => 'grammar',
    LessonTrack.lessons => 'lessons',
  };
}

enum LessonType {
  lesson,
  levelTest;

  String get storageValue => switch (this) {
    LessonType.lesson => 'lesson',
    LessonType.levelTest => 'level_test',
  };
}

@immutable
class LessonQuestion {
  const LessonQuestion({
    required this.id,
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

@immutable
class Lesson {
  const Lesson({
    required this.id,
    required this.levelIndex,
    required this.track,
    required this.order,
    required this.title,
    required this.body,
    required this.questions,
    this.type = LessonType.lesson,
  });

  final String id;
  final int levelIndex;
  final LessonTrack? track;
  final int order;
  final String title;
  final List<String> body;
  final List<LessonQuestion> questions;
  final LessonType type;
}

/// Tek bir CEFR seviyesinin iki track'e ait dersleri ve ilerlemesi.
@immutable
class LessonLevel {
  const LessonLevel({
    required this.levelIndex,
    required this.grammarLessons,
    required this.lessonLessons,
    this.grammarProgress = 0,
    this.lessonProgress = 0,
    this.levelTestUnlocked = false,
  });

  final int levelIndex;
  final List<Lesson> grammarLessons;
  final List<Lesson> lessonLessons;
  final double grammarProgress;
  final double lessonProgress;
  final bool levelTestUnlocked;

  List<Lesson> lessonsFor(LessonTrack track) =>
      track == LessonTrack.grammar ? grammarLessons : lessonLessons;

  double progressFor(LessonTrack track) =>
      track == LessonTrack.grammar ? grammarProgress : lessonProgress;
}
