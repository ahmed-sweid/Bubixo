import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/constants/supabase_tables.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/error/exceptions.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/models/word_models.dart';
import 'package:en_bubixo/core/network/network_info.dart';
import 'package:en_bubixo/features/words/data/datasources/word_remote_data_source.dart';
import 'package:en_bubixo/features/words/data/models/word_snapshot.dart';
import 'package:en_bubixo/features/words/data/repositories/word_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// `eq` ve `in` filtrelerini gerçekten uygulayan sahte kapı.
///
/// Filtreler yok sayılsaydı veri kaynağının "kapalı seviyeyi çekme" ve
/// "yalnız bu kelimelerin içeriğini getir" kararları test edilmezdi; sahte
/// kapı PostgREST'in yaptığı eleme taklit eder.
class _FakeBackend implements SupabaseBackend {
  _FakeBackend(this.tableRows);

  final Map<String, List<Map<String, dynamic>>> tableRows;
  final List<TableQuery> queries = <TableQuery>[];

  @override
  bool get isReady => true;

  @override
  Future<List<Map<String, dynamic>>> rows(TableQuery query) async {
    queries.add(query);
    final List<Map<String, dynamic>> source =
        tableRows[query.table] ?? const <Map<String, dynamic>>[];

    final List<Map<String, dynamic>> filtered = source.where((
      Map<String, dynamic> row,
    ) {
      for (final MapEntry<String, Object> filter in query.eq.entries) {
        if (row[filter.key] != filter.value) return false;
      }
      final String? inColumn = query.inColumn;
      final List<Object>? inValues = query.inValues;
      if (inColumn != null && inValues != null) {
        return inValues.contains(row[inColumn]);
      }
      return true;
    }).toList();

    final String? orderColumn = query.orderColumn;
    if (orderColumn != null) {
      filtered.sort(
        (Map<String, dynamic> a, Map<String, dynamic> b) =>
            (a[orderColumn] as int).compareTo(b[orderColumn] as int),
      );
    }
    final int? limit = query.limit;
    return limit == null
        ? filtered
        : filtered.take(limit).toList(growable: false);
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

class _FakeWordRemote implements WordRemoteDataSource {
  _FakeWordRemote({this.snapshot});

  WordSnapshot? snapshot;

  /// Doldurulursa veri kaynağı bu SQLSTATE ile patlar; repository'nin işi
  /// onu doğru `Failure`'a çevirmek.
  String? errorCode;
  int snapshotCalls = 0;

  @override
  Future<WordSnapshot> fetchSnapshot() async {
    snapshotCalls++;
    if (errorCode != null) {
      throw BackendException(message: 'sorgu reddedildi', code: errorCode!);
    }
    return snapshot ??
        const WordSnapshot(words: <Word>[], suggestedWords: <PoolWord>[]);
  }
}

Failure? _leftOf<T>(Either<Failure, T> either) =>
    either.fold(ifLeft: (f) => f, ifRight: (_) => null);

WordSnapshot? _rightSnapshot(Either<Failure, WordSnapshot> either) =>
    either.fold(ifLeft: (_) => null, ifRight: (r) => r);

Map<String, dynamic> _level(int id, String code, int order) => <String, dynamic>{
  LevelColumns.id: id,
  LevelColumns.code: code,
  LevelColumns.title: code,
  LevelColumns.orderIndex: order,
};

Map<String, dynamic> _unlock(int levelId, String status) => <String, dynamic>{
  UserLevelProgressColumns.levelId: levelId,
  UserLevelProgressColumns.status: status,
};

Map<String, dynamic> _progress(
  int wordId,
  String direction,
  String status,
) => <String, dynamic>{
  VocabularyWordProgressColumns.wordId: wordId,
  VocabularyWordProgressColumns.cardDirection: direction,
  VocabularyWordProgressColumns.status: status,
};

Map<String, dynamic> _wordRow({
  required int id,
  required int levelId,
  required int order,
  String word = 'x',
  String? tr = '?',
  List<String> tags = const <String>['greeting'],
  bool published = true,
}) => <String, dynamic>{
  VocabularyWordColumns.id: id,
  VocabularyWordColumns.levelId: levelId,
  VocabularyWordColumns.word: word,
  VocabularyWordColumns.translations: tr == null
      ? null
      : <String, dynamic>{'tr': tr},
  VocabularyWordColumns.tags: tags,
  VocabularyWordColumns.orderIndex: order,
  VocabularyWordColumns.isPublished: published,
};

void main() {
  group('WordRemoteDataSource', () {
    late _FakeBackend backend;
    late WordRemoteDataSourceImpl dataSource;

    setUp(() {
      backend = _FakeBackend(<String, List<Map<String, dynamic>>>{
        SupabaseTable.levels: <Map<String, dynamic>>[
          _level(1, 'A1', 1),
          _level(2, 'A2', 2),
        ],
        SupabaseTable.userLevelProgress: <Map<String, dynamic>>[
          _unlock(1, 'unlocked'),
          _unlock(2, 'locked'),
        ],
        SupabaseTable.vocabularyWordProgress: <Map<String, dynamic>>[
          // İki yönü olan kelime: tek yön hâlâ öğreniliyor.
          _progress(100, 'en_to_translation', 'learning'),
          _progress(100, 'translation_to_en', 'mastered'),
          _progress(101, 'en_to_translation', 'mastered'),
          _progress(101, 'translation_to_en', 'mastered'),
          // İlerleme satırı var ama içerik yayından kalkmış.
          _progress(999, 'en_to_translation', 'mastered'),
        ],
        SupabaseTable.vocabularyWords: <Map<String, dynamic>>[
          _wordRow(id: 100, levelId: 1, order: 1, word: 'hello', tr: 'merhaba'),
          _wordRow(id: 101, levelId: 1, order: 2, word: 'world', tr: 'dünya'),
          _wordRow(
            id: 102,
            levelId: 1,
            order: 3,
            word: 'cat',
            tr: 'kedi',
            tags: <String>['animal', 'home'],
          ),
          // Kapalı seviyenin kelimesi havuza girmemeli.
          _wordRow(id: 200, levelId: 2, order: 1, word: 'locked word'),
          // Yayından kalkmış içerik: öneri de kullanıcının listesi de olamaz.
          _wordRow(
            id: 999,
            levelId: 1,
            order: 4,
            word: 'retired',
            published: false,
          ),
          // Çevirisi eksik kelime: alan boş metinle taşınır.
          _wordRow(id: 103, levelId: 1, order: 5, word: 'bare', tr: null),
        ],
      });
      dataSource = WordRemoteDataSourceImpl(backend);
    });

    test('kelime tüm kart yönleri ezberlenmişse memorized olur', () async {
      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(
        snapshot.words.map((Word w) => <Object>[w.term, w.status]),
        <Object>[
          <Object>['hello', WordStatus.learning],
          <Object>['world', WordStatus.memorized],
        ],
      );
    });

    test('içeriği yayından kalkmış ilerleme satırı listeye girmez', () async {
      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(snapshot.words.map((Word w) => w.id), isNot(contains('999')));
    });

    test('öneriler kullanıcının planındaki kelimeleri dışlar', () async {
      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(snapshot.suggestedWords.map((PoolWord w) => w.term), <String>[
        'cat',
        'bare',
      ]);
    });

    test('kapalı seviyenin kelimeleri havuza girmez', () async {
      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(
        snapshot.suggestedWords.map((PoolWord w) => w.id),
        isNot(contains('200')),
      );
    });

    test('havuz kelimesi 0tabanlı seviye indeksi ve ilk etiketi taşır', () async {
      final WordSnapshot snapshot = await dataSource.fetchSnapshot();
      final PoolWord cat = snapshot.suggestedWords.first;

      expect(cat.levelIndex, 0);
      expect(cat.category, 'animal');
      expect(cat.translation, 'kedi');
    });

    test('etiketsiz ve çevirisiz kelime boş alanlarla taşınır', () async {
      backend.tableRows[SupabaseTable.vocabularyWords]!.last[
        VocabularyWordColumns.tags
      ] = <String>[];

      final WordSnapshot snapshot = await dataSource.fetchSnapshot();
      final PoolWord bare = snapshot.suggestedWords.last;

      expect(bare.term, 'bare');
      expect(bare.translation, isEmpty);
      expect(bare.category, isEmpty);
    });

    test('çeviri jsonb içinden tr anahtarı okunur', () async {
      backend.tableRows[SupabaseTable.vocabularyWords]!
          .first[VocabularyWordColumns.translations] = <String, dynamic>{
        'de': 'hallo',
        'tr': 'merhaba',
      };

      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(snapshot.words.first.translation, 'merhaba');
    });

    test('kilit satırı olmayan seviye açık sayılır', () async {
      backend = _FakeBackend(<String, List<Map<String, dynamic>>>{
        SupabaseTable.levels: <Map<String, dynamic>>[_level(7, 'B1', 7)],
        SupabaseTable.vocabularyWords: <Map<String, dynamic>>[
          _wordRow(id: 300, levelId: 7, order: 1, word: 'brave'),
        ],
      });
      dataSource = WordRemoteDataSourceImpl(backend);

      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(snapshot.suggestedWords.single.term, 'brave');
      expect(snapshot.words, isEmpty);
    });

    test('beş okuma sırası: seviye, kilit, ilerleme, içerik, havuz', () async {
      await dataSource.fetchSnapshot();

      expect(backend.queries.map((TableQuery q) => q.table), <String>[
        SupabaseTable.levels,
        SupabaseTable.userLevelProgress,
        SupabaseTable.vocabularyWordProgress,
        SupabaseTable.vocabularyWords,
        SupabaseTable.vocabularyWords,
      ]);
      expect(
        backend.queries.last.eq,
        <String, Object>{VocabularyWordColumns.isPublished: true},
      );
    });

    test('hiç seviye yoksa tek okuma ile boş snapshot döner', () async {
      backend = _FakeBackend(<String, List<Map<String, dynamic>>>{
        SupabaseTable.levels: const <Map<String, dynamic>>[],
      });
      dataSource = WordRemoteDataSourceImpl(backend);

      final WordSnapshot snapshot = await dataSource.fetchSnapshot();

      expect(snapshot.isEmpty, isTrue);
      expect(backend.queries, hasLength(1));
    });

    test('başlatılmamış kapıda istek atmadan hata fırlatır', () async {
      expect(
        () => WordRemoteDataSourceImpl(_UnavailableBackend()).fetchSnapshot(),
        throwsA(isA<BackendException>()),
      );
    });
  });

  group('WordRepository', () {
    final WordSnapshot snapshot = const WordSnapshot(
      words: <Word>[
        Word(
          id: '1',
          term: 'hello',
          translation: 'merhaba',
          status: WordStatus.learning,
        ),
      ],
      suggestedWords: <PoolWord>[],
    );

    late _FakeWordRemote remote;
    late _FakeNetworkInfo network;
    late WordRepositoryImpl repository;

    setUp(() {
      remote = _FakeWordRemote(snapshot: snapshot);
      network = _FakeNetworkInfo(true);
      repository = WordRepositoryImpl(remote, network);
    });

    test('bağlantı yoksa istek atmadan NetworkFailure döner', () async {
      network.connected = false;

      final result = await repository.fetchSnapshot();

      expect(_leftOf(result), isA<NetworkFailure>());
      expect(remote.snapshotCalls, 0);
    });

    test('oturumsuz okuma PermissionFailure olarak ekrana düşer', () async {
      remote.snapshot = null;
      remote.errorCode = '42501';

      final result = await repository.fetchSnapshot();

      expect(_leftOf(result), isA<PermissionFailure>());
      expect(_rightSnapshot(result), isNull);
    });

    test('başarılı okuma snapshotı olduğu gibi geçirir', () async {
      final result = await repository.fetchSnapshot();

      expect(_rightSnapshot(result), snapshot);
      expect(remote.snapshotCalls, 1);
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
