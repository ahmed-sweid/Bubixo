part of 'level_cubit.dart';

sealed class LevelState extends Equatable {
  const LevelState();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Seçim ekranının kullanılabilir durumu. `levels` hiç boş değildir: veri
/// katmanı yokken ya da katalog henüz çözülmemişken yerleşik CEFR
/// basamakları çizilir.
final class LevelReady extends LevelState {
  const LevelReady({
    required this.levels,
    this.currentLevelId,
    this.selectedLevelId,
    this.isSaving = false,
    this.saveMessage,
  });

  final List<AppLevel> levels;

  /// `profiles.current_level_id` — kullanıcının sunucuda kayıtlı bandı.
  /// `null` = henüz seçim yapmadı; onay adımı bu yüzden zorunlu.
  final String? currentLevelId;

  /// Ekranda işaretli bant; henüz yazılmamış olabilir.
  final String? selectedLevelId;

  /// `set_user_level` sunucudayken ikinci gönderimi ve test akışını engeller.
  final bool isSaving;

  /// Son yazma denemesinin gösterilebilir hatası. Yeni bir seçim yapıldığında
  /// temizlenir, çünkü kullanıcı hatayı gidermiş olur.
  final String? saveMessage;

  AppLevel? get selectedLevel {
    for (final AppLevel level in levels) {
      if (level.id == selectedLevelId) {
        return level;
      }
    }
    return null;
  }

  /// Sunucuda kayıtlı bant; onay sayfasında gösterilmek üzere kullanılır.
  AppLevel? get currentLevel {
    for (final AppLevel level in levels) {
      if (level.id == currentLevelId) {
        return level;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    levels,
    currentLevelId,
    selectedLevelId,
    isSaving,
    saveMessage,
  ];
}

/// Katalog okunamadı ya da sunucuda yayınlanmış seviye yok. Seviyesiz devam
/// edilemediği için tam ekran hata ve tekrar deneme gösterilir.
final class LevelError extends LevelState {
  const LevelError({this.message});

  final String? message;

  @override
  List<Object?> get props => <Object?>[message];
}
