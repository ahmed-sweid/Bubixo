import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/level_content.dart';
import '../data/models/level_models.dart';
import '../data/repositories/level_repository.dart';

part 'level_state.dart';

/// Seviye seçimi ekranının kataloğu, imzası ve kaydı.
///
/// Liste `public.levels`'ten gelir; kullanıcının daha önce kaydedilmiş bandı
/// `profiles.current_level_id`'nden okunur ve ilgili kart önseçilir. Onay
/// `set_user_level` RPC'sine gider — ilerleme defterine ham `update` yazılmaz,
/// çünkü imza ile alt bantların kilidini açmanın aynı işlem içinde olması
/// gerekir.
///
/// [repository] üretimde DI'dan gelir. Widget testleri ekranı veri katmanı
/// olmadan render ettiği için null olabilir; o durumda katalog yerleşik CEFR
/// basamaklarından çizilir ve [saveSelected] hiçbir yere yazmadan başarılı
/// döner — akışın tek çıkışı tanıtım yığınını kapatmaktır.
class LevelCubit extends Cubit<LevelState> {
  LevelCubit({this.repository}) : super(LevelReady(levels: _localCatalog()));

  final LevelRepository? repository;

  /// Katalog okunana kadar ekranda duran altı bant. `id` değerleri yereldir:
  /// veri katmanı olmadan [saveSelected] hiç yazmadığı için sunucuya
  /// ulaşamazlar.
  static List<AppLevel> _localCatalog() => <AppLevel>[
    for (int i = 0; i < LevelContent.cefrLevels.length; i++)
      AppLevel(
        id: '${i + 1}',
        code: LevelContent.cefrLevels[i],
        title: LevelContent.cefrLevelDescriptions[i],
        orderIndex: i + 1,
      ),
  ];

  /// Kataloğu, sonra varsa kullanıcının mevcut seviyesini okur.
  Future<void> load() async {
    final LevelRepository? source = repository;
    if (source == null) return;

    final result = await source.fetchLevels();
    if (isClosed) return;

    result.fold(
      ifLeft: (failure) => emit(LevelError(message: failure.errorMessage)),
      ifRight: (levels) => emit(
        levels.isEmpty
            ? const LevelError()
            : LevelReady(
                levels: levels,
                selectedLevelId: _keptSelection(levels),
              ),
      ),
    );

    final LevelState catalog = state;
    if (catalog is LevelReady && catalog.levels.isNotEmpty) {
      await _applySignature();
    }
  }

  /// Izgarada dokunulan bant; sunucuya yazılmaz, yalnız seçimdir.
  void select(String levelId) {
    final LevelState current = state;
    if (current is! LevelReady) return;
    if (!current.levels.any((AppLevel level) => level.id == levelId)) return;

    emit(
      LevelReady(
        levels: current.levels,
        currentLevelId: current.currentLevelId,
        selectedLevelId: levelId,
      ),
    );
  }

  /// Seçilen bandı sunucuya yazar. Dönen değer ekranın devam edip
  /// edemeyeceğini söy: `false` durumda kullanıcı aynı ekranda kalır ve
  /// [LevelReady.saveMessage] hatayı gösterir.
  Future<bool> saveSelected() async {
    final LevelState current = state;
    if (current is! LevelReady || current.isSaving) return false;

    final AppLevel? level = current.selectedLevel;
    if (level == null) return false;

    final LevelRepository? source = repository;
    if (source == null) return true;

    emit(
      LevelReady(
        levels: current.levels,
        currentLevelId: current.currentLevelId,
        selectedLevelId: level.id,
        isSaving: true,
      ),
    );

    final result = await source.saveLevel(
      levelId: level.id,
      source: LevelSource.manual,
    );
    if (isClosed) return false;

    return result.fold(
      ifLeft: (failure) {
        emit(
          LevelReady(
            levels: current.levels,
            currentLevelId: current.currentLevelId,
            selectedLevelId: level.id,
            saveMessage: failure.errorMessage,
          ),
        );
        return false;
      },
      ifRight: (AppLevel applied) {
        emit(
          LevelReady(
            levels: current.levels,
            currentLevelId: applied.id,
            selectedLevelId: applied.id,
          ),
        );
        return true;
      },
    );
  }

  /// Sunucudaki imzayı okuyup önseçim yapar. Okunamazsa katalog kullanılmaya
  /// devam eder: kaybolan yalnız "mevcut seviyen" işareti, seçim hâlâ
  /// yazılabilir.
  Future<void> _applySignature() async {
    final LevelRepository? source = repository;
    if (source == null) return;

    final LevelState before = state;
    if (before is! LevelReady) return;

    final result = await source.fetchCurrentLevel();
    if (isClosed) return;

    final LevelState current = state;
    if (current is! LevelReady) return;

    result.fold(
      ifLeft: (failure) => null,
      ifRight: (AppLevel? level) {
        if (level == null ||
            !current.levels.any((AppLevel item) => item.id == level.id)) {
          return null;
        }
        emit(
          LevelReady(
            levels: current.levels,
            currentLevelId: level.id,
            selectedLevelId: current.selectedLevelId ?? level.id,
          ),
        );
        return null;
      },
    );
  }

  /// Katalog yenilenince seçim korunur; yeni listede olmayan bir banda
  /// işaret etmek, yazılamayacak bir id tutmak demektir.
  String? _keptSelection(List<AppLevel> levels) {
    final LevelState current = state;
    final String? selectedId = current is LevelReady
        ? current.selectedLevelId
        : null;
    if (selectedId == null) return null;
    return levels.any((AppLevel level) => level.id == selectedId)
        ? selectedId
        : null;
  }
}
