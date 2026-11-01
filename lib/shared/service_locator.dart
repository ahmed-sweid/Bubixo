import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/data/auth_session.dart';
import '../core/data/supabase_backend.dart';
import '../core/network/network_info.dart';

final GetIt sl = GetIt.instance;

/// Uygulamanın tüm servis/cubit kayıtları tek yerde.
///
/// Kural: `main()` dışında hiçbir yer `Supabase` veya repository'yi kendisi
/// kurmaz; herkes `sl()`'den alır. Özellik fazlarında (WP3+) buraya
/// `_initLessons()`, `_initWords()` gibi bölüm bölümler eklenir ve cubit'ler
/// `registerFactory` ile kaydedilir (ömrü widget ile birlikte biter).
///
/// `supabase` null bırakılırsa (testler, anahtarsız çalıştırma) kapı hazır
/// değildir ve hiçbir bileşen ağa dokunmaz.
Future<void> initDependencies({SupabaseClient? supabase}) async {
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnection()),
  );

  sl.registerLazySingleton<SupabaseBackend>(() => SupabaseBackendImpl(supabase));

  sl.registerLazySingleton<AuthSession>(
    () => AuthSession(sl()),
    dispose: (session) => session.dispose(),
  );
}
