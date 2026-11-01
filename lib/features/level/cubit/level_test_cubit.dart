import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/level_test_content.dart';
import '../../../core/services/sound_service.dart';
import '../data/models/placement_models.dart';
import '../data/repositories/placement_repository.dart';

part 'level_test_state.dart';

/// Seviye belirleme testinin oturum yönetimi.
///
/// Test **sunucu güdümlü**: soru listesi istemcide tutulmaz, her cevap
/// `placement_submit_answer` RPC'sine gönderilir ve sıradaki soru ile seviye
/// tahmini oradan gelir. Cevap anahtarı istemciye inmez, bu yüzden doğruluk
/// kontrolü de burada yapılmaz — sunucunun `is_correct` bildirimi yalnızca
/// sesli geri bildirim için kullanılır.
///
/// [repository] üretimde DI'dan gelir. Widget testleri ekranı veri katmanı
/// olmadan render ettiği için null olabilir; o durumda [start] sessiz kalır
/// ve ekranda yükleme iskeleti görünür.
class LevelTestCubit extends Cubit<LevelTestState> {
  LevelTestCubit({
    this.repository,
    LevelTestState initialState = const LevelTestLoading(),
  }) : super(initialState);

  final PlacementRepository? repository;

  /// Sorunun ekranda görünmesinden cevabın gönderilmesine geçen süre;
  /// `p_response_time_ms` olarak sunucuya yazılır.
  final Stopwatch _responseTimer = Stopwatch();

  /// Bu oturumda gönderilen cevap sayısı — ilerleme göstergesinin payı.
  int _answeredCount = 0;

  /// Oturumu açar veya yarıda kalmış oturumu devam ettirir.
  Future<void> start() async {
    final PlacementRepository? source = repository;
    if (source == null) return;

    emit(const LevelTestLoading());
    final result = await source.startAttempt();
    if (isClosed) return;

    result.fold(
      ifLeft: (failure) => emit(LevelTestError(message: failure.errorMessage)),
      ifRight: (session) {
        if (session == null || session.isEmpty) {
          emit(const LevelTestEmpty());
          return;
        }
        _answeredCount = 0;
        _follow(session.attemptId, session.route);
      },
    );
  }

  void selectOption(int optionIndex) {
    final LevelTestState current = state;
    if (current is! LevelTestReady || current.isSubmitting) return;

    SoundService.instance.play(SoundEvent.optionSelect);
    emit(current.copyWith(selectedIndex: optionIndex));
  }

  /// Seçilen cevabı sunucuya gönderir ve adaptif adımın kararını uygular:
  /// sıradaki soru ya da sonuç.
  Future<void> advance() async {
    final LevelTestState current = state;
    if (current is! LevelTestReady) return;
    if (current.selectedIndex == null || current.isSubmitting) return;

    final PlacementRepository? source = repository;
    if (source == null) return;

    emit(current.copyWith(isSubmitting: true));
    final int responseTimeMs = _responseTimer.elapsedMilliseconds;

    final result = await source.submitAnswer(
      attemptId: current.attemptId,
      questionId: current.question.id,
      answerId: current.question.options[current.selectedIndex!].id,
      responseTimeMs: responseTimeMs,
    );
    if (isClosed) return;

    result.fold(
      ifLeft: (failure) => emit(LevelTestError(message: failure.errorMessage)),
      ifRight: (answer) {
        _answeredCount = current.answeredCount + 1;
        _playFeedback(answer.isCorrect);
        _follow(current.attemptId, answer.route);
      },
    );
  }

  /// Sunucu rotasını duruma çevirir: soru varsa devam, bittiyse sonuç.
  void _follow(String attemptId, PlacementRoute route) {
    final PlacementQuestion? question = route.question;
    if (route.finished || question == null) {
      SoundService.instance.play(SoundEvent.sessionComplete);
      emit(
        LevelTestResult(levelIndex: _levelIndex(route.outcome), outcome: route.outcome),
      );
      return;
    }

    SoundService.instance.play(SoundEvent.transition);
    _responseTimer
      ..reset()
      ..start();
    emit(
      LevelTestReady(
        attemptId: attemptId,
        question: question,
        answeredCount: _answeredCount,
      ),
    );
  }

  /// Doğru/yanlış sesi; yazma-konuşma sorularında sunucu `null` döner ve
  /// geri bildirim çalınmaz.
  void _playFeedback(bool? isCorrect) {
    if (isCorrect == null) return;
    SoundService.instance.play(
      isCorrect ? SoundEvent.correct : SoundEvent.wrong,
    );
  }

  /// Sunucu bandını ([A1]…[C2]) arayüz indeksine çevirir; tanınmayan bandın
  /// anlamı olmadığı için en düşük seviye gösterilir.
  int _levelIndex(PlacementOutcome? outcome) {
    final int index = LevelContent.cefrLevels.indexOf(outcome?.level ?? '');
    return index < 0 ? 0 : index;
  }
}
