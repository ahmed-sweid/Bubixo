import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/constants/error_content.dart';
import 'package:en_bubixo/core/constants/supabase_tables.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/error/exceptions.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/network/network_info.dart';
import 'package:en_bubixo/features/level/data/datasources/level_remote_data_source.dart';
import 'package:en_bubixo/features/level/data/models/level_models.dart';
import 'package:en_bubixo/features/level/data/repositories/level_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Satır okumalarını ve RPC'leri kaydeden sahte kapı.
///
/// Alan adları canlı şemadan (`levels`, `profiles`) ve iki yeni RPC'nin
/// jsonb çıktısından alındığı gibi kurgulandı; eşleme bozulursa test kırılır.
class _FakeBackend implements SupabaseBackend {
  _FakeBackend();

  bool ready = true;

  /// Sıradaki her çağrıda fırlatılacak hata.
  Object? failure;

  final List<TableQuery> queries = <TableQuery>[];
  final List<String> rpcNames = <String>[];
  final List<Map<String, dynamic>?> rpcParams = <Map<String, dynamic>?>[];

  /// `rows` için sırayla döndürülecek listeler.
  final List<List<Map<String, dynamic>>> rowsQueue =
      <List<Map<String, dynamic>>>[];

  /// `row` için sırayla döndürülecek tek satırlar (`null` = boş sonuç).
  final List<Map<String, dynamic>?> singleRowQueue =
      <Map<String, dynamic>?>[];

  /// `rpc` için sırayla döndürülecek yanıtlar.
  final List<Object?> rpcQueue = <Object?>[];

  @override
  bool get isReady => ready;

  @override
  Future<List<Map<String, dynamic>>> rows(TableQuery query) async {
    queries.add(query);
    _maybeThrow();
    if (rowsQueue.isEmpty) {
      throw StateError('Sahte kapıda satır kuyruğu boş: ${query.table}');
    }
    return rowsQueue.removeAt(0);
  }

  @override
  Future<Map<String, dynamic>?> row(TableQuery query) async {
    queries.add(query);
    _maybeThrow();
    if (singleRowQueue.isEmpty) {
      throw StateError('Sahte kapıda tek satır kuyruğu boş: ${query.table}');
    }
    return singleRowQueue.removeAt(0);
  }

  @override
  Future<dynamic> rpc(String name, [Map<String, dynamic>? params]) async {
    rpcNames.add(name);
    rpcParams.add(params);
    _maybeThrow();
    if (rpcQueue.isEmpty) {
      throw StateError('Sahte kapıda RPC kuyruğu boş: $name');
    }
    return rpcQueue.removeAt(0);
  }

