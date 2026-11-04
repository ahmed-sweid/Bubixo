import 'dart:async';

import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/features/level/cubit/level_test_cubit.dart';
import 'package:en_bubixo/features/level/data/models/level_models.dart';
import 'package:en_bubixo/features/level/data/models/placement_models.dart';
import 'package:en_bubixo/features/level/data/repositories/level_repository.dart';
import 'package:en_bubixo/features/level/data/repositories/placement_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const PlacementQuestion _a1 = PlacementQuestion(
  id: '11',
  code: 'A1_S1_01',
  stage: 1,
  cefrLevel: 'A1',
  prompt: 'Pick one.',
  options: <PlacementOption>[
    PlacementOption(id: 'a', text: 'alpha'),
    PlacementOption(id: 'b', text: 'beta'),
  ],
);

const PlacementQuestion _b1 = PlacementQuestion(
  id: '22',
  code: 'B1_S2_01',
  stage: 2,
  cefrLevel: 'B1',
  prompt: 'Pick another.',
  options: <PlacementOption>[PlacementOption(id: 'a', text: 'charlie')],
);

PlacementRoute _route(PlacementQuestion question) => PlacementRoute(
  finished: false,
  stage: question.stage,
  outcome: null,
  question: question,
);

PlacementRoute _finished(String level, {PlacementOutcome? outcome}) =>
    PlacementRoute(
      finished: true,
      stage: 2,
      question: null,
      outcome:
          outcome ??
          PlacementOutcome(
            level: level,
            confidence: 'high',
            totalQuestions: 3,
            correctAnswers: 2,
            score: 66,
          ),
    );

class _FakePlacementRepository implements PlacementRepository {
  _FakePlacementRepository({this.session});

  PlacementSession? session;
  Failure? failure;

  /// Sıradaki cevapta dönecek adım; biterse test kapanmış sayılır.
  final List<PlacementRoute> routes = <PlacementRoute>[];

  /// Doluysa cevap bekletilir: gönderim sürerken ikinci gönderim denenir.
  Completer<Either<Failure, PlacementAnswer>>? hold;

  int startCalls = 0;
  final List<String> submittedAnswerIds = <String>[];
  String? lastAttemptId;
  String? lastQuestionId;
  int? lastResponseTimeMs;

  @override
  Future<Either<Failure, PlacementSession?>> startAttempt() async {
    startCalls++;
    final Failure? error = failure;
    if (error != null) return Left<Failure, PlacementSession?>(error);
    return Right<Failure, PlacementSession?>(session);
  }

  @override
  Future<Either<Failure, PlacementAnswer>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
    int? responseTimeMs,
  }) async {
    lastAttemptId = attemptId;
    lastQuestionId = questionId;
    lastResponseTimeMs = responseTimeMs;
    submittedAnswerIds.add(answerId);

    final Failure? error = failure;
    if (error != null) return Left<Failure, PlacementAnswer>(error);

    final Either<Failure, PlacementAnswer> response = Right<
      Failure,
      PlacementAnswer
    >(
      PlacementAnswer(
        isCorrect: true,
        selectedAnswerId: answerId,
        route: routes.isEmpty ? _finished('B1') : routes.removeAt(0),
      ),
    );

    final Completer<Either<Failure, PlacementAnswer>>? pending = hold;
    if (pending != null) {
      hold = null;
      return pending.future.then<Either<Failure, PlacementAnswer>>(
        (_) => response,
      );
    }
    return response;
  }

  @override
  Future<Either<Failure, PlacementOutcome>> fetchResult(
    String attemptId,
  ) async => Right<Failure, PlacementOutcome>(
    const PlacementOutcome(
      level: 'A1',
      confidence: 'medium',
      totalQuestions: 0,
      correctAnswers: 0,
      score: 0,
    ),
  );
}

PlacementSession _session(PlacementRoute route) => PlacementSession(
  test: const PlacementTest(
    id: '1',
    code: 'default',
    title: 'Seviye Testi',
    version: 1,
  ),
  attemptId: '7',
  attemptNumber: 1,
  route: route,
);

class _FakeLevelRepository implements LevelRepository {
  _FakeLevelRepository();

  AppLevel? savedResponse;
  Failure? failure;

  /// Doluysa yazma bekletilir: sürerken ikinci onay denenmez.
  Completer<Either<Failure, AppLevel>>? hold;

  String? appliedAttemptId;
  int applyCalls = 0;

