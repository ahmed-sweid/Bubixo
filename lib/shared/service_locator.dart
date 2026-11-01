import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/data/auth_session.dart';
import '../core/data/supabase_backend.dart';
import '../core/network/network_info.dart';
import '../features/auth/cubit/auth_cubit.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository.dart';

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

  _initAuth();
}

/// Özellik başına ayrı kayıt bölümü: her veri katmanı kendi fonksiyonunda.
void _initAuth() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );

  // Cubit ömrü widget ile birlikte biter; oturumun kalıcı durumu
  // `AuthSession` lazy singleton'ında durur.
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(repository: sl(), session: sl()),
  );
}
