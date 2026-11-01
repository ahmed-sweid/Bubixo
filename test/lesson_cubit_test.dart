import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/models/lesson_models.dart';
import 'package:en_bubixo/features/lessons/cubit/lessons_cubit.dart';
import 'package:en_bubixo/features/lessons/data/repositories/lesson_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLessonRepository implements LessonRepository {
  _FakeLessonRepository({this.levels = const <LessonLevel>[]});

  List<LessonLevel> levels;
  Failure? failure;
  int calls = 0;

  @override
  Future<Either<Failure, List<LessonLevel>>> fetchCatalog() async {
    calls++;
    final Failure? error = failure;
    return error == null
        ? Right<Failure, List<LessonLevel>>(levels)
        : Left<Failure, List<LessonLevel>>(error);
  }
}

const LessonLevel _a1 = LessonLevel(
  levelIndex: 0,
  grammarLessons: <Lesson>[
    Lesson(
      id: '5',
      levelIndex: 0,
      track: LessonTrack.grammar,
      order: 1,
      title: 'Present Simple',
      body: <String>[],
      questions: <LessonQuestion>[],
    ),
  ],
  lessonLessons: <Lesson>[],
);

const LessonLevel _a2Empty = LessonLevel(
  levelIndex: 1,
  grammarLessons: <Lesson>[],
  lessonLessons: <Lesson>[],
);

void main() {
  late _FakeLessonRepository repository;
  late LessonsCubit cubit;

  setUp(() {
    repository = _FakeLessonRepository(levels: <LessonLevel>[_a1]);
    cubit = LessonsCubit(repository: repository);
  });

  tearDown(() async => cubit.close());

  group('LessonsCubit', () {
    test('veri katmanı yoksa load sessiz kalır ve iskelet görünür', () async {
      final LessonsCubit bare = LessonsCubit();
      addTearDown(bare.close);

      await bare.load();

      expect(bare.state, const LessonsLoading());
    });

    test('başarılı okuma dolu seviyeleri yayımlar', () async {
      await cubit.load();

      expect(cubit.state, const LessonsReady(levels: <LessonLevel>[_a1]));
      expect(repository.calls, 1);
    });

    test('içeriği olmayan seviyeler ekrana taşınmaz, boş durumu seçilir', () async {
      repository.levels = <LessonLevel>[_a2Empty];

      await cubit.load();

      expect(cubit.state, const LessonsEmpty());
    });

    test('hata mesajı Failure metni olarak gelir', () async {
      repository.failure = const PermissionFailure(code: '42501');

      await cubit.load();

      final LessonsState state = cubit.state;
      expect(state, isA<LessonsError>());
      expect(
        (state as LessonsError).message,
        isNotEmpty,
        reason: 'yetki reddi kullanıcıya Türkçe metin olarak inmeli',
      );
    });

    test('tekrar yükleme eski durumu ezmeden yeniden loading geçiri', () async {
      await cubit.load();
      expect(cubit.state, isA<LessonsReady>());

      repository.failure = const NetworkFailure();
      await cubit.load();

      expect(cubit.state, isA<LessonsError>());
      expect(repository.calls, 2);
    });
  });
}
