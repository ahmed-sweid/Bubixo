/// Seviye belirleme testi metinleri — metinler tek noktadan yönetilir;
/// sayfa katmanı yalnızca tüketir.
abstract final class LevelTestContent {
  static const String appBarTitle = 'Seviye Testi';

  /// {index} ve {total} yer tutucuları soru ilerledikçe değiştirilir.
  static const String questionProgressTemplate = 'SORU {index}/{total}';
  static const String ctaLabel = 'DEVAM ET';

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
