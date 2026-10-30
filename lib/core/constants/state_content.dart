/// Yükleme, hata ve boş durumların tüm metinleri ve görselleri.
///
/// Hata görseli her ekranda aynıdır ([errorImageAsset]); boş durum görseli
/// bağlama göre değişir.
abstract final class StateContent {
  // --- Hata ---
  static const String errorImageAsset =
      'assets/images/Feeling sorry-rafiki.png';
  static const String errorTitle = 'İçerik yüklenemedi';
  static const String errorMessage =
      'Bağlantıda bir sorun var gibi görünüyor. İnternetini kontrol edip '
      'tekrar deneyebilirsin.';
  static const String retryLabel = 'TEKRAR DENE';

  // --- Boş: kelime listesi ---
  static const String wordsEmptyImageAsset =
      'assets/images/Dictionary-rafiki.png';
  static const String wordsEmptyTitle = 'Henüz kelimen yok';
  static const String wordsEmptyMessage =
      'Keşfet sayfasından ilk kelimelerini seç, buradan ezberlemeye başla.';
  static const String wordsEmptyCtaLabel = 'KELİME EKLE';

  // --- Boş: arama / filtre sonucu ---
  static const String searchEmptyImageAsset = 'assets/images/Empty-rafiki.png';
  static const String searchEmptyTitle = 'Sonuç bulunamadı';
  static const String searchEmptyMessage =
      'Farklı bir arama dene ya da filtreleri temizleyip tüm listeyi gör.';
  static const String clearFiltersLabel = 'FİLTRELERİ TEMİZLE';

  // --- Boş: hikâye listesi ---
  static const String storiesEmptyImageAsset =
      'assets/images/Bibliophile-rafiki.png';
  static const String storiesEmptyTitle = 'Henüz hikâye yok';
  static const String storiesEmptyMessage =
      'Yeni hikâyeler eklendiğinde burada görünecek.';

  // --- Boş: ders listesi ---
  static const String lessonsEmptyImageAsset =
      'assets/images/English teacher-rafiki.png';
  static const String lessonsEmptyTitle = 'Henüz ders yok';
  static const String lessonsEmptyMessage =
      'Yeni dersler eklendiğinde burada görünecek.';

  // --- Boş: pratik listesi ---
  static const String practiceEmptyImageAsset =
      'assets/images/Work time-rafiki.png';
  static const String practiceEmptyTitle = 'Henüz pratik yok';
  static const String practiceEmptyMessage =
      'Yeni pratikler eklendiğinde burada görünecek.';

  // --- Boş: profil ---
  static const String profileEmptyImageAsset =
      'assets/images/Choose-rafiki.png';
  static const String profileEmptyTitle = 'Profil bulunamadı';
  static const String profileEmptyMessage =
      'Hesap bilgilerine ulaşılamadı. Tekrar giriş yapmayı dene.';

  // --- Boş: seviye testi ---
  static const String levelTestEmptyImageAsset =
      'assets/images/Online test-rafiki.png';
  static const String levelTestEmptyTitle = 'Test hazır değil';
  static const String levelTestEmptyMessage =
      'Sorular yüklendiğinde buradan seviyeni belirleyebilirsin.';

  // --- Yükleme ---
  static const String loadingLabel = 'İçerik yükleniyor';
}
