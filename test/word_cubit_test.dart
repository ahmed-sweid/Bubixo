import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/models/word_models.dart';
import 'package:en_bubixo/features/words/cubit/words_cubit.dart';
import 'package:en_bubixo/features/words/data/models/word_snapshot.dart';
import 'package:en_bubixo/features/words/data/repositories/word_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const WordSnapshot _emptySnapshot = WordSnapshot(
  words: <Word>[],
  suggestedWords: <PoolWord>[],
);

class _FakeWordRepository implements WordRepository {
  _FakeWordRepository({this.snapshot = _emptySnapshot});

  WordSnapshot snapshot;
  Failure? failure;
  int calls = 0;

  @override
  Future<Either<Failure, WordSnapshot>> fetchSnapshot() async {
    calls++;
    final Failure? error = failure;
    return error == null
        ? Right<Failure, WordSnapshot>(snapshot)
        : Left<Failure, WordSnapshot>(error);
  }
}

const Word _hello = Word(
  id: '1',
  term: 'hello',
  translation: 'merhaba',
  status: WordStatus.learning,
);

const PoolWord _cat = PoolWord(
  id: '2',
  term: 'cat',
  translation: 'kedi',
  category: 'animal',
  levelIndex: 0,
);

const WordSnapshot _filled = WordSnapshot(
  words: <Word>[_hello],
  suggestedWords: <PoolWord>[_cat],
);

void main() {
  late _FakeWordRepository repository;
  late WordsCubit cubit;

  setUp(() {
    repository = _FakeWordRepository(snapshot: _filled);
    cubit = WordsCubit(repository: repository);
  });

  tearDown(() async => cubit.close());

  group('WordsCubit', () {
    test('veri katmanı yoksa load sessiz kalır ve iskelet görünür', () async {
      final WordsCubit bare = WordsCubit();
      addTearDown(bare.close);

      await bare.load();

      expect(bare.state, const WordsLoading());
    });

    test('başarılı okuma liste ve önerileri birlikte yayımlar', () async {
      await cubit.load();

      expect(
        cubit.state,
        const WordsReady(words: <Word>[_hello], suggestedWords: <PoolWord>[_cat]),
      );
      expect(repository.calls, 1);
    });

    test('hem liste hem öneri boşsa boş durumu seçilir', () async {
      await cubit.load();
      expect(cubit.state, isA<WordsReady>());

      repository = _FakeWordRepository();
      cubit = WordsCubit(repository: repository);
      await cubit.load();

      expect(cubit.state, const WordsEmpty());
    });

    test('hata mesajı Failure metni olarak gelir', () async {
      repository.failure = const PermissionFailure(code: '42501');

      await cubit.load();

      final WordsState state = cubit.state;
      expect(state, isA<WordsError>());
      expect(
        (state as WordsError).message,
        isNotEmpty,
        reason: 'yetki reddi kullanıcıya Türkçe metin olarak inmeli',
      );
    });

    test('tekrar yükleme eski durumu ezmeden yeniden loading geçiri', () async {
      await cubit.load();
      expect(cubit.state, isA<WordsReady>());

      repository.failure = const NetworkFailure();
      await cubit.load();

      expect(cubit.state, isA<WordsError>());
      expect(repository.calls, 2);
    });
  });

  group('WordsCubit hızlı çeviri', () {
    setUp(() async {
      await cubit.load();
    });

    test('ingilizceden türkçeye havuzda bulunan kelime çevrilir', () {
      cubit.translate('CAT');

      final WordsReady state = cubit.state as WordsReady;
      expect(state.translation?.term, 'CAT');
      expect(state.translation?.translation, 'kedi');
    });

    test('listede bulunan kelime de çevrilir', () {
      cubit.translate('hello');

      expect((cubit.state as WordsReady).translation?.translation, 'merhaba');
    });

    test('bulunamayan kelime boş sonuçla gösterilir', () {
      cubit.translate('zzz');

      final WordsReady state = cubit.state as WordsReady;
      expect(state.translation?.term, 'zzz');
      expect(state.translation?.translation, isNull);
    });

    test('boş giriş istek sayılmaz, sonuç değişmez', () {
      cubit.translate('   ');

      expect((cubit.state as WordsReady).translation, isNull);
    });

    test('yön değişince eski cevap silinir ve tersten arama çalışır', () {
      cubit.translate('kedi');
      expect((cubit.state as WordsReady).translation?.translation, isNull);

      cubit.swapDirection();
      final WordsReady swapped = cubit.state as WordsReady;
      expect(swapped.enToTr, isFalse);
      expect(swapped.translation, isNull);

      cubit.translate('kedi');
      expect((cubit.state as WordsReady).translation?.translation, 'cat');
    });

    test('çeviri ağa çıkmaz, ekrandaki listeyi kullanır', () {
      final int before = repository.calls;

      cubit.translate('hello');

      expect(repository.calls, before);
    });
  });
}
