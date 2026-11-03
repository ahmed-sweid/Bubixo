/// Seviye belirleme ekranı içerik verisi — metinler tek noktadan yönetilir;
/// sayfa katmanı yalnızca tüketir.
abstract final class LevelContent {
  static const String title = 'Seviyeni belirle!';
  static const String subtitle =
      'Kendi seviyeni seç ya da kısa testle sana en uygununu bulalım.';

  /// Etiketler BÜYÜK HARF saklanır: Dart'ın toUpperCase()'i 'i'yi noktasız
  /// 'I'a çevirdiği için Türkçe etiketler kaynağında büyük yazılır.
  static const String chooseLabel = 'SEVİYEMİ SEÇ';
  static const String testLabel = 'SEVİYE TESTİNİ ÇÖZ';

  /// Avrupa Ortak Dil Referans Çerçevesi (CEFR) basamakları — cefrLevelDescriptions ile sıralı.
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  static const List<String> cefrLevelDescriptions = [
    'Başlangıç',
    'Temel',
    'Orta',
    'Orta üstü',
    'İleri',
    'Ustalık',
  ];

  /// Karta yazılacak Türkçe açıklama. Sunucu `levels.title`'ı İngilizce
  /// döndürdüğü için arayüz metni burada kalır ve **koda göre** çözülür;
  /// tanınmayan kod boş döner, çağıran sunucunun adını gösterir.
  static String descriptionFor(String code) {
    final int index = cefrLevels.indexOf(code);
    return index < 0 ? '' : cefrLevelDescriptions[index];
  }

  /// Seviye kaydedildikten sonraki onay sayfası. {level} yer tutucusu
  /// seçilen CEFR koduyla değiştirilir; seviye bilinmiyorsa
  /// [chosenFallbackMessage] kullanılır.
  static const String chosenImageAsset = 'assets/images/Goal-rafiki.png';
  static const String chosenTitle = 'Seviyen hazır!';
  static const String chosenMessageTemplate =
      'Artık {level} bandındasın. Dersler, kelimeler ve hikâyeler bu '
      'seviyeye göre sana eşlik edecek.';
  static const String chosenFallbackMessage =
      'Seviyen kaydedildi. Dersler, kelimeler ve hikâyeler bu seviyeye '
      'göre sana eşlik edecek.';
  static const String chosenCtaLabel = 'ANA SAYFAYA GİT';
}
