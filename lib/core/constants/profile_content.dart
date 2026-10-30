import '../models/profile_models.dart';

/// Profil ekranı ve alt akışlarının metinleri — tek noktadan yönetilir.
///
/// Etiketler BÜYÜK HARF saklanır: Dart'ın toUpperCase()'i 'i'yi noktasız
/// 'I'a çevirdiği için Türkçe etiketler kaynağında büyük yazılır.
abstract final class ProfileContent {
  // --- Ekran başlığı ---
  static const String screenSubtitle =
      'Hesabını, öğrenme durumunu ve tercihlerini buradan yönet.';

  // --- Kimlik kartı ---
  static const String editCtaLabel = 'DÜZENLE';

  // --- Öğrenme istatistikleri ---
  static const String statsSectionLabel = 'ÖĞRENME İSTATİSTİKLERİ';
  static const String completedLessonsLabel = 'TAMAMLANAN DERS';
  static const String wordsLabel = 'KELİME';
  static const String wordsDetailTemplate =
      '{learning} çalışılıyor · {memorized} ezberlendi';
  static const String readStoriesLabel = 'OKUNAN HİKÂYE';
  static const String completedPracticesLabel = 'TAMAMLANAN PRATİK';
  static const String overallProgressLabel = 'GENEL ÖĞRENME İLERLEMESİ';
  static const String percentTemplate = '{percent}%';

  // --- Seviye bilgisi ---
  static const String levelSectionLabel = 'SEVİYE BİLGİSİ';
  static const String currentLevelLabel = 'Mevcut seviyen';
  static const String retakeTestCtaLabel = 'TESTE TEKRAR GİR';
  static const String levelUpdatedTemplate =
      'Seviyen {level} olarak güncellendi.';

  // --- Öğrenme hedefleri ---
  static const String goalSectionLabel = 'GÜNLÜK HEDEF';
  static const String goalUnit = 'etkinlik';
  static const String goalProgressTemplate =
      '{done} / {total} {unit} tamamlandı';
  static const String goalHint =
      'Her gün tamamlamak istediğin etkinlik sayısını seç.';
  static const String goalChangeCtaLabel = 'HEDEFİ DEĞİŞTİR';

  static const Map<DailyGoal, String> goalLabels = <DailyGoal, String>{
    DailyGoal.light: 'Rahat',
    DailyGoal.normal: 'Önerilen',
    DailyGoal.strong: 'Ciddi',
    DailyGoal.expert: 'Usta',
  };

  // --- Uygulama ayarları ---
  static const String settingsSectionLabel = 'UYGULAMA AYARLARI';
  static const String languageRowLabel = 'Uygulama dili';
  static const String notificationsRowLabel = 'Bildirim tercihleri';
  static const String audioRowLabel = 'Sesli okuma ve ses';
  static const String readingRowLabel = 'Okuma tercihleri';

  static const Map<AppLanguage, String> languageLabels = <AppLanguage, String>{
    AppLanguage.turkish: 'Türkçe',
    AppLanguage.english: 'English',
  };

  // --- Ayar sheet'leri ---
  static const String languageSheetTitle = 'Uygulama dili';
  static const String notificationsSheetTitle = 'Bildirim tercihleri';
  static const String audioSheetTitle = 'Sesli okuma ve ses';
  static const String readingSheetTitle = 'Okuma tercihleri';
  static const String sheetDoneCtaLabel = 'TAMAM';

  static const String practiceReminderLabel = 'Günlük çalışma hatırlatması';
  static const String practiceReminderDescription =
      'Seriyi korumak için her gün aynı saatte hatırlat.';
  static const String streakGuardLabel = 'Seri koruyucu uyarısı';
  static const String streakGuardDescription =
      'Seri tehlikeye girdiğinde hemen bildir.';
  static const String newContentLabel = 'Yeni içerik duyuruları';
  static const String newContentDescription =
      'Yeni ders, hikâye ve kelime eklendiğinde haber ver.';

  static const String readAloudLabel = 'Sesli okuma';
  static const String readAloudDescription =
      'Kelimeleri ve hikâyeleri otomatik seslendir.';
  static const String soundEffectsLabel = 'Ses efektleri';
  static const String soundEffectsDescription =
      'Doğru ve yanlış cevaplarda kısa sesler çal.';
  static const String audioSpeedLabel = 'Okuma hızı';

  static const String textSizeLabel = 'Yazı boyutu';
  static const String showTranslationLabel = 'Çeviriyi göster';
  static const String showTranslationDescription =
      'Hikâyede İngilizce metnin altında Türkçe çeviri gelsin.';
  static const String tapToTranslateLabel = 'Dokunarak çevir';
  static const String tapToTranslateDescription =
      'Hikâyedeki bir kelimeye dokununca karşılığını göster.';

  static const Map<ReadingTextSize, String> textSizeLabels =
      <ReadingTextSize, String>{
        ReadingTextSize.small: 'Küçük',
        ReadingTextSize.medium: 'Orta',
        ReadingTextSize.large: 'Büyük',
      };

  /// Sesli okuma hız seçenekleri — hikâye okuma hızlarıyla aynı ölçek.
  static const List<double> audioSpeeds = <double>[0.75, 1, 1.25, 1.5];
  static const String speedTemplate = '{speed}x';

  // --- Hesap işlemleri ---
  static const String accountSectionLabel = 'HESAP İŞLEMLERİ';
  static const String changePasswordRowLabel = 'Şifre değiştir';
  static const String logoutRowLabel = 'Oturumu kapat';
  static const String deleteAccountRowLabel = 'Hesabı sil';

  static const String logoutDialogTitle = 'Oturumu kapatıyor musun?';
  static const String logoutDialogDescription =
      'Tekrar giriş yapana kadar ilerlemen bu cihazda bekler.';
  static const String logoutConfirmLabel = 'ÇIKIŞ';
  static const String cancelLabel = 'VAZGEÇ';

  static const String deleteDialogTitle = 'Hesabını silmek istiyor musun?';
  static const String deleteDialogDescription =
      'Tüm profilin, kelimelerin ve ilerlemen kalıcı olarak silinir. '
      'Bu işlem geri alınamaz.';
  static const String deleteConfirmLabel = 'HESABI SİL';

  // --- Profil düzenleme sheet'i ---
  static const String editSheetTitle = 'Profil bilgileri';
  static const String nameFieldLabel = 'Ad';
  static const String emailFieldLabel = 'E-posta';
  static const String saveCtaLabel = 'KAYDET';
  static const String savedMessage = 'Profil bilgilerin güncellendi.';
  static const String avatarChangeCtaLabel = 'PROFİL FOTOĞRAFI';
  static const String avatarChangeStubMessage =
      'Fotoğraf seçme akışı henüz bağlı değil.';

  // --- Ortak ---
  static const String offLabel = 'Kapalı';
  static const String backendStubMessage = 'Bu akış henüz bağlı değil.';
}
