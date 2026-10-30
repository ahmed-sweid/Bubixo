import 'package:flutter/foundation.dart';

import '../../core/models/lesson_models.dart';

/// Dersler sekmesinin cubit'e hazır durum modeli.
sealed class LessonsState {
  const LessonsState();
}

final class LessonsLoading extends LessonsState {
  const LessonsLoading();
}

final class LessonsError extends LessonsState {
  const LessonsError();
}

final class LessonsEmpty extends LessonsState {
  const LessonsEmpty();
}

final class LessonsReady extends LessonsState {
  const LessonsReady({required this.levels});

  /// CEFR sırasına göre seviye grupları; backend'den tek sorguda gelir.
  final List<LessonLevel> levels;
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
