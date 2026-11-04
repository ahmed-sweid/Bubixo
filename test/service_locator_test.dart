import 'package:en_bubixo/features/auth/cubit/auth_cubit.dart';
import 'package:en_bubixo/features/level/cubit/level_test_cubit.dart';
import 'package:en_bubixo/features/lessons/cubit/lessons_cubit.dart';
import 'package:en_bubixo/features/words/cubit/words_cubit.dart';
import 'package:en_bubixo/shared/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
    // Supabase client verilmiyor: kapı hazır değil, ama kayıtlar kuruluyor.
    await initDependencies();
  });

  tearDown(() async => sl.reset());

  group('hizmet kaydı', () {
    test('auth cubit oturum ve repository ile kuruluyor', () {
      final AuthCubit cubit = sl<AuthCubit>();
      addTearDown(cubit.close);

      expect(cubit.repository, isNotNull);
      expect(cubit.session, isNotNull);
    });

    test('dersler cubit repository ile kuruluyor', () {
      final LessonsCubit cubit = sl<LessonsCubit>();
      addTearDown(cubit.close);

      expect(cubit.repository, isNotNull);
    });

    test('kelimeler cubit repository ile kuruluyor', () {
      final WordsCubit cubit = sl<WordsCubit>();
      addTearDown(cubit.close);

      expect(cubit.repository, isNotNull);
    });

    test('seviye testi cubit repository ile kuruluyor', () {
      final LevelTestCubit cubit = sl<LevelTestCubit>();
      addTearDown(cubit.close);

      expect(cubit.repository, isNotNull);
    });
  });
}
