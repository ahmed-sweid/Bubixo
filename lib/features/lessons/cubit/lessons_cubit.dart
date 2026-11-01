import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/lesson_models.dart';
import '../data/repositories/lesson_repository.dart';

part 'lessons_state.dart';

/// Dersler sekmesinin durum yönetimi: katalog tek sorgu grubuyla okunur.
///
/// [repository] üretimde DI'dan gelir. Widget testleri ekranı veri katmanı
/// olmadan render ettiği için null olabilir; o durumda [load] sessiz kalır ve
/// ekranda yükleme iskeleti görünür.
class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({
    this.repository,
    LessonsState initialState = const LessonsLoading(),
  }) : super(initialState);

  final LessonRepository? repository;

  Future<void> load() async {
    final LessonRepository? source = repository;
    if (source == null) return;

    emit(const LessonsLoading());
    final result = await source.fetchCatalog();
    if (isClosed) return;

    result.fold(
      ifLeft: (failure) => emit(LessonsError(message: failure.errorMessage)),
      ifRight: (levels) {
        // İçerik olmayan seviyeler kart olarak gösterilmez: A2–C2 tohumu
        // henüz atılmamışken sekme "boş" demek, altı boş kart demek değil.
        final List<LessonLevel> filled = levels
            .where(
              (LessonLevel level) =>
                  level.grammarLessons.isNotEmpty ||
                  level.lessonLessons.isNotEmpty,
            )
            .toList(growable: false);
        emit(
          filled.isEmpty
              ? const LessonsEmpty()
              : LessonsReady(levels: filled),
        );
      },
    );
  }
}