  @override
  Future<Either<Failure, AppLevel>> applyPlacementResult(String attemptId) async {
    applyCalls++;
    appliedAttemptId = attemptId;

    final Failure? error = failure;
    final Either<Failure, AppLevel> response =
        error != null
        ? Left<Failure, AppLevel>(error)
        : Right<Failure, AppLevel>(
            savedResponse ??
                const AppLevel(id: '4', code: 'B2', title: 'Upper Intermediate', orderIndex: 4),
          );

    final Completer<Either<Failure, AppLevel>>? pending = hold;
    if (pending != null) {
      hold = null;
      return pending.future.then<Either<Failure, AppLevel>>((_) => response);
    }
    return response;
  }

  @override
  Future<Either<Failure, List<AppLevel>>> fetchLevels() async =>
      Left<Failure, List<AppLevel>>(const NetworkFailure());

  @override
  Future<Either<Failure, AppLevel?>> fetchCurrentLevel() async =>
      Left<Failure, AppLevel?>(const NetworkFailure());

  @override
  Future<Either<Failure, AppLevel>> saveLevel({
    required String levelId,
    required LevelSource source,
  }) async => Left<Failure, AppLevel>(const NetworkFailure());
}

void main() {
  late _FakePlacementRepository repository;
  late LevelTestCubit cubit;

  setUp(() {
    repository = _FakePlacementRepository(session: _session(_route(_a1)));
    cubit = LevelTestCubit(repository: repository);
  });

  tearDown(() async => cubit.close());

  group('LevelTestCubit start', () {
    test('veri katmanı yoksa start sessiz kalır ve iskelet görünür', () async {
      final LevelTestCubit bare = LevelTestCubit();
      addTearDown(bare.close);

      await bare.start();

      expect(bare.state, const LevelTestLoading());
    });

    test('oturumun ilk sorusu ve kimliği hazır duruma taşınır', () async {
      await cubit.start();

      final LevelTestReady state = cubit.state as LevelTestReady;
      expect(state.attemptId, '7');
      expect(state.question, _a1);
      expect(state.answeredCount, 0);
      expect(state.selectedIndex, isNull);
    });

    test('yayınlanmış test yoksa boş durum seçilir', () async {
      repository.session = PlacementSession(
        test: null,
        attemptId: '7',
        attemptNumber: 1,
        route: _route(_a1),
      );

      await cubit.start();

      expect(cubit.state, const LevelTestEmpty());
    });

    test('null oturum da boş durumdur', () async {
      repository.session = null;

      await cubit.start();

      expect(cubit.state, const LevelTestEmpty());
    });

    test('start doğrudan sonuçla dönerse sonuç durumu kurulur', () async {
      repository.session = _session(_finished('C1'));

      await cubit.start();

      expect(cubit.state, isA<LevelTestResult>());
      expect((cubit.state as LevelTestResult).levelIndex, 4);
    });

    test('hata durumu Failure metniyle yayımlanır', () async {
      repository.failure = const NetworkFailure();

      await cubit.start();

      final LevelTestState state = cubit.state;
      expect(state, isA<LevelTestError>());
      expect((state as LevelTestError).message, isNotEmpty);
    });
  });

  group('LevelTestCubit cevap gönderimi', () {
    setUp(() async {
      repository.routes.add(_route(_b1));
      await cubit.start();
      cubit.selectOption(1);
    });

    test('cevap seçenek id si olarak sunucuya gider', () async {
      await cubit.advance();

      expect(repository.lastAttemptId, '7');
      expect(repository.lastQuestionId, _a1.id);
      expect(repository.submittedAnswerIds, <String>[_a1.options[1].id]);
    });

    test('yanıt süresi milisaniye olarak taşınır', () async {
      await cubit.advance();

      expect(repository.lastResponseTimeMs, isNotNull);
      expect(repository.lastResponseTimeMs, greaterThanOrEqualTo(0));
    });

    test('seçim yokken gönderim denenmez', () async {
      final LevelTestCubit fresh = LevelTestCubit(repository: repository);
      addTearDown(fresh.close);
      await fresh.start();

      await fresh.advance();

      expect(repository.submittedAnswerIds, isEmpty);
    });

    test('sıradaki soru gelince sayaç ilerler ve seçim sıfırlanır', () async {
      await cubit.advance();

      final LevelTestReady state = cubit.state as LevelTestReady;
      expect(state.question, _b1);
      expect(state.answeredCount, 1);
      expect(state.selectedIndex, isNull);
      expect(state.isSubmitting, isFalse);
    });

    test('aşama değişince ilerleme paydası da değişir', () async {
      expect((cubit.state as LevelTestReady).totalCap, 12);

      await cubit.advance();

      expect((cubit.state as LevelTestReady).totalCap, 18);
    });

    test('test biterse sunucunun bandı indeks olarak yayımlanır', () async {
      repository.routes.add(_finished('B2'));

      await cubit.advance();
      cubit.selectOption(0);
      await cubit.advance();

      final LevelTestResult state = cubit.state as LevelTestResult;
      expect(state.levelIndex, 3);
      expect(state.outcome?.confidence, 'high');
    });

    test('tanınmayan bant en düşük seviyeye düşer', () async {
      repository.routes.add(_finished('X9'));

      await cubit.advance();
      cubit.selectOption(0);
      await cubit.advance();

      expect((cubit.state as LevelTestResult).levelIndex, 0);
    });

    test('gönderim sürerken ikinci gönderim yapılmaz', () async {
      final Completer<Either<Failure, PlacementAnswer>> gate =
          Completer<Either<Failure, PlacementAnswer>>();
      repository.hold = gate;
      final Future<void> first = cubit.advance();
      await Future<void>.delayed(Duration.zero);

      expect((cubit.state as LevelTestReady).isSubmitting, isTrue);
      await cubit.advance();
      expect(repository.submittedAnswerIds, hasLength(1));

      gate.complete(
        Right<Failure, PlacementAnswer>(
          PlacementAnswer(
            isCorrect: true,
            selectedAnswerId: _a1.options[1].id,
            route: _route(_b1),
          ),
        ),
      );
      await first;

      expect(cubit.state, isA<LevelTestReady>());
    });

    test('cevap reddedilirse hata durumu görünür', () async {
      repository.failure = const ConflictFailure(code: '23505');

      await cubit.advance();

      expect(cubit.state, isA<LevelTestError>());
    });
  });

  group('LevelTestCubit onay yazımı', () {
    test('seviye deposu yoksa onay hiçbir yere yazmadan true döner', () async {
      final LevelTestCubit bare = LevelTestCubit(
        initialState: const LevelTestResult(levelIndex: 1, attemptId: '9'),
      );
      addTearDown(bare.close);

      expect(await bare.confirmResult(), isTrue);
    });

    test('onay yalnız oturum id’sini apply_placement_result’a taşır', () async {
      final _FakeLevelRepository levels = _FakeLevelRepository();
      final LevelTestCubit controller = LevelTestCubit(
        repository: repository,
        levelRepository: levels,
        initialState: const LevelTestResult(levelIndex: 3, attemptId: '15'),
      );
      addTearDown(controller.close);

      expect(await controller.confirmResult(), isTrue);

      expect(levels.appliedAttemptId, '15');
      final LevelTestResult state = controller.state as LevelTestResult;
      expect(state.isSaving, isFalse);
      expect(state.saveMessage, isNull);
    });

    test('yazma reddedilirse false döner ve hata sonuçta kalır', () async {
      final _FakeLevelRepository levels = _FakeLevelRepository()
        ..failure = const PermissionFailure(code: '42501');
      final LevelTestCubit controller = LevelTestCubit(
        repository: repository,
        levelRepository: levels,
        initialState: const LevelTestResult(levelIndex: 3, attemptId: '15'),
      );
      addTearDown(controller.close);

      expect(await controller.confirmResult(), isFalse);

      final LevelTestResult state = controller.state as LevelTestResult;
      expect(state, isA<LevelTestResult>());
      expect(state.saveMessage, isNotEmpty);
      expect(state.isSaving, isFalse);
      expect(state.levelIndex, 3);
    });

    test('yazma sürerken ikinci onay gitmez', () async {
      final _FakeLevelRepository levels = _FakeLevelRepository();
      final Completer<Either<Failure, AppLevel>> gate =
          Completer<Either<Failure, AppLevel>>();
      levels.hold = gate;
      final LevelTestCubit controller = LevelTestCubit(
        repository: repository,
        levelRepository: levels,
        initialState: const LevelTestResult(levelIndex: 3, attemptId: '15'),
      );
      addTearDown(controller.close);

      final Future<bool> first = controller.confirmResult();
      await Future<void>.delayed(Duration.zero);

      expect(
        (controller.state as LevelTestResult).isSaving,
        isTrue,
      );
      await controller.confirmResult();
      expect(levels.applyCalls, 1);

      gate.complete(
        Right<Failure, AppLevel>(
          const AppLevel(id: '4', code: 'B2', title: 'Upper Intermediate', orderIndex: 4),
        ),
      );
      expect(await first, isTrue);
    });
  });
}
