import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/constants/level_content.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/features/level/cubit/level_cubit.dart';
import 'package:en_bubixo/features/level/data/models/level_models.dart';
import 'package:en_bubixo/features/level/data/repositories/level_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const AppLevel _a1 = AppLevel(id: '1', code: 'A1', title: 'Beginner', orderIndex: 1);
const AppLevel _b1 = AppLevel(id: '3', code: 'B1', title: 'Intermediate', orderIndex: 3);

class _FakeLevelRepository implements LevelRepository {
  _FakeLevelRepository();

  List<AppLevel>? levels;
  AppLevel? current;
  Failure? failure;

  /// Yalnız imza okumasına uygulanan hata: katalog hatasından ayrı durur,
  /// çünkü imza kaybı akışı durdurmamalı.
  Failure? signatureFailure;
  AppLevel? savedResponse;

  int fetchCalls = 0;
  String? savedLevelId;
  LevelSource? savedSource;
  String? appliedAttemptId;
  int saveCalls = 0;

  @override
  Future<Either<Failure, List<AppLevel>>> fetchLevels() async {
    fetchCalls++;
    final Failure? error = failure;
    if (error != null) return Left<Failure, List<AppLevel>>(error);
    return Right<Failure, List<AppLevel>>(levels ?? const <AppLevel>[]);
  }

  @override
  Future<Either<Failure, AppLevel?>> fetchCurrentLevel() async {
    final Failure? error = signatureFailure ?? failure;
    if (error != null) return Left<Failure, AppLevel?>(error);
    return Right<Failure, AppLevel?>(current);
  }

  @override
  Future<Either<Failure, AppLevel>> saveLevel({
    required String levelId,
    required LevelSource source,
  }) async {
    saveCalls++;
    savedLevelId = levelId;
    savedSource = source;
    final Failure? error = failure;
    if (error != null) return Left<Failure, AppLevel>(error);
    // Gerçek RPC gönderilen bandın kendisini döndürür.
    return Right<Failure, AppLevel>(
      savedResponse ??
          (levels ?? const <AppLevel>[]).firstWhere(
            (AppLevel level) => level.id == levelId,
          ),
    );
  }

  @override
  Future<Either<Failure, AppLevel>> applyPlacementResult(String attemptId) async {
    appliedAttemptId = attemptId;
    final Failure? error = failure;
    if (error != null) return Left<Failure, AppLevel>(error);
    return Right<Failure, AppLevel>(_b1);
  }
}

