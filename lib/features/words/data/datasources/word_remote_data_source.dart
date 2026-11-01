import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/data/supabase_backend.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/word_models.dart';
import '../models/word_snapshot.dart';

/// Kelimeler sekmesinin uzak veri kaynağı.
///
/// Canlı şema iki parçalı: yayınlanmış içerik `vocabulary_words`'ta,
/// kullanıcının ezber planı `vocabulary_word_progress`'te durur. İlerleme
/// satırları kelime başına değil kelime-yönü başınadır
/// (`user_id, word_id, card_direction` benzersiz), bu yüzden bir kelimenin
/// durumu kendi satırlarının birleşiminden çıkarılır.
abstract class WordRemoteDataSource {
  Future<WordSnapshot> fetchSnapshot();
}

class WordRemoteDataSourceImpl implements WordRemoteDataSource {
  WordRemoteDataSourceImpl(this._backend);

  final SupabaseBackend _backend;

  static const String _masteredStatus = 'mastered';
  static const String _lockedStatus = 'locked';

  /// Öneri havuzu sonsuz okunamaz; seviye başına bu kadar kelime ekrana yeter.
  static const int _poolLimitPerLevel = 30;

  @override
  Future<WordSnapshot> fetchSnapshot() async {
    final List<Map<String, dynamic>> levelRows = await _rows(
      TableQuery(
        SupabaseTable.levels,
        columns: LevelColumns.all,
        orderColumn: LevelColumns.orderIndex,
      ),
    );
    if (levelRows.isEmpty) {
      return const WordSnapshot(words: <Word>[], suggestedWords: <PoolWord>[]);
    }

    final Map<int, int> indexByLevel = <int, int>{
      for (final Map<String, dynamic> row in levelRows)
        _intOf(row[LevelColumns.id]): _intOf(row[LevelColumns.orderIndex]) - 1,
    };

    // Seviye satırı eksikse kilit kanıtı yoktur: kayıt tetikleyicisi satırı
    // sonradan kurar, bu yüzden varsayılan açık.
    final List<Map<String, dynamic>> unlockRows = await _rows(
      TableQuery(
        SupabaseTable.userLevelProgress,
        columns: UserLevelProgressColumns.all,
      ),
    );
    final Map<int, String> statusByLevel = <int, String>{
      for (final Map<String, dynamic> row in unlockRows)
        _intOf(row[UserLevelProgressColumns.levelId]):
            row[UserLevelProgressColumns.status] as String? ?? _lockedStatus,
    };
    final List<int> unlockedLevelIds = indexByLevel.keys
        .where((int levelId) => statusByLevel[levelId] != _lockedStatus)
        .toList(growable: false);

    final List<Map<String, dynamic>> progressRows = await _rows(
      TableQuery(
        SupabaseTable.vocabularyWordProgress,
        columns: VocabularyWordProgressColumns.all,
      ),
    );
    final Map<int, List<Map<String, dynamic>>> progressByWord =
        <int, List<Map<String, dynamic>>>{};
    for (final Map<String, dynamic> row in progressRows) {
      progressByWord
          .putIfAbsent(_intOf(row[VocabularyWordProgressColumns.wordId]), () =>
              <Map<String, dynamic>>[])
          .add(row);
    }

    // RLS ilerleme satırlarını zaten sahibine göre süzüyor; buradaki liste
    // yalnız o kelimelerin içeriğini çeker. `is_published` filtresi burada da
    // gerekir: yayından kalkmış içerik ilerlemede duruyorsa kartı çizilemez.
    final Map<int, Map<String, dynamic>> contentByWord =
        <int, Map<String, dynamic>>{};
    final List<int> progressedWordIds = progressByWord.keys.toList(
      growable: false,
    );
    if (progressedWordIds.isNotEmpty) {
      for (final Map<String, dynamic> row in await _rows(
        TableQuery(
          SupabaseTable.vocabularyWords,
          columns: VocabularyWordColumns.all,
          eq: <String, Object>{
            VocabularyWordColumns.isPublished: true,
          },
          inColumn: VocabularyWordColumns.id,
          inValues: progressedWordIds.cast<Object>(),
          orderColumn: VocabularyWordColumns.orderIndex,
        ),
      )) {
        contentByWord[_intOf(row[VocabularyWordColumns.id])] = row;
      }
    }

    final List<Map<String, dynamic>> poolRows = unlockedLevelIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _rows(
            TableQuery(
              SupabaseTable.vocabularyWords,
              columns: VocabularyWordColumns.all,
              eq: <String, Object>{
                VocabularyWordColumns.isPublished: true,
              },
              inColumn: VocabularyWordColumns.levelId,
              inValues: unlockedLevelIds.cast<Object>(),
              orderColumn: VocabularyWordColumns.orderIndex,
              limit: unlockedLevelIds.length * _poolLimitPerLevel,
            ),
          );

    final List<Word> words = <Word>[
      for (final MapEntry<int, Map<String, dynamic>> entry
          in contentByWord.entries)
        _word(entry.value, progressByWord[entry.key]!),
    ];

    // Öneri, kullanıcının planında olmayan kelimedir; yayından kalkmış içerik
    // ilerlemede dursa bile ekrana çıkmaz.
    final List<PoolWord> suggested = <PoolWord>[
      for (final Map<String, dynamic> row in poolRows)
        if (!progressByWord.containsKey(_intOf(row[VocabularyWordColumns.id])))
          _poolWord(row, indexByLevel),
    ];

    return WordSnapshot(words: words, suggestedWords: suggested);
  }

