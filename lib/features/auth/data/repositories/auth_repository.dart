import 'package:dart_either/dart_either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/auth_models.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/auth_remote_data_source.dart';

/// Kimlik akışlarının tip güvenli kapısı: `Left` her zaman gösterilebilir
/// bir `Failure`, `Right` her zaman bir hesap (veya void).
abstract class AuthRepository {
  Future<Either<Failure, AuthAccount>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthAccount>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// `true` = tarayıcı açıldı; oturum `AuthSession` üzerinden gelir.
  Future<Either<Failure, bool>> signInWithGoogle();

  Future<Either<Failure, void>> sendPasswordResetLink({required String email});

  Future<Either<Failure, void>> signOut();
}

/// Oturumun *durumu* buradan okunmaz: onun tek sahibi `AuthSession`.
/// Repository yalnız komut çalıştırır ve hatayı `Failure`'a çevirir.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._network);

  final AuthRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, AuthAccount>> signIn({
    required String email,
    required String password,
  }) => _guard(
    () => _remote.signIn(email: email, password: password),
  );

  @override
  Future<Either<Failure, AuthAccount>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) => _guard(
    () => _remote.signUp(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  @override
  Future<Either<Failure, bool>> signInWithGoogle() =>
      _guard(_remote.signInWithGoogle);

  @override
  Future<Either<Failure, void>> sendPasswordResetLink({required String email}) =>
      _guard<void>(() => _remote.sendPasswordResetLink(email: email));

  @override
  Future<Either<Failure, void>> signOut() => _guard<void>(_remote.signOut);

  /// İstekten önce ağa bakılır: bağlantısız deneme kullanıcıya "sunucu yoğun"
  /// değil "internetsin yok" demek için, ve gereksiz istek atmamak için.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() request) async {
    if (!await _network.isConnected) {
      return Left<Failure, T>(const NetworkFailure());
    }
    try {
      return Right<Failure, T>(await request());
    } on BackendException catch (error) {
      return Left<Failure, T>(failureFrom(error));
    } on Object catch (error) {
      return Left<Failure, T>(failureFromUnknown(error));
    }
  }
}