void main() {
  late _FakeLevelRepository repository;
  late LevelCubit cubit;

  setUp(() {
    repository = _FakeLevelRepository();
    cubit = LevelCubit(repository: repository);
  });

  tearDown(() async => cubit.close());

  group('LevelCubit yerleşik katalog', () {
    test('veri katmanı yoksa altı CEFR bandı sabitten çizilir', () {
      final LevelCubit bare = LevelCubit();
      addTearDown(bare.close);

      final LevelReady state = bare.state as LevelReady;
      expect(state.levels.map((AppLevel level) => level.code), LevelContent.cefrLevels);
      expect(state.selectedLevelId, isNull);
      expect(state.currentLevelId, isNull);
    });

    test('veri katmanı yokken load sessiz kalır, katalog yerli kalır', () async {
      final LevelCubit bare = LevelCubit();
      addTearDown(bare.close);

      await bare.load();

      expect(bare.state, isA<LevelReady>());
      expect((bare.state as LevelReady).levels.first.code, 'A1');
    });

    test('veri katmanı yokken saveSelected yazmadan başarılı döner', () async {
      final LevelCubit bare = LevelCubit();
      addTearDown(bare.close);
      bare.select('2');

      expect(await bare.saveSelected(), isTrue);
      expect((bare.state as LevelReady).isSaving, isFalse);
      expect((bare.state as LevelReady).currentLevelId, isNull);
    });
  });

  group('LevelCubit katalog okuması', () {
    test('sunucu kataloğu yerleşik listeyi değiştirir', () async {
      repository.levels = const <AppLevel>[_a1, _b1];

      await cubit.load();

      final LevelReady state = cubit.state as LevelReady;
      expect(state.levels, const <AppLevel>[_a1, _b1]);
      expect(repository.fetchCalls, 1);
    });

    test('katalog hatası tam ekran hata durumu olur', () async {
      repository.failure = const NetworkFailure();

      await cubit.load();

      final LevelState state = cubit.state;
      expect(state, isA<LevelError>());
      expect((state as LevelError).message, isNotEmpty);
    });

    test('boş katalog da hatadır: seviyesiz devam edilemez', () async {
      repository.levels = const <AppLevel>[];

      await cubit.load();

      expect(cubit.state, const LevelError());
    });
  });

  group('LevelCubit imza önseçimi', () {
    test('kayıtlı bant katalogdan çözülüp önseçilir', () async {
      repository.levels = const <AppLevel>[_a1, _b1];
      repository.current = _b1;

      await cubit.load();

      final LevelReady state = cubit.state as LevelReady;
      expect(state.currentLevelId, '3');
      expect(state.selectedLevelId, '3');
    });

    test('imzasız kullanıcı için hiçbir kart işaretlenmez', () async {
      repository.levels = const <AppLevel>[_a1, _b1];
      repository.current = null;

      await cubit.load();

      final LevelReady state = cubit.state as LevelReady;
      expect(state.currentLevelId, isNull);
      expect(state.selectedLevelId, isNull);
    });

    test('kullanıcı seçim yaptıysa imza seçimi ezmez', () async {
      repository.levels = const <AppLevel>[_a1, _b1];
      repository.current = _b1;

      final Future<void> loading = cubit.load();
      cubit.select('1');
      await loading;

      expect((cubit.state as LevelReady).selectedLevelId, '1');
      expect((cubit.state as LevelReady).currentLevelId, '3');
    });

    test('imza okunamasa bile katalog kullanılabilir kalır', () async {
      repository.levels = const <AppLevel>[_a1, _b1];
      repository.signatureFailure = const PermissionFailure(code: '42501');

      await cubit.load();

      final LevelReady state = cubit.state as LevelReady;
      expect(state, isA<LevelReady>());
      expect(state.levels, hasLength(2));
      expect(state.selectedLevelId, isNull);
    });
  });

  group('LevelCubit seçim ve kayıt', () {
    setUp(() async {
      repository.levels = const <AppLevel>[_a1, _b1];
      await cubit.load();
    });

    test('dokunulan bant seçilir', () {
      cubit.select('3');

      expect((cubit.state as LevelReady).selectedLevelId, '3');
    });

    test('katalogda olmayan id seçilemez', () {
      cubit.select('99');

      expect((cubit.state as LevelReady).selectedLevelId, isNull);
    });

    test('onay seçilen bandı manual kaynakla sunucuya yazar', () async {
      cubit.select('3');

      expect(await cubit.saveSelected(), isTrue);

      expect(repository.savedLevelId, '3');
      expect(repository.savedSource, LevelSource.manual);
      final LevelReady state = cubit.state as LevelReady;
      expect(state.currentLevelId, '3');
      expect(state.selectedLevelId, '3');
      expect(state.saveMessage, isNull);
    });

    test('yazma reddedilirse ekranda kalınır ve hata gösterilir', () async {
      cubit.select('3');
      repository.failure = const ValidationFailure(code: '23514');

      expect(await cubit.saveSelected(), isFalse);

      final LevelReady state = cubit.state as LevelReady;
      expect(state.saveMessage, isNotEmpty);
      expect(state.selectedLevelId, '3');
      expect(state.isSaving, isFalse);
      expect(repository.savedLevelId, '3');
    });

    test('seçim yapılmadan onay sunucuya gitmez', () async {
      expect(await cubit.saveSelected(), isFalse);
      expect(repository.saveCalls, 0);
    });

    test('yeni seçim eski hata mesajını temizler', () async {
      cubit.select('3');
      repository.failure = const ValidationFailure(code: '23514');
      await cubit.saveSelected();

      repository.failure = null;
      cubit.select('1');

      expect((cubit.state as LevelReady).saveMessage, isNull);
    });
  });
}
