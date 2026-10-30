/// Kelimeler modülünün ekran metinleri.
abstract final class WordsContent {
  // --- İstatistik kartı ---
  static const String learningLabel = 'EZBERLEMEDE';
  static const String memorizedLabel = 'EZBERLENMİŞ';

  // --- Hızlı çeviri kartı ---
  static const String translateSectionLabel = 'HIZLI ÇEVİRİ';
  static const String swapLanguagesTooltip = 'Dillerin yerini değiştir';
  static const String translateInputHint = 'Kelime veya metin gir';
  static const String translateCtaLabel = 'ÇEVİR';
  static const String notFoundMessage = 'Çeviri bulunamadı.';
  static const String addToMemorizeLabel = 'EZBERLEMEYE EKLE';

  // --- Ana eylemler ---
  static const String startCtaLabel = 'EZBERLEMEYE BAŞLA';
  static const String discoverCardTitle = 'Yeni kelime ekle';
  static const String discoverCtaLabel = 'EKLE';

  // --- Önerilen kelimeler ---
  static const String suggestedSectionLabel = 'ÖNERİLEN KELİMELER';
  static const String addSuggestedTooltip = 'Ezberlemeye ekle';

  // --- Kelime keşfet sayfası ---
  static const String discoverScreenTitle = 'Kelime Keşfet';
  static const String discoverSearchHint = 'Kelime ara';
  static const String discoverFilterTooltip = 'Kategori filtresi';
  static const String applyFiltersLabel = 'FİLTREYİ UYGULA';
  static const String filterSectionLabel = 'KATEGORİLER';
  static const String selectedCountTemplate = '{count} kelime seçildi';
  static const String addSelectedCtaLabel = 'SEÇİLENLERİ EKLE';
  static const String discoverEmptyTitle = 'Havuz boş';
  static const String discoverEmptyMessage =
      'Yeni kelimeler eklendiğinde burada listelenecek.';

  // --- Ezberleme ekranı ---
  static const String memorizeScreenTitle = 'Ezberleme';
  static const String memorizeEmptyMessage = 'Çalışacak kelime yok.';
  static const String cardFlipHint = 'Çevirmek için karta dokun';
  static const String memorizeProgressTemplate = '{done} / {total}';
  static const String memorizeFinishCtaLabel = 'EZBERLEMEYİ BİTİR';
  static const String memorizeSummaryTemplate =
      '{known} kelimeyi bildin, {unknown} kelime kaldı.';

  // --- Ezberleme sonuç sayfası ---
  static const String memorizeResultTitle = 'Oturum Sonucu';
  static const String totalLabel = 'TOPLAM';
  static const String knownLabel = 'BİLİNEN';
  static const String unknownLabel = 'BİLİNMEYEN';
  static const String resultSummaryTemplate =
      '{total} kelime çalıştın, {known} tanesini ezberledin.';
  static const String knownSectionLabel = 'BİLİNEN KELİMELER';
  static const String unknownSectionLabel = 'BİLİNMEYEN KELİMELER';
  static const String homeCtaLabel = 'ANA SAYFAYA';
  static const String continueCtaLabel = 'DEVAM ET';
}
