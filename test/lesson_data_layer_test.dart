import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/constants/supabase_tables.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/error/exceptions.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/models/lesson_models.dart';
import 'package:en_bubixo/core/network/network_info.dart';
import 'package:en_bubixo/features/lessons/data/datasources/lesson_remote_data_source.dart';
import 'package:en_bubixo/features/lessons/data/repositories/lesson_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tablo adına göre satır dönen sahte kapı: veri kaynağının hangi görünümü
/// okuduğu kaydedilir, böylece sorgu listesi de test edilmiş olur.
class _FakeBackend implements SupabaseBackend {
  _FakeBackend(this.tableRows);

  final Map<String, List<Map<String, dynamic>>> tableRows;
  final List<String> queriedTables = <String>[];

  @override
  bool get isReady => true;

  @override
  Future<List<Map<String, dynamic>>> rows(TableQuery query) async {
    queriedTables.add(query.table);
    return tableRows[query.table] ?? const <Map<String, dynamic>>[];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Bu testte yalnız okuma kullanılır');
}

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeLessonRemote implements LessonRemoteDataSource {
  _FakeLessonRemote({this.levels});

  List<LessonLevel>? levels;

  /// Doldurulursa veri kaynağı bu SQLSTATE ile patlar; repository'nin işi
  /// onu doğru `Failure`'a çevirmek.
  String? errorCode;
  int catalogCalls = 0;

  @override
  Future<List<LessonLevel>> fetchCatalog() async {
    catalogCalls++;
    if (errorCode != null) {
      throw BackendException(message: 'sorgu reddedildi', code: errorCode!);
    }
    return levels ?? const <LessonLevel>[];
  }
}

Failure? _leftOf<T>(Either<Failure, T> either) =>
    either.fold(ifLeft: (f) => f, ifRight: (_) => null);

List<LessonLevel>? _rightLevels(Either<Failure, List<LessonLevel>> either) =>
    either.fold(ifLeft: (_) => null, ifRight: (r) => r);

Map<String, dynamic> _level(int id, String code, int order) =>
    <String, dynamic>{
      LevelColumns.id: id,
      LevelColumns.code: code,
      LevelColumns.title: code,
      LevelColumns.orderIndex: order,
    };

Map<String, dynamic> _lessonRow({
  required int id,
  required int levelId,
  required int order,
  required String status,
}) => <String, dynamic>{
  LessonsCatalogColumns.lessonId: id,
  LessonsCatalogColumns.levelId: levelId,
  LessonsCatalogColumns.levelCode: 'A1',
  LessonsCatalogColumns.levelTitle: 'A1',
  LessonsCatalogColumns.title: 'Ders $id',
  LessonsCatalogColumns.orderIndex: order,
  LessonsCatalogColumns.isPublished: true,
  LessonsCatalogColumns.hasContent: true,
  LessonsCatalogColumns.userStatus: status,
};

Map<String, dynamic> _grammarRow({
  required int id,
  required int levelId,
  required int order,
  required String status,
}) => <String, dynamic>{
  GrammarCatalogColumns.grammarTopicId: id,
  GrammarCatalogColumns.levelId: levelId,
  GrammarCatalogColumns.levelCode: 'A1',
  GrammarCatalogColumns.levelTitle: 'A1',
  GrammarCatalogColumns.title: 'Konu $id',
  GrammarCatalogColumns.orderIndex: order,
  GrammarCatalogColumns.isPublished: true,
  GrammarCatalogColumns.hasContent: true,
  GrammarCatalogColumns.userStatus: status,
};

Map<String, dynamic> _unlock(int levelId, String status) => <String, dynamic>{
  UserLevelProgressColumns.levelId: levelId,
  UserLevelProgressColumns.status: status,
};

void main() {
  group('LessonRemoteDataSource', () {
    late _FakeBackend backend;
    late LessonRemoteDataSourceImpl dataSource;

    setUp(() {
      backend = _FakeBackend(<String, List<Map<String, dynamic>>>{
        SupabaseTable.levels: <Map<String, dynamic>>[
          _level(1, 'A1', 1),
          _level(2, 'A2', 2),
        ],
        SupabaseView.lessonsCatalog: <Map<String, dynamic>>[
          _lessonRow(id: 10, levelId: 1, order: 1, status: 'completed'),
          _lessonRow(id: 11, levelId: 1, order: 2, status: 'in_progress'),
        ],
        SupabaseView.grammarCatalog: <Map<String, dynamic>>[
          _grammarRow(id: 5, levelId: 1, order: 1, status: 'not_started'),
        ],
        SupabaseTable.userLevelProgress: <Map<String, dynamic>>[
          _unlock(1, 'unlocked'),
          _unlock(2, 'locked'),
        ],
      });
      dataSource = LessonRemoteDataSourceImpl(backend);
    });

    test('seviyeler order_index ile 0tabanlı indekse çevrilir', () async {
      final List<LessonLevel> levels = await dataSource.fetchCatalog();

      expect(levels.map((LessonLevel l) => l.levelIndex), <int>[0, 1]);
    });

    test('ilerleme tamamlanan/total oranından hesaplanır', () async {
      final List<LessonLevel> levels = await dataSource.fetchCatalog();

      expect(levels.first.lessonProgress, 0.5);
      expect(levels.first.grammarProgress, 0);
    });

    test('katalog satırları doğru track altına gruplanır', () async {
      final List<LessonLevel> levels = await dataSource.fetchCatalog();
      final LessonLevel a1 = levels.first;

      expect(a1.lessonLessons.map((Lesson l) => l.title), <String>[
        'Ders 10',
        'Ders 11',
      ]);
      expect(a1.grammarLessons.single.title, 'Konu 5');
      expect(a1.grammarLessons.single.track, LessonTrack.grammar);
      expect(
        a1.lessonLessons.map((Lesson lesson) => lesson.isCompleted),
        <bool>[true, false],
      );
    });

    test('seviye testi kilidi user_level_progress.status ile açılır', () async {
      final List<LessonLevel> levels = await dataSource.fetchCatalog();

      expect(levels.first.levelTestUnlocked, isTrue);
      expect(levels[1].levelTestUnlocked, isFalse);
    });

    test('kilit satırı olmayan seviye açık sayılır', () async {
      backend = _FakeBackend(<String, List<Map<String, dynamic>>>{
        SupabaseTable.levels: <Map<String, dynamic>>[_level(3, 'B1', 3)],
      });
      dataSource = LessonRemoteDataSourceImpl(backend);

      final List<LessonLevel> levels = await dataSource.fetchCatalog();

      expect(levels.single.levelTestUnlocked, isTrue);
      expect(levels.single.grammarLessons, isEmpty);
    });

    test('dört okuma: levels + iki catalog + kilit tablosu', () async {
      await dataSource.fetchCatalog();

      expect(backend.queriedTables, <String>[
        SupabaseTable.levels,
        SupabaseView.lessonsCatalog,
        SupabaseView.grammarCatalog,
        SupabaseTable.userLevelProgress,
      ]);
    });

    test('başlatılmamış kapıda istek atmadan hata fırlatır', () async {
      final _UnavailableBackend unavailable = _UnavailableBackend();

      expect(
        () => LessonRemoteDataSourceImpl(unavailable).fetchCatalog(),
        throwsA(isA<BackendException>()),
      );
    });
  });

  group('LessonRepository', () {
    final List<LessonLevel> catalog = <LessonLevel>[
      const LessonLevel(
        levelIndex: 0,
        grammarLessons: <Lesson>[],
        lessonLessons: <Lesson>[],
      ),
    ];

    late _FakeLessonRemote remote;
    late _FakeNetworkInfo network;
    late LessonRepositoryImpl repository;

    setUp(() {
      remote = _FakeLessonRemote(levels: catalog);
      network = _FakeNetworkInfo(true);
      repository = LessonRepositoryImpl(remote, network);
    });

    test('bağlantı yoksa istek atmadan NetworkFailure döner', () async {
      network.connected = false;

      final result = await repository.fetchCatalog();

      expect(_leftOf(result), isA<NetworkFailure>());
      expect(remote.catalogCalls, 0);
    });

    test('RLS reddi PermissionFailure olarak ekrana düşer', () async {
      remote.levels = null;
      remote.errorCode = '42501';

      final result = await repository.fetchCatalog();

      expect(_leftOf(result), isA<PermissionFailure>());
      expect(_rightLevels(result), isNull);
    });

    test('başarılı okuma katalog listesini olduğu gibi geçirir', () async {
      final result = await repository.fetchCatalog();

      expect(_rightLevels(result), catalog);
      expect(remote.catalogCalls, 1);
    });
  });
}

/// `isReady` false kalan kapı: `client` asla dokunulmaz.
class _UnavailableBackend implements SupabaseBackend {
  @override
  bool get isReady => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Bu testte Supabase client kullanılmaz');
}
