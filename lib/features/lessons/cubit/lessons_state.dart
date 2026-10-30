part of 'lessons_cubit.dart';

sealed class LessonsState extends Equatable {
  const LessonsState();

  @override
  List<Object?> get props => const <Object?>[];
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

  @override
  List<Object?> get props => <Object?>[levels];
}
