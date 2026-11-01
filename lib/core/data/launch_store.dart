import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın cihaz-yerel açılış tercihi deposu.
///
/// Yalnızca "bu cihazda ilk açılış akışı tamamlandı" bilgisini tutar. Oturum
/// bilgisi Supabase SDK'nın kendi güvenli deposunda durur; buraya token ya da
/// kullanıcı verisi yazılmaz, okunmaz.
///
/// [init] yalnızca `main()`den çağrılır. Testler başlatmadığı için [current]
/// sessiz varsayılanda kalır: okuma `false` döner, yazma hiçbir şey yapmaz.
abstract class LaunchStore {
  static const String _introCompletedKey = 'intro_completed';

  static LaunchStore current = const SilentLaunchStore();

  static Future<void> init() async {
    current = SharedPreferencesLaunchStore(
      await SharedPreferences.getInstance(),
    );
  }

  Future<bool> isIntroCompleted();

  Future<void> markIntroCompleted();
}

/// Anahtar-değer deposu olan gerçek uygulama.
class SharedPreferencesLaunchStore implements LaunchStore {
  SharedPreferencesLaunchStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<bool> isIntroCompleted() async =>
      _prefs.getBool(LaunchStore._introCompletedKey) ?? false;

  @override
  Future<void> markIntroCompleted() =>
      _prefs.setBool(LaunchStore._introCompletedKey, true);
}

/// Başlatılmamış ortam (widget testleri) için hiçbir şey hatırlamayan varsayılan.
class SilentLaunchStore implements LaunchStore {
  const SilentLaunchStore();

  @override
  Future<bool> isIntroCompleted() async => false;

  @override
  Future<void> markIntroCompleted() async {}
}
