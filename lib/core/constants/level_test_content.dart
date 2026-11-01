/// Seviye belirleme testi metinleri — metinler tek noktadan yönetilir;
/// sayfa katmanı yalnızca tüketir.
abstract final class LevelTestContent {
  static const String appBarTitle = 'Seviye Testi';

  /// {index} ve {total} yer tutucuları soru ilerledikçe değiştirilir.
  static const String questionProgressTemplate = 'SORU {index}/{total}';
  static const String ctaLabel = 'DEVAM ET';

  /// Sunucu sıradaki soruyu adaptif seçtiği için kullanıcının kaç soru
  /// cevaplayacağı önceden bilinmez; ilerleme çubuğu aşama başına üst
  /// sınırdan çizilir. Yayınlanmış testin soru sayılarıyla kalibre edilir:
  /// aşama 1 her bandan 2 tarama (12), aşama 2 iki bandan 3'er doğrulama (6),
  /// aşama 3 komşu bant sınırı için 3'er soru (6).
  static const int screeningStageQuestionCap = 12;
  static const int confirmationStageQuestionCap = 6;
  static const int boundaryStageQuestionCap = 6;

  /// Verilen aşamada testin görebileceği en fazla soru sayısı.
  static int stageQuestionCap(int stage) => switch (stage) {
    2 => screeningStageQuestionCap + confirmationStageQuestionCap,
    3 =>
      screeningStageQuestionCap +
      confirmationStageQuestionCap +
      boundaryStageQuestionCap,
    _ => screeningStageQuestionCap,
  };

  static const String resultBadgeLabel = 'SEVİYEN';
  static const String confirmLabel = 'BU SEVİYEYİ ONAYLA';
  static const String chooseManuallyLabel = 'KENDİM SEVİYE SEÇECEĞİM';

  /// Her CEFR basamağı için sonuç bilgilendirme metni —
  /// [LevelContent.cefrLevels] sırasıyla eşleşir.
  static const List<String> resultInfos = [
    'İngilizceye temellerden başlıyoruz. Günlük kalıplarla hızla ilerleyeceksin.',
    'Basit günlük konuşmaları anlıyor ve yanıt veriyorsun. Temel kalıpları pekiştirelim.',
    'Günlük konularda kendini rahat ifade ediyorsun. Şimdi daha uzun cümlelere geçelim.',
    'Karmaşık konuları anlıyor, görüşünü gerekçeleriyle anlatabiliyorsun. Çok iyi yerdesin!',
    'Dili akıcı kullanıyor, nüansları yakalıyorsun. Ustalığa bir adım kaldı.',
    'Dili yerli bir konuşur gibi kullanıyorsun. Pratikle keskinleştirmeye devam!',
  ];
}
