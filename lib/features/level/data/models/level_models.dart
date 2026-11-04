import 'package:equatable/equatable.dart';

/// Seviye kataloğu ve kullanıcının seviye imzası modelleri.
///
/// Liste sunucudaki `public.levels` tablosundan gelir; imza
/// `public.profiles.current_level_id` satırında durur. `title` sunucuda
/// İngilizce'dir ("Beginner") — ekranda görünen Türkçe açıklama
/// `LevelContent` üzerinden **koda göre** alınır, çünkü arayüz metni sabit
/// katmanda durmak zorundadır.
///
/// Değer eşitliği taşınır: cubit her sunucu okumasında yeni satırlar kurar ve
/// durum karşılaştırması (Equatable listeleri derinden karşılaştırır) içeriği
/// aynı kalan bir yeniden çizimi ayıklayabilmelidir.
class AppLevel extends Equatable {
  const AppLevel({
    required this.id,
    required this.code,
    required this.title,
    required this.orderIndex,
  });

  /// `levels.id` — bigint identity, istemcide string olarak taşınır.
  final String id;

  /// CEFR bandı (`A1`…`C2`).
  final String code;

  /// Sunucudaki İngilizce ad; etiket çizimi için değil, teşhis için.
  final String title;

  /// `levels.order_index` — 1'den başlar, katalog bu değere göre sıralıdır.
  final int orderIndex;

  @override
  List<Object?> get props => <Object?>[id, code, title, orderIndex];
}

/// Seviye imzasının nasıl oluştuğu; sunucu bu iki değeri kabul eder.
enum LevelSource {
  manual('manual'),
  placement('placement');

  const LevelSource(this.wireValue);

  /// `profiles.current_level_source` kolonuna yazılan metin.
  final String wireValue;
}
