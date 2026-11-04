import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/constants/supabase_tables.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/error/exceptions.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/network/network_info.dart';
import 'package:en_bubixo/features/level/data/datasources/placement_remote_data_source.dart';
import 'package:en_bubixo/features/level/data/models/placement_models.dart';
import 'package:en_bubixo/features/level/data/repositories/placement_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// RPC'leri kaydedip hazır jsonb dönen sahte kapı.
///
/// Yanıtlar canlı projeden (`placement_*` RPC'leri, 2026-11-01) alındığı gibi
/// kurgulandı; alan adı eşlemesi burada bozulursa test kırılır.
class _FakeBackend implements SupabaseBackend {
  _FakeBackend();

  bool ready = true;

  /// Sıradaki `rpc` çağrısında fırlatılacak hata.
  Object? failure;

  /// Çağrı başına sırayla döndürülür.
  final List<Object?> responses = <Object?>[];

  final List<String> names = <String>[];
  final List<Map<String, dynamic>?> params = <Map<String, dynamic>?>[];

  @override
  bool get isReady => ready;

  @override
  Future<dynamic> rpc(String name, [Map<String, dynamic>? requestParams]) async {
    names.add(name);
    params.add(requestParams);
    final Object? error = failure;
    if (error != null) {
      throw error;
    }
    if (responses.isEmpty) {
      throw StateError('Sahte kapıda yanıt kuyruğu boş: $name');
    }
    return responses.removeAt(0);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Seviye testi yalnız rpc kullanır');
}

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

Map<String, dynamic> _question({
  int id = 1,
  String code = 'A1_S1_01',
  int stage = 1,
  String level = 'A1',
}) => <String, dynamic>{
  'id': id,
  'code': code,
  'stage': stage,
  'cefr_level': level,
  'skill': 'language_knowledge',
  'domain': 'grammar',
  'question_type': 'single_choice',
  'prompt': 'She $code to work every day.',
  'options': <Map<String, String>>[
    <String, String>{'id': 'a', 'text': 'have'},
    <String, String>{'id': 'b', 'text': 'has'},
  ],
  'media_url': null,
  // Açıklama soruyla birlikte gelir; doğruluk kararı vermez.
  'explanation': 'Özne üçüncü tekil şahısta fiil -s alır.',
  'points': 1,
};

Map<String, dynamic> _routeQuestion({int stage = 1, Map<String, dynamic>? question}) =>
    <String, dynamic>{
      'finished': false,
      'stage': stage,
      'question': question ?? _question(),
      'level': 'A1',
      'confidence': 'medium',
    };

Map<String, dynamic> _routeFinished() => <String, dynamic>{
  'finished': true,
  'stage': 2,
  'question': null,
  'level': 'B1',
  'confidence': 'high',
  'answered': 18,
  'correct': 9,
  'score': 50.0,
  'skill_scores': <String, dynamic>{},
  'attempt_number': 1,
};

Map<String, dynamic> _startPayload({Map<String, dynamic>? route}) =>
    <String, dynamic>{
      'test': <String, dynamic>{
        'id': 3,
        'code': 'PLACEMENT_V1',
        'title': 'Seviye belirleme testi',
        'description': 'Kaç soru, hangi seviye?',
        'version': 1,
      },
      'attempt': <String, dynamic>{
        'id': 11,
        'attempt_number': 1,
        'status': 'in_progress',
        'stage': 1,
      },
      'route': route ?? _routeQuestion(),
    };

void main() {
  group('placement veri kaynağı', () {
    late _FakeBackend backend;
    late PlacementRemoteDataSourceImpl dataSource;

    setUp(() {
      backend = _FakeBackend();
      dataSource = PlacementRemoteDataSourceImpl(backend);
    });

    test('başlatma yayınlanmış testi, oturumu ve ilk soruyu çözümler', () async {
      backend.responses.add(_startPayload());

      final PlacementSession? session = await dataSource.startAttempt();

      expect(backend.names, <String>[SupabaseRpc.placementStartAttempt]);
      expect(backend.params.single, isNull);
      expect(session, isNotNull);
      expect(session!.isEmpty, isFalse);
      expect(session.test?.title, 'Seviye belirleme testi');
      expect(session.test?.version, 1);
      expect(session.attemptId, '11');
      expect(session.attemptNumber, 1);
      expect(session.route.finished, isFalse);
      expect(session.route.stage, 1);
      expect(session.route.outcome, isNull);

      final PlacementQuestion question = session.route.question!;
      expect(question.id, '1');
      expect(question.code, 'A1_S1_01');
      expect(question.cefrLevel, 'A1');
      expect(question.options.map((PlacementOption o) => o.id), <String>[
        'a',
        'b',
      ]);
    });

    test('soru yükü cevap anahtarı taşımaz — modelde böyle bir alan yok', () async {
      // Sunucu yanlışlıkla anahtarı sızdırsa bile istemci onu okuyamaz:
      // modelde karşılığı olmayan alan yok sayılır.
      backend.responses.add(
        _startPayload(
          route: _routeQuestion(
            question: <String, dynamic>{
              ..._question(),
              'correct_answer': <String, String>{'id': 'b'},
            },
          ),
        ),
      );

      final PlacementSession session = (await dataSource.startAttempt())!;
      final PlacementQuestion question = session.route.question!;

      expect(question.options.length, 2);
      expect(question.prompt, contains('A1_S1_01'));
    });

    test('yayınlanmış test yoksa hata değil null döner', () async {
      backend.responses.add(<String, dynamic>{'test': null});

      expect(await dataSource.startAttempt(), isNull);
    });

    test('cevap gönderimi RPC parametrelerini ve sonraki adımı çevirir', () async {
      backend.responses.add(<String, dynamic>{
        'is_correct': false,
        'points_awarded': 0,
        'question_id': 1,
        'selected_answer_id': 'a',
        'explanation': 'Özne üçüncü tekil şahısta fiil -s alır.',
        'route': _routeQuestion(stage: 1, question: _question(id: 2, code: 'A1_S1_02')),
      });

      final PlacementAnswer answer = await dataSource.submitAnswer(
        attemptId: '11',
        questionId: '1',
        answerId: 'a',
        responseTimeMs: 1200,
      );

      expect(backend.names, <String>[SupabaseRpc.placementSubmitAnswer]);
      expect(backend.params.single, <String, dynamic>{
        'p_attempt_id': 11,
        'p_question_id': 1,
        'p_answer': <String, String>{'id': 'a'},
        'p_response_time_ms': 1200,
      });
      expect(answer.isCorrect, isFalse);
      expect(answer.pointsAwarded, 0);
      // Kullanıcının kendi seçimi döner; anahtar değil.
      expect(answer.selectedAnswerId, 'a');
      expect(answer.explanation, isNotNull);
      expect(answer.route.question?.id, '2');
    });

    test('kapanış yolu özeti seviye tahminiyle birlikte verir', () async {
      backend.responses.add(<String, dynamic>{
        'is_correct': true,
        'points_awarded': 1,
        'question_id': 18,
        'selected_answer_id': 'b',
        'explanation': null,
        'route': _routeFinished(),
      });

      final PlacementAnswer answer = await dataSource.submitAnswer(
        attemptId: '11',
        questionId: '18',
        answerId: 'b',
      );

      expect(answer.route.finished, isTrue);
      expect(answer.route.question, isNull);
      final PlacementOutcome outcome = answer.route.outcome!;
      expect(outcome.level, 'B1');
      expect(outcome.confidence, 'high');
      expect(outcome.totalQuestions, 18);
      expect(outcome.correctAnswers, 9);
      expect(outcome.score, 50.0);
      expect(outcome.attemptNumber, 1);
    });

    test('sonuç okuma get_result alanlarını modele taşır', () async {
      backend.responses.add(<String, dynamic>{
        'attempt_id': 11,
        'status': 'completed',
        'stage': 2,
        'attempt_number': 2,
        'level': 'A2',
        'confidence': 'medium',
        'answered': 15,
        'correct': 7,
        'score': 46.67,
        'skill_scores': <String, dynamic>{},
        'result_notes': <String, dynamic>{'rule': 'band_evidence_v1'},
        'started_at': '2026-11-01T14:00:00Z',
        'submitted_at': '2026-11-01T14:05:00Z',
      });

      final PlacementOutcome outcome = await dataSource.fetchResult('11');

      expect(backend.names, <String>[SupabaseRpc.placementGetResult]);
      expect(backend.params.single, <String, dynamic>{'p_attempt_id': 11});
      expect(outcome.attemptId, '11');
      expect(outcome.attemptNumber, 2);
      expect(outcome.level, 'A2');
      expect(outcome.confidence, 'medium');
      expect(outcome.totalQuestions, 15);
    });

    test('bigint string olarak gelirse yine sayıya çevrilir', () async {
      // PostgREST bazı kurulumlarda large integer'ı string taşır.
      backend.responses.add(<String, dynamic>{
        'test': <String, dynamic>{
          'id': '3',
          'code': 'PLACEMENT_V1',
          'title': 'Seviye belirleme testi',
          'description': null,
          'version': '1',
        },
        'attempt': <String, dynamic>{
          'id': '11',
          'attempt_number': '1',
          'status': 'in_progress',
          'stage': '1',
        },
        'route': <String, dynamic>{
          'finished': false,
          'stage': '2',
          'question': _question(stage: 2),
        },
      });

      final PlacementSession session = (await dataSource.startAttempt())!;

      expect(session.attemptId, '11');
      expect(session.route.stage, 2);
      expect(session.test?.version, 1);
    });

    test('yanıt biçimi bozuksa bad_response ile patlar', () async {
      backend.responses.add(<String, dynamic>{'test': _startPayload()['test']});

      expect(
        () => dataSource.startAttempt(),
        throwsA(
          isA<BackendException>().having(
            (BackendException e) => e.code,
            'code',
            'bad_response',
          ),
        ),
      );
    });

    test('kapı hazır değilse RPC hiç çağrılmaz', () async {
      backend.ready = false;

      expect(
        () => dataSource.startAttempt(),
        throwsA(
          isA<BackendException>().having(
            (BackendException e) => e.code,
            'code',
            'backend_not_ready',
          ),
        ),
      );
      expect(backend.names, isEmpty);
    });
  });

  group('placement repository', () {
    late _FakeBackend backend;
    late PlacementRemoteDataSourceImpl remote;
    late _FakeNetworkInfo network;
    late PlacementRepository repository;

    setUp(() {
      backend = _FakeBackend();
      remote = PlacementRemoteDataSourceImpl(backend);
      network = _FakeNetworkInfo(true);
      repository = PlacementRepositoryImpl(remote, network);
    });

    test('çevrimdışıyken hiç istek atmadan NetworkFailure', () async {
      network.connected = false;

      final Either<Failure, PlacementSession?> result =
          await repository.startAttempt();

      expect(result.fold(ifLeft: (Failure f) => f, ifRight: (Object? _) => null),
          isA<NetworkFailure>());
      expect(backend.names, isEmpty);
    });

    test('oturum yoksa PermissionFailure Türkçe metinle iner', () async {
      backend.failure = const BackendException(
        message: 'seviye testi oturumu icin giris gerekli',
        code: '42501',
      );

      final Either<Failure, PlacementSession?> result =
          await repository.startAttempt();

      final Failure failure = result.fold(
        ifLeft: (Failure f) => f,
        ifRight: (Object? _) => throw StateError('beklenen Left gelmedi'),
      );
      expect(failure, isA<PermissionFailure>());
      expect(failure.errorMessage, isNotEmpty);
    });

    test('çift cevap ConflictFailure, kapalı oturum ValidationFailure olur', () async {
      backend.failure = const BackendException(
        message: 'bu soru bu oturumda zaten cevaplanmis',
        code: '23505',
      );
      final Either<Failure, PlacementAnswer> doubleAnswer =
          await repository.submitAnswer(
            attemptId: '11',
            questionId: '1',
            answerId: 'a',
          );
      expect(
        doubleAnswer.fold(
          ifLeft: (Failure f) => f,
          ifRight: (Object? _) => throw StateError('beklenen Left gelmedi'),
        ),
        isA<ConflictFailure>(),
      );

      backend.failure = const BackendException(
        message: 'kapali oturuma cevap yazilamaz',
        code: '23514',
      );
      final Either<Failure, PlacementOutcome> closed =
          await repository.fetchResult('11');
      expect(
        closed.fold(
          ifLeft: (Failure f) => f,
          ifRight: (Object? _) => throw StateError('beklenen Left gelmedi'),
        ),
        isA<ValidationFailure>(),
      );
    });

    test('başarılı adım Right olarak geçer', () async {
      backend.responses.add(_startPayload());

      final Either<Failure, PlacementSession?> result =
          await repository.startAttempt();

      expect(
        result.fold(ifLeft: (Failure f) => f, ifRight: (PlacementSession? s) => s),
        isA<PlacementSession>(),
      );
    });

    test('sonuç okuma da aynı kapıdan geçer', () async {
      backend.responses.add(<String, dynamic>{
        'attempt_id': 11,
        'status': 'completed',
        'stage': 2,
        'attempt_number': 1,
        'level': 'B1',
        'confidence': 'high',
        'answered': 18,
        'correct': 9,
        'score': 50.0,
      });

      final Either<Failure, PlacementOutcome> result =
          await repository.fetchResult('11');

      final PlacementOutcome outcome = result.fold(
        ifLeft: (Failure f) => throw StateError('beklenen Right gelmedi: $f'),
        ifRight: (PlacementOutcome o) => o,
      );
      expect(outcome.level, 'B1');
    });
  });
}
