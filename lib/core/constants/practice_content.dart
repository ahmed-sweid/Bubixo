import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../models/practice_models.dart';
import 'app_colors.dart';

/// Pratik modülünün ekran metinleri ve tür görselleri.
abstract final class PracticeContent {
  // --- Ana sayfa ----------------------------------------------------------
  static const String progressTemplate = '{done} / {total} tamamlandı';
  static const String emptyMessage = 'Bu pratikte içerik yok.';

  static const Map<PracticeType, String> typeTitles = <PracticeType, String>{
    PracticeType.sentenceOrder: 'Cümle Sıralama',
    PracticeType.fillBlank: 'Boşluk Doldurma',
    PracticeType.speaking: 'Konuşma',
    PracticeType.listening: 'Dinleme',
    PracticeType.matching: 'Eşleştirme',
  };

  static const Map<PracticeType, String> typeDescriptions =
      <PracticeType, String>{
        PracticeType.sentenceOrder: 'Karışık kelimeleri doğru sıraya diz.',
        PracticeType.fillBlank: 'Cümledeki boşluğu doğru kelimeyle tamamla.',
        PracticeType.speaking: 'Telaffuzunu mikrofonla dene.',
        PracticeType.listening: 'Dinle, anla ve doğru cevabı seç.',
        PracticeType.matching: 'İngilizce kelimeleri anlamlarıyla eşleştir.',
      };

  static const Map<PracticeType, IconData> typeIcons = <PracticeType, IconData>{
    PracticeType.sentenceOrder: Iconsax.note_2,
    PracticeType.fillBlank: Iconsax.edit_2,
    PracticeType.speaking: Iconsax.microphone_2,
    PracticeType.listening: Iconsax.headphone,
    PracticeType.matching: Iconsax.element_3,
  };

  static const Map<PracticeType, Color> typeColors = <PracticeType, Color>{
    PracticeType.sentenceOrder: AppColors.accentMacaw,
    PracticeType.fillBlank: AppColors.accentBee,
    PracticeType.speaking: AppColors.accentBeetle,
    PracticeType.listening: AppColors.accentFox,
    PracticeType.matching: AppColors.primary,
  };

  // --- Detay sayfası ------------------------------------------------------
  static const String percentTemplate = '%{percent}';
  static const String itemCountTemplate = '{done}/{total} içerik';

  // --- Oturum -------------------------------------------------------------
  static const String questionProgressTemplate = '{index} / {total}';
  static const String checkCtaLabel = 'KONTROL ET';
  static const String nextCtaLabel = 'SONRAKİ';
  static const String finishCtaLabel = 'BİTİR';
  static const String correctFeedback = 'Doğru! Harika gidiyorsun.';
  static const String wrongFeedbackTemplate = 'Yanlış. Doğru cevap: {answer}';

  static const String sentenceOrderInstruction = 'Kelimeleri doğru sıraya diz.';
  static const String sentenceOrderHintTemplate = 'Türkçesi: {hint}';
  static const String sentencePoolHint = 'Kelimeye dokunarak cümleye ekle.';
  static const String sentenceEmptyHint = 'Cümleni buraya kur.';

  static const String fillBlankInstruction = 'Boşluğu doğru seçenekle tamamla.';

  static const String listeningInstruction = 'Sesi dinle ve doğru cevabı seç.';
  static const String listeningPrompt = 'Duyduğun cümleyi seç.';
  static const String listeningPlayLabel = 'DİNLE';
  static const String listeningReplayLabel = 'TEKRAR DİNLE';
  static const String listeningPlayingLabel = 'DİNLENİYOR...';

  static const String speakingInstruction = 'Aşağıdaki ifadeyi sesli söyle.';
  static const String speakingTaskLabel = 'GÖREV';
  static const String speakingPhraseLabel = 'SÖYLE';
  static const String recordStartLabel = 'KAYDI BAŞLAT';
  static const String recordStopLabel = 'KAYDI DURDUR';
  static const String recordingLabel = 'Kayıt sürüyor...';
  static const String recordedLabel = 'Kayıt alındı.';
  static const String recordedMessage =
      'Kaydın tamamlandı. Tekrar deneyebilir veya sonraki ifadeye geçebilirsin.';
  static const String retryLabel = 'TEKRAR DENE';

  static const String matchingInstruction = 'Kelimeleri anlamlarıyla eşleştir.';
  static const String matchingProgressTemplate = '{matched} / {total} eşleşti';
  static const String matchingMismatch = 'Eşleşmedi, tekrar dene.';
  static const String matchingComplete = 'Tüm eşleşmeler tamam!';

  // --- Sonuç --------------------------------------------------------------
  static const String resultTitle = 'Pratik Sonucu';
  static const String totalLabel = 'TOPLAM';
  static const String correctLabel = 'DOĞRU';
  static const String wrongLabel = 'YANLIŞ';
  static const String completedLabel = 'TAMAMLANAN';
  static const String resultSummaryTemplate =
      '{correct} doğru, {wrong} yanlış cevap verdin.';
  static const String perfectResultMessage = 'Hepsini doğru yaptın, harika!';
  static const String speakingResultSummaryTemplate =
      '{completed} ifadeyi sesli tamamladın.';
  static const String retryCtaLabel = 'PRATİĞİ TEKRAR ET';
  static const String homeCtaLabel = 'ANA SAYFAYA';
}
