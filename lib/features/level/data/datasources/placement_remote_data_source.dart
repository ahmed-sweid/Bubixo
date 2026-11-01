import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/data/supabase_backend.dart';
import '../../../../core/error/exceptions.dart';
import '../models/placement_models.dart';

/// Seviye belirleme testinin uzak veri kaynağı.
///
/// Üç RPC tek yönlü akışı kurar: başlat (`placement_start_attempt`), cevabı
/// gönder (`placement_submit_answer`), sonucu oku (`placement_get_result`).
/// Soru seçimi, doğrulama ve seviye tahmi istemcide değil Postgres'te
/// yapılır; bu yüzden burada doğru cevap alanı aramak bile anlamsız —
/// sunucu öyle bir alan göndermez.
abstract class PlacementRemoteDataSource {
  /// Yayınlanmış test yoksa null döner; hata değildir, boş durumdur.
  Future<PlacementSession?> startAttempt();

  Future<PlacementAnswer> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
    int? responseTimeMs,
  });

  Future<PlacementOutcome> fetchResult(String attemptId);
}

class PlacementRemoteDataSourceImpl implements PlacementRemoteDataSource {
  PlacementRemoteDataSourceImpl(this._backend);

  final SupabaseBackend _backend;

  @override
  Future<PlacementSession?> startAttempt() async {
    final Map<String, dynamic> payload = await _call(
      SupabaseRpc.placementStartAttempt,
      null,
    );

    final Object? test = payload['test'];
    if (test is! Map) {
      return null;
    }

    final Object? attempt = payload['attempt'];
    return PlacementSession(
      test: _test(test),
      attemptId: _idOf(attempt, 'id'),
      attemptNumber: _intOf(attempt, 'attempt_number'),
      route: _route(payload['route']),
    );
  }

  @override
  Future<PlacementAnswer> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
    int? responseTimeMs,
  }) async {
    final Map<String, dynamic> payload = await _call(
      SupabaseRpc.placementSubmitAnswer,
      <String, dynamic>{
        'p_attempt_id': int.parse(attemptId),
        'p_question_id': int.parse(questionId),
        'p_answer': <String, String>{'id': answerId},
        'p_response_time_ms': responseTimeMs,
      },
    );

    return PlacementAnswer(
      isCorrect: payload['is_correct'] as bool?,
      pointsAwarded: payload['points_awarded'] as num?,
      selectedAnswerId: (payload['selected_answer_id'] as String?) ?? answerId,
      explanation: payload['explanation'] as String?,
      route: _route(payload['route']),
    );
  }

  @override
  Future<PlacementOutcome> fetchResult(String attemptId) async {
    final Map<String, dynamic> payload = await _call(
      SupabaseRpc.placementGetResult,
      <String, dynamic>{'p_attempt_id': int.parse(attemptId)},
    );
    return _outcome(payload);
  }

  PlacementTest _test(Map<Object?, Object?> row) => PlacementTest(
    id: _idOf(row, 'id'),
    code: row['code'] as String? ?? '',
    title: row['title'] as String? ?? '',
    version: _intOf(row, 'version'),
    description: row['description'] as String?,
  );

  PlacementRoute _route(Object? value) {
    final Map<String, dynamic> route = _map(value, 'route');
    final bool finished = route['finished'] == true;
    final Object? question = route['question'];
    return PlacementRoute(
      finished: finished,
      stage: _intOf(route, 'stage'),
      question: finished || question is! Map ? null : _question(question),
      outcome: finished ? _outcome(route) : null,
    );
  }

  PlacementQuestion _question(Map<Object?, Object?> row) => PlacementQuestion(
    id: _idOf(row, 'id'),
    code: row['code'] as String? ?? '',
    stage: _intOf(row, 'stage'),
    cefrLevel: row['cefr_level'] as String? ?? '',
    prompt: row['prompt'] as String? ?? '',
    options: _options(row['options']),
  );

  /// `options` jsonb dizisi `[{"id": "a", "text": "…"}]`.
  List<PlacementOption> _options(Object? value) {
    if (value is! List) {
      return const <PlacementOption>[];
    }
    return <PlacementOption>[
      for (final Object? option in value)
        if (option is Map)
          PlacementOption(
            id: '${option['id'] ?? ''}',
            text: '${option['text'] ?? ''}',
          ),
    ];
  }

  PlacementOutcome _outcome(Map<String, dynamic> source) => PlacementOutcome(
    level: source['level'] as String?,
    confidence: source['confidence'] as String?,
    totalQuestions: source['answered'] is int
        ? source['answered']! as int
        : int.tryParse('${source['answered'] ?? 0}') ?? 0,
    correctAnswers: source['correct'] is int
        ? source['correct']! as int
        : int.tryParse('${source['correct'] ?? 0}') ?? 0,
    score: source['score'] as num?,
    attemptId: source['attempt_id'] == null ? null : '${source['attempt_id']}',
    attemptNumber: source['attempt_number'] is int
        ? source['attempt_number']! as int
        : int.tryParse('${source['attempt_number'] ?? ''}'),
  );

  Future<Map<String, dynamic>> _call(String name, Map<String, dynamic>? params) async {
    if (!_backend.isReady) {
      throw const BackendException(
        message: 'Supabase başlatılmamış; seviye testi çalıştırılamıyor.',
        code: 'backend_not_ready',
      );
    }
    final Object? value = await _backend.rpc(name, params);
    if (value is! Map) {
      throw BackendException(
        message: '`$name` beklenen jsonb yanıtını döndürmedi.',
        code: 'bad_response',
      );
    }
    return value.cast<String, dynamic>();
  }

  Map<String, dynamic> _map(Object? value, String field) {
    if (value is! Map) {
      throw BackendException(
        message: 'Seviye testi yanıtında `$field` yok.',
        code: 'bad_response',
      );
    }
    return value.cast<String, dynamic>();
  }

  String _idOf(Object? value, String field) {
    if (value is! Map || value[field] == null) {
      throw BackendException(
        message: 'Seviye testi yanıtında `$field` yok.',
        code: 'bad_response',
      );
    }
    return '${value[field]}';
  }

  /// PostgREST large integer'ları string olarak da taşıyabilir; ikisi de
  /// geçerli, sessizce 0'a düşürmek yerine çözülmesi zor hata fırlatılır.
  int _intOf(Object? row, String field) {
    final Object? value = row is Map ? row[field] : null;
    if (value is int) {
      return value;
    }
    return int.tryParse('${value ?? ''}') ??
        (throw BackendException(
          message: 'Seviye testi yanıtında `$field` sayı değil.',
          code: 'bad_response',
        ));
  }
}
