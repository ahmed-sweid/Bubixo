import 'package:flutter/foundation.dart';

/// Seviye belirleme testi veri modelleri.
///
/// Cevap anahtarı bu modellerde **bilinçli olarak yok**: anahtar
/// `private.placement_question_keys` tablosunda durur ve RLS/ACL ile istemciye
/// kapalıdır. Doğruluk, sıradaki soru ve seviye tahmini sunucuda hesaplanır;
/// buraya yalnız gösterilebilir alanlar gelir.
@immutable
class PlacementOption {
  const PlacementOption({required this.id, required this.text});

  /// Cevap olarak sunucuya geri gönderilen etiket (`a`, `b`, …).
  final String id;
  final String text;
}

@immutable
class PlacementQuestion {
  const PlacementQuestion({
    required this.id,
    required this.code,
    required this.stage,
    required this.cefrLevel,
    required this.prompt,
    required this.options,
  });

  final String id;

  /// İnsan okunur soru kodu (`A2_S1_01`) — loglama ve testler için.
  final String code;

  /// 1 tarama, 2 doğrulama, 3 sınır doğrulaması.
  final int stage;

  /// Sorunun ölçtüğü CEFR bandı; sunucu sıradaki soruyu buna göre seçer.
  final String cefrLevel;

  final String prompt;
  final List<PlacementOption> options;
}

@immutable
class PlacementTest {
  const PlacementTest({
    required this.id,
    required this.code,
    required this.title,
    required this.version,
    this.description,
  });

  final String id;
  final String code;
  final String title;
  final int version;
  final String? description;
}

/// Test bittiğinde sunucunun ürettiği özet.
@immutable
class PlacementOutcome {
  const PlacementOutcome({
    required this.level,
    required this.confidence,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    this.attemptId,
    this.attemptNumber,
  });

  /// Tahmin edilen CEFR bandı (`A1`…`C2`), `null` ise henüz hesaplanmamış.
  final String? level;

  /// `low | medium | high` — eşik iki komşu bandı ayırt edemediyse `low`.
  final String? confidence;

  final int totalQuestions;
  final int correctAnswers;

  /// 0–100 arası ham puan; kalibrasyon pilot verisiyle değişebilir.
  final num? score;

  final String? attemptId;
  final int? attemptNumber;
}

/// Adaptif akışın bir sonraki adımı: ya yeni soru ya da kapanış.
@immutable
class PlacementRoute {
  const PlacementRoute({
    required this.finished,
    required this.stage,
    required this.outcome,
    this.question,
  });

  final bool finished;

  /// Oturumun içinde bulunduğu aşama.
  final int stage;

  /// `finished` false iken dolu.
  final PlacementQuestion? question;

  /// `finished` true iken dolu: seviye tahmini ve özet.
  final PlacementOutcome? outcome;
}

/// `placement_start_attempt` yanıtı.
@immutable
class PlacementSession {
  const PlacementSession({
    required this.test,
    required this.attemptId,
    required this.attemptNumber,
    required this.route,
  });

  /// Yayınlanmış test yoksa null döner; `null` boş durum anlamına gelir.
  final PlacementTest? test;
  final String attemptId;
  final int attemptNumber;
  final PlacementRoute route;

  bool get isEmpty => test == null;
}

/// `placement_submit_answer` yanıtı.
@immutable
class PlacementAnswer {
  const PlacementAnswer({
    required this.isCorrect,
    required this.selectedAnswerId,
    required this.route,
    this.pointsAwarded,
    this.explanation,
  });

  /// Rubrik gerektiren sorularda null kalır: sunucu tahmin etmez.
  final bool? isCorrect;
  final num? pointsAwarded;

  /// Kullanıcının kendi seçtiği seçeneğin id'si — geri bildirim çizimi için.
  final String? selectedAnswerId;

  /// Sorunun `explanation` alanı; doğru cevabı içermez.
  final String? explanation;

  final PlacementRoute route;
}