  void _maybeThrow() {
    final Object? error = failure;
    if (error != null) {
      throw error;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Seviye kaydı yalnız rows/row/rpc kullanır');
}

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

Map<String, dynamic> _levelRow(int id, String code, String title, int order) =>
    <String, dynamic>{
      'id': id,
      'code': code,
      'title': title,
      'order_index': order,
      'created_at': '2026-11-01T00:00:00.000Z',
    };

/// `set_user_level` / `apply_placement_result` çıktısı.
Map<String, dynamic> _applied(int id, String code, int order, String source) =>
    <String, dynamic>{
      'level_id': id,
      'code': code,
      'title': 'Upper Intermediate',
      'order_index': order,
      'source': source,
      'set_at': '2026-11-03T00:00:00.000Z',
    };

void main() {
  late _FakeBackend backend;
  late LevelRemoteDataSourceImpl remote;

  setUp(() {
    backend = _FakeBackend();
    remote = LevelRemoteDataSourceImpl(backend);
  });

  group('seviye kataloğu okuması', () {
    test('levels order_index sırasıyla ve tam kolon listesiyle istenir',
        () async {
      backend.rowsQueue.add(<Map<String, dynamic>>[
        _levelRow(1, 'A1', 'Beginner', 1),
        _levelRow(2, 'A2', 'Elementary', 2),
      ]);

      final List<AppLevel> levels = await remote.fetchLevels();

      final TableQuery query = backend.queries.single;
      expect(query.table, SupabaseTable.levels);
      expect(query.columns, LevelColumns.all);
      expect(query.orderColumn, LevelColumns.orderIndex);
      expect(levels.map((AppLevel level) => level.code), <String>['A1', 'A2']);
    });

    test('satır alanları modele eşelenir (bigint id string taşınır)', () async {
      backend.rowsQueue.add(<Map<String, dynamic>>[
        _levelRow(4, 'B2', 'Upper Intermediate', 4),
      ]);

      final AppLevel level = (await remote.fetchLevels()).single;
      expect(level.id, '4');
      expect(level.code, 'B2');
      expect(level.title, 'Upper Intermediate');
      expect(level.orderIndex, 4);
    });

    test('order_index string gelirse yine sayıya çevrilir', () async {
      backend.rowsQueue.add(<Map<String, dynamic>>[
        <String, dynamic>{'id': 3, 'code': 'B1', 'order_index': '3'},
      ]);

      expect((await remote.fetchLevels()).single.orderIndex, 3);
    });

    test('id alanı yoksa kötü yanıt hatası fırlatılır', () async {
      backend.rowsQueue.add(<Map<String, dynamic>>[
        <String, dynamic>{'code': 'A1'},
      ]);

      await expectLater(
        remote.fetchLevels(),
        throwsA(
          isA<BackendException>().having(
            (BackendException error) => error.code,
            'code',
            'bad_response',
          ),
        ),
      );
    });
  });

  group('seviye imzası okuması', () {
    test('imza kolonu null ise ikinci sorgu atılmaz ve null döner', () async {
      backend.singleRowQueue.add(<String, dynamic>{'current_level_id': null});

      expect(await remote.fetchCurrentLevel(), isNull);
      expect(backend.queries, hasLength(1));
      expect(backend.queries.single.table, SupabaseTable.profiles);
      expect(
        backend.queries.single.columns,
        ProfileColumns.currentLevelId,
      );
    });

    test('imza varsa seviye satırı katalogdan çözülür', () async {
      backend.singleRowQueue.add(<String, dynamic>{'current_level_id': 4});
      backend.singleRowQueue.add(_levelRow(4, 'B2', 'Upper Intermediate', 4));

      final AppLevel? level = await remote.fetchCurrentLevel();
      expect(level?.code, 'B2');
      expect(backend.queries, hasLength(2));
      expect(backend.queries.last.eq, <String, Object>{LevelColumns.id: 4});
    });

    test('imza olmayan seviyeye işaret ederse null döner', () async {
      backend.singleRowQueue.add(<String, dynamic>{'current_level_id': 9});
      backend.singleRowQueue.add(null);

      expect(await remote.fetchCurrentLevel(), isNull);
    });
  });

  group("seviye yazma RPC'leri", () {
    test('elle seçim set_user_level’e seviye id ve manual kaynakla gider',
        () async {
      backend.rpcQueue.add(_applied(4, 'B2', 4, 'manual'));

      final AppLevel applied = await remote.saveLevel(
        levelId: '4',
        source: LevelSource.manual,
      );

      expect(backend.rpcNames.single, SupabaseRpc.setUserLevel);
      expect(backend.rpcParams.single, <String, dynamic>{
        'p_level_id': 4,
        'p_source': 'manual',
      });
      expect(applied.id, '4');
      expect(applied.code, 'B2');
    });

    test('test sonucu apply_placement_result’a yalnız oturum id’si gider',
        () async {
      backend.rpcQueue.add(_applied(5, 'C1', 5, 'placement'));

      final AppLevel applied = await remote.applyPlacementResult('15');

      expect(backend.rpcNames.single, SupabaseRpc.applyPlacementResult);
      expect(
        backend.rpcParams.single,
        <String, dynamic>{'p_attempt_id': 15},
      );
      expect(applied.code, 'C1');
    });

    test('LevelSource.wireValue sunucunun kabul ettiği iki metinden biri',
        () {
      expect(LevelSource.manual.wireValue, 'manual');
      expect(LevelSource.placement.wireValue, 'placement');
    });

    test('RPC düz metin dönerse kötü yanıt hatası fırlatılır', () async {
      backend.rpcQueue.add('ok');

      await expectLater(
        remote.applyPlacementResult('15'),
        throwsA(
          isA<BackendException>().having(
            (BackendException error) => error.code,
            'code',
            'bad_response',
          ),
        ),
      );
    });
  });

  test('Supabase başlatılmamışsa dört yol da backend_not_ready verir',
      () async {
    backend.ready = false;

    for (final Future<void> Function() call in <Future<void> Function()>[
      remote.fetchLevels,
      remote.fetchCurrentLevel,
      () => remote.saveLevel(levelId: '1', source: LevelSource.manual),
      () => remote.applyPlacementResult('1'),
    ]) {
      await expectLater(
        call(),
        throwsA(
          isA<BackendException>().having(
            (BackendException error) => error.code,
            'code',
            'backend_not_ready',
          ),
        ),
      );
    }
    expect(backend.queries, isEmpty);
    expect(backend.rpcNames, isEmpty);
  });

  group('repository', () {
    late LevelRepositoryImpl repository;

    setUp(() {
      repository = LevelRepositoryImpl(remote, _FakeNetworkInfo(true));
    });

    test('çevrimdışıyken NetworkFailure ve veri kaynağına hiç gidilmez',
        () async {
      repository = LevelRepositoryImpl(remote, _FakeNetworkInfo(false));

      final Either<Failure, List<AppLevel>> result =
          await repository.fetchLevels();

      expect(
        result.fold(ifLeft: (Failure f) => f, ifRight: (List<AppLevel> v) => v),
        isA<NetworkFailure>(),
      );
      expect(backend.queries, isEmpty);
      expect(backend.rpcNames, isEmpty);
    });

    test('katalog Right olarak listelenir', () async {
      backend.rowsQueue.add(<Map<String, dynamic>>[
        _levelRow(1, 'A1', 'Beginner', 1),
      ]);

      final Either<Failure, List<AppLevel>> result =
          await repository.fetchLevels();

      expect(
        result.fold(ifLeft: (Failure f) => f, ifRight: (List<AppLevel> v) => v),
        isA<List<AppLevel>>(),
      );
    });

    test('imzasız kullanıcı Right(null) — boş durum, hata değil', () async {
      backend.singleRowQueue.add(<String, dynamic>{'current_level_id': null});

      final Either<Failure, AppLevel?> result =
          await repository.fetchCurrentLevel();

      expect(
        result.fold(ifLeft: (Failure f) => f, ifRight: (AppLevel? v) => v),
        isNull,
      );
    });

    test('oturumsuz profil okuması PermissionFailure’a döner', () async {
      backend.failure = const BackendException(
        message: 'permission denied',
        code: '42501',
      );

      final Either<Failure, AppLevel?> result =
          await repository.fetchCurrentLevel();

      final Failure failure = result.fold(
        ifLeft: (Failure f) => f,
        ifRight: (AppLevel? v) => throw StateError('beklenmedik Right: $v'),
      );
      expect(failure, isA<PermissionFailure>());
      expect(failure.errorMessage, ErrorContent.forbidden);
    });

    test('olmayan seviye 23514 ValidationFailure’a döner', () async {
      backend.failure = const BackendException(
        message: 'seviye bulunamadi',
        code: '23514',
      );

      final Either<Failure, AppLevel> result = await repository.saveLevel(
        levelId: '99',
        source: LevelSource.manual,
      );

      expect(
        result.fold(ifLeft: (Failure f) => f, ifRight: (AppLevel v) => v),
        isA<ValidationFailure>(),
      );
    });

    test('beklenmedik hata failureFromUnknown ile kapanır', () async {
      backend.failure = StateError('sapka');

      final Either<Failure, AppLevel> result =
          await repository.applyPlacementResult('1');

      expect(
        result.fold(ifLeft: (Failure f) => f, ifRight: (AppLevel v) => v),
        isA<Failure>(),
      );
    });

    test('test sonucu uygulanınca uygulanan seviye Right döner', () async {
      backend.rpcQueue.add(_applied(4, 'B2', 4, 'placement'));

      final Either<Failure, AppLevel> result =
          await repository.applyPlacementResult('18');

      final AppLevel level = result.fold(
        ifLeft: (Failure f) => throw f,
        ifRight: (AppLevel v) => v,
      );
      expect(level.id, '4');
      expect(level.orderIndex, 4);
    });
  });
}
