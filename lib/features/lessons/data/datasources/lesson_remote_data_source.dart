import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/data/supabase_backend.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/models/lesson_models.dart';

/// Dersler sekmesinin uzak veri kaynağı.
///
/// Kural aynı: SDK tipleri burada doğmaz, yalnız `SupabaseBackend` üzerinden
/// `TableQuery` kullanılır; hata `BackendException` olarak yukarı çıkar.
/// Okuma ilerleme-duyarlı catalog görünümlerinden yapılır, ham `lessons` /
/// `grammar_topics` tablolarından değil — görünümler `is_published` filtrelerini
/// ve `auth.uid()` ilerleme eşleşmesini zaten içeriyor.
abstract class LessonRemoteDataSource {
  /// CEFR sırasına göre seviyeler; her seviyede iki track'in ders listesi ve
  /// tamamlanma oranı hazır gelir.
  Future<List<LessonLevel>> fetchCatalog();
}

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  LessonRemoteDataSourceImpl(this._backend);

  final SupabaseBackend _backend;

  static const String _completedStatus = 'completed';
  static const String _lockedStatus = 'locked';

  @override
  Future<List<LessonLevel>> fetchCatalog() async {
    final List<Map<String, dynamic>> levelRows = await _rows(
      TableQuery(
        SupabaseTable.levels,
        columns: LevelColumns.all,
        orderColumn: LevelColumns.orderIndex,
      ),
    );
    if (levelRows.isEmpty) return const <LessonLevel>[];

    final List<Map<String, dynamic>> lessonRows = await _rows(
      TableQuery(
        SupabaseView.lessonsCatalog,
        columns: LessonsCatalogColumns.all,
        orderColumn: LessonsCatalogColumns.orderIndex,
      ),
    );
    final List<Map<String, dynamic>> grammarRows = await _rows(
      TableQuery(
        SupabaseView.grammarCatalog,
        columns: GrammarCatalogColumns.all,
        orderColumn: GrammarCatalogColumns.orderIndex,
      ),
    );
    final List<Map<String, dynamic>> unlockRows = await _rows(
      TableQuery(SupabaseTable.userLevelProgress, columns: UserLevelProgressColumns.all),
    );

    // level_id -> arayüz seviye indeksi: `levels.order_index` 1'den başlar,
    // `LevelContent.cefrLevels` ve kart indeksi 0'dan.
    final Map<int, int> indexByLevel = <int, int>{
      for (final Map<String, dynamic> row in levelRows)
        _intOf(row[LevelColumns.id]): _intOf(row[LevelColumns.orderIndex]) - 1,
    };

    // level_id -> kullanıcının bu seviyedeki kilidi; imleç satırı yoksa seviye
    // açık sayılır, çünkü satırları kayıt tetikleyicisi kurar ve eksik satır
    // kilit kanıtı değildir.
    final Map<int, String> unlockStatus = <int, String>{
      for (final Map<String, dynamic> row in unlockRows)
        _intOf(row[UserLevelProgressColumns.levelId]):
            row[UserLevelProgressColumns.status] as String? ?? _lockedStatus,
    };

    final Map<int, List<Lesson>> lessonsByLevel = _groupByLevel(
      lessonRows,
      LessonTrack.lessons,
      indexByLevel,
      idKey: LessonsCatalogColumns.lessonId,
      levelKey: LessonsCatalogColumns.levelId,
      titleKey: LessonsCatalogColumns.title,
      orderKey: LessonsCatalogColumns.orderIndex,
      statusKey: LessonsCatalogColumns.userStatus,
    );
    final Map<int, List<Lesson>> grammarByLevel = _groupByLevel(
      grammarRows,
      LessonTrack.grammar,
      indexByLevel,
      idKey: GrammarCatalogColumns.grammarTopicId,
      levelKey: GrammarCatalogColumns.levelId,
      titleKey: GrammarCatalogColumns.title,
      orderKey: GrammarCatalogColumns.orderIndex,
      statusKey: GrammarCatalogColumns.userStatus,
    );

    return <LessonLevel>[
      for (final Map<String, dynamic> row in levelRows)
        _levelOf(
          row,
          lessons: lessonsByLevel[_intOf(row[LevelColumns.id])] ??
              const <Lesson>[],
          grammar: grammarByLevel[_intOf(row[LevelColumns.id])] ??
              const <Lesson>[],
          unlocked:
              unlockStatus[_intOf(row[LevelColumns.id])] != _lockedStatus,
        ),
    ];
  }

  /// Tek seviye satırını, iki track'in dersleriyle birlikte [LessonLevel]'e
  /// çevirir.
  LessonLevel _levelOf(
    Map<String, dynamic> row, {
    required List<Lesson> lessons,
    required List<Lesson> grammar,
    required bool unlocked,
  }) => LessonLevel(
    levelIndex: _intOf(row[LevelColumns.orderIndex]) - 1,
    grammarLessons: grammar,
    lessonLessons: lessons,
    grammarProgress: _completionRatio(grammar),
    lessonProgress: _completionRatio(lessons),
    levelTestUnlocked: unlocked,
  );

  Map<int, List<Lesson>> _groupByLevel(
    List<Map<String, dynamic>> rows,
    LessonTrack track,
    Map<int, int> indexByLevel, {
    required String idKey,
    required String levelKey,
    required String titleKey,
    required String orderKey,
    required String statusKey,
  }) {
    final Map<int, List<Lesson>> grouped = <int, List<Lesson>>{};
    for (final Map<String, dynamic> row in rows) {
      final int levelId = _intOf(row[levelKey]);
      grouped
          .putIfAbsent(levelId, () => <Lesson>[])
          .add(
            _lessonOf(
              row,
              track,
              indexByLevel[levelId] ?? 0,
              idKey,
              titleKey,
              orderKey,
              statusKey,
            ),
          );
    }
    return grouped;
  }

  /// Catalog görünümleri gövde taşımaz (`has_content` bayrağı yeterlidir);
  /// anlatım metni ve sorular detay çekildiğinde dolar.
  Lesson _lessonOf(
    Map<String, dynamic> row,
    LessonTrack track,
    int levelIndex,
    String idKey,
    String titleKey,
    String orderKey,
    String statusKey,
  ) => Lesson(
    id: _intOf(row[idKey]).toString(),
    levelIndex: levelIndex,
    track: track,
    order: _intOf(row[orderKey]),
    title: row[titleKey] as String,
    body: const <String>[],
    questions: const <LessonQuestion>[],
    isCompleted: (row[statusKey] as String?) == _completedStatus,
  );

  double _completionRatio(List<Lesson> lessons) => lessons.isEmpty
      ? 0
      : lessons.where((Lesson lesson) => lesson.isCompleted).length /
            lessons.length;

  Future<List<Map<String, dynamic>>> _rows(TableQuery query) {
    if (!_backend.isReady) {
      throw const BackendException(
        message: 'Supabase başlatılmamış; katalog okunamıyor.',
        code: 'backend_not_ready',
      );
    }
    return _backend.rows(query);
  }

  /// PostgREST `bigint`'i JSON'da sayı olarak döndürür, ama alan taşınırken
  /// metin de gelebilir; ikisi de tek yerden okunur.
  int _intOf(Object? value) => value is int ? value : int.parse('$value');
}
