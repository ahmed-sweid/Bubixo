part of 'level_test_cubit.dart';

sealed class LevelTestState extends Equatable {
  const LevelTestState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LevelTestLoading extends LevelTestState {
  const LevelTestLoading();
}

final class LevelTestError extends LevelTestState {
  const LevelTestError({this.message});

  final String? message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Yayınlanmış seviye testi yok — içerik yüklenene kadar görünen durum.
final class LevelTestEmpty extends LevelTestState {
  const LevelTestEmpty();
}

/// Adaptif akıştaki tek soruluk adım. Sunucu sıradaki soruyu seçtiği için
/// durumda bir soru listesi taşınmaz: yalnızca gösterilen soru, kullanıcının
/// seçimi ve ilerleme sayacı vardır.
final class LevelTestReady extends LevelTestState {
  const LevelTestReady({
    required this.attemptId,
    required this.question,
    this.answeredCount = 0,
    this.selectedIndex,
    this.isSubmitting = false,
  });

  /// Cevabın işlendiği sunucu oturumu; hata sonrası tekrar denemede aynı
  /// oturum devam ettirilir.
  final String attemptId;
  final PlacementQuestion question;

  /// Bu oturumda gönderilmiş cevap sayısı — yalnızca ilerleme çizimi için.
  final int answeredCount;
  final int? selectedIndex;

  /// Cevap sunucudayken ikinci gönderimi engeller.
  final bool isSubmitting;

  /// İlerleme çubuğunun paydası: aşamanın üst sınırı, garantili soru sayısı değil.
  int get totalCap => LevelTestContent.stageQuestionCap(question.stage);

  LevelTestReady copyWith({int? selectedIndex, bool? isSubmitting}) =>
      LevelTestReady(
        attemptId: attemptId,
        question: question,
        answeredCount: answeredCount,
        selectedIndex: selectedIndex ?? this.selectedIndex,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => <Object?>[
    attemptId,
    question,
    answeredCount,
    selectedIndex,
    isSubmitting,
  ];
}

final class LevelTestResult extends LevelTestState {
  const LevelTestResult({required this.levelIndex, this.outcome});

  /// [LevelContent.cefrLevels] indeksine çevrilmiş sunucu tahmini.
  final int levelIndex;

  /// Sunucunun tam özeti (güven, soru/doğru sayısı, puan) — UI şu an yalnızca
  /// `levelIndex` kullanıyor, ileride sonuç ekranına eklenebilir.
  final PlacementOutcome? outcome;

  @override
  List<Object?> get props => <Object?>[levelIndex, outcome];
}