  /// Bir kelimenin tüm kart yönleri ezberlenmişse kelime ezberlenmiş sayılır;
  /// tek yön bile öğreniliyorsa kart hâlâ çalışıyor demektir.
  Word _word(
    Map<String, dynamic> content,
    List<Map<String, dynamic>> progressRows,
  ) => Word(
    id: _intOf(content[VocabularyWordColumns.id]).toString(),
    term: content[VocabularyWordColumns.word] as String,
    translation: _translation(content),
    status: progressRows.every(
          (Map<String, dynamic> row) =>
              row[VocabularyWordProgressColumns.status] == _masteredStatus,
        )
        ? WordStatus.memorized
        : WordStatus.learning,
  );

  PoolWord _poolWord(Map<String, dynamic> row, Map<int, int> indexByLevel) =>
      PoolWord(
        id: _intOf(row[VocabularyWordColumns.id]).toString(),
        term: row[VocabularyWordColumns.word] as String,
        translation: _translation(row),
        category: _category(row),
        levelIndex:
            indexByLevel[_intOf(row[VocabularyWordColumns.levelId])] ?? 0,
      );

  /// `translations` jsonb bir dil haritası (`{"tr": "…"}`); arayüz tek çeviri
  /// gösterir ve Türkçe anahtarı kullanır.
  String _translation(Map<String, dynamic> row) {
    final Object? translations = row[VocabularyWordColumns.translations];
    if (translations is Map && translations['tr'] is String) {
      return translations['tr']! as String;
    }
    return '';
  }

  /// `tags` text[] — keşfet filtresi ilk etiketi kategori olarak kullanır.
  String _category(Map<String, dynamic> row) {
    final Object? tags = row[VocabularyWordColumns.tags];
    if (tags is List && tags.isNotEmpty && tags.first is String) {
      return tags.first! as String;
    }
    return '';
  }

  Future<List<Map<String, dynamic>>> _rows(TableQuery query) {
    if (!_backend.isReady) {
      throw const BackendException(
        message: 'Supabase başlatılmamış; kelimeler okunamıyor.',
        code: 'backend_not_ready',
      );
    }
    return _backend.rows(query);
  }

  int _intOf(Object? value) => value is int ? value : int.parse('$value');
}
