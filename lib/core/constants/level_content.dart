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
}
