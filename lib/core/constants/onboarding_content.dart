/// Onboarding içerik verisi — metinler, görsel yolları ve CTA etiketleri
/// tek noktadan yönetilir; sayfa katmanı yalnızca tüketir.
class OnboardingPageData {
  const OnboardingPageData({
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.ctaLabel,
  });

  final String imageAsset;
  final String title;
  final String description;

  /// Etiket BÜYÜK HARF saklanır: Dart'ın toUpperCase()'i 'i'yi noktasız
  /// 'I'a çevirdiği için Türkçe etiketler kaynağında büyük yazılır.
  final String ctaLabel;
}

abstract final class OnboardingContent {
  static const List<OnboardingPageData> pages = [
    OnboardingPageData(
      imageAsset: 'assets/images/Choose-rafiki.png',
      title: 'İngilizce öğrenmeye kendi seviyenden başla.',
      description:
          "A1'den C2'ye kadar seviyeni belirle, sana uygun derslerle adım "
          "adım ilerle. Kendi hızında öğren, gelişimini takip et.",
      ctaLabel: 'DEVAM ET',
    ),
    OnboardingPageData(
      imageAsset: 'assets/images/Vowels-rafiki.png',
      title: 'Yeni kelimeler öğren, unutmayı geride bırak.',
      description:
          'Kelimeleri keşfet, kişisel kelime listeni oluştur ve akıllı '
          'tekrarlarla öğrendiklerini pekiştir. Böylece kelimeler zamanla '
          'hafızanda yer etsin.',
      ctaLabel: 'DEVAM ET',
    ),
    OnboardingPageData(
      imageAsset: 'assets/images/Translator-rafiki.png',
      title: 'İngilizceni gerçek hayatta kullanmaya hazırla.',
      description:
          'Hikâyeler oku, interaktif testleri çöz ve farklı pratiklerle '
          'öğrendiklerini uygula. Her gün küçük adımlarla daha ileriye git.',
      ctaLabel: 'HADİ BAŞLAYALIM',
    ),
  ];
}
