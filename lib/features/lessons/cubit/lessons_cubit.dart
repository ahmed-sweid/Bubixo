import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/lesson_models.dart';

part 'lessons_state.dart';

/// Dersler sekmesinin durum yönetimi; veri katmanı bağlanınca ders
/// seviyelerini bu cubit yükleyecek.
class LessonsCubit extends Cubit<LessonsState> {
  LessonsCubit({LessonsState initialState = const LessonsLoading()})
    : super(initialState);
}
