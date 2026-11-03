import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/data/supabase_backend.dart';
import '../../../../core/error/exceptions.dart';
import '../models/level_models.dart';

/// Seviye kataloğu ve seviye imzasının uzak veri kaynağı.
///
/// Okuma iki yerden: liste `public.levels` (anon açık), imza
/// `public.profiles` (yalnız sahibi). Yazma iki RPC'den geçer; imza kolonuna
/// ham `update` yazılmaz, çünkü asıl işlem ilerleme defteriyle aynı
/// atomiklikte olmak zorunda.
abstract class LevelRemoteDataSource {
  /// Kataloğu `order_index` artan sırayla verir.
  Future<List<AppLevel>> fetchLevels();

  /// Kullanıcının şu anki seviyesi; hiç seçim yapmadıysa `null`.
  Future<AppLevel?> fetchCurrentLevel();

  Future<AppLevel> saveLevel({
    required String levelId,
    required LevelSource source,
  });

  /// Yerleştirme testinin sonucunu imza olarak uygular. Seviyeyi sunucu
  /// kendi oturum kaydından çözer — istemci bir bandı "benim testim" diye
  /// gönderemez.
  Future<AppLevel> applyPlacementResult(String attemptId);
}

class LevelRemoteDataSourceImpl implements LevelRemoteDataSource {
  LevelRemoteDataSourceImpl(this._backend);

  final SupabaseBackend _backend;

  @override
  Future<List<AppLevel>> fetchLevels() async {
    final List<Map<String, dynamic>> rows = await _ready(
      () => _backend.rows(
        const TableQuery(
          SupabaseTable.levels,
          columns: LevelColumns.all,
          orderColumn: LevelColumns.orderIndex,
        ),
      ),
    );
    return rows.map((Map<String, dynamic> row) => _level(row, LevelColumns.id))
        .toList(growable: false);
  }

  @override
  Future<AppLevel?> fetchCurrentLevel() async {
    final Map<String, dynamic>? profile = await _ready(
      () => _backend.row(
        const TableQuery(
          SupabaseTable.profiles,
          columns: ProfileColumns.currentLevelId,
        ),
      ),
    );

    final Object? levelId = profile?[ProfileColumns.currentLevelId];
    if (levelId == null) {
      return null;
    }

    final Map<String, dynamic>? row = await _ready(
      () => _backend.row(
        TableQuery(
          SupabaseTable.levels,
          columns: LevelColumns.all,
          eq: <String, Object>{LevelColumns.id: levelId},
        ),
      ),
    );
    return row == null ? null : _level(row, LevelColumns.id);
  }

  @override
  Future<AppLevel> saveLevel({
    required String levelId,
    required LevelSource source,
  }) async {
    final Map<String, dynamic> payload = await _rpc(
      SupabaseRpc.setUserLevel,
      <String, dynamic>{
        'p_level_id': int.parse(levelId),
        'p_source': source.wireValue,
      },
    );
    return _level(payload, 'level_id');
  }

  @override
  Future<AppLevel> applyPlacementResult(String attemptId) async {
    final Map<String, dynamic> payload = await _rpc(
      SupabaseRpc.applyPlacementResult,
      <String, dynamic>{'p_attempt_id': int.parse(attemptId)},
    );
    return _level(payload, 'level_id');
  }

  /// RPC yanıtı ile katalog satırı aynı alan adlarını taşır; yalnız seviye
  /// kimliği RPC'de `level_id` diye anılır.
  AppLevel _level(Map<String, dynamic> source, String idField) {
    final Object? id = source[idField];
    if (id == null) {
      throw BackendException(
        message: 'Seviye kaydında `$idField` alanı yok.',
        code: 'bad_response',
      );
    }
    final Object? order = source[LevelColumns.orderIndex];
    return AppLevel(
      id: '$id',
      code: '${source[LevelColumns.code] ?? ''}',
      title: '${source[LevelColumns.title] ?? ''}',
      orderIndex: order is int ? order : int.tryParse('$order') ?? 0,
    );
  }

  Future<Map<String, dynamic>> _rpc(
    String name,
    Map<String, dynamic> params,
  ) async {
    final Object? value = await _ready(() => _backend.rpc(name, params));
    if (value is! Map) {
      throw BackendException(
        message: '`$name` beklenen jsonb yanıtını döndürmedi.',
        code: 'bad_response',
      );
    }
    return value.cast<String, dynamic>();
  }

  Future<T> _ready<T>(Future<T> Function() request) async {
    if (!_backend.isReady) {
      throw const BackendException(
        message: 'Supabase başlatılmamış; seviye kaydı okunamıyor.',
        code: 'backend_not_ready',
      );
    }
    return request();
  }
}
