import 'package:dart_either/dart_either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/level_remote_data_source.dart';
import '../models/level_models.dart';

/// Seviye seçiminin tip güvenli kapısı.
///
/// `Left` gösterilebilir bir `Failure` (çevrimdışı, oturumsuz profil okuması,
/// olmayan seviye), `Right` katalog veya uygulanmış imza. Seviye hesabı burada
/// yapılmaz: test sonucu sunucunun `apply_placement_result` kararından gelir.
abstract class LevelRepository {
  Future<Either<Failure, List<AppLevel>>> fetchLevels();

  /// İmza yoksa `Right(null)` — kullanıcı henüz seviye seçmedi, bu boş
  /// durumdur. Oturumsuz okuma ise `Left(PermissionFailure)`: `profiles`
  /// politikası anon'a kapalı.
  Future<Either<Failure, AppLevel?>> fetchCurrentLevel();

  Future<Either<Failure, AppLevel>> saveLevel({
    required String levelId,
    required LevelSource source,
  });

  Future<Either<Failure, AppLevel>> applyPlacementResult(String attemptId);
}

class LevelRepositoryImpl implements LevelRepository {
  LevelRepositoryImpl(this._remote, this._network);

  final LevelRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, List<AppLevel>>> fetchLevels() =>
      _guard(_remote.fetchLevels);

  @override
  Future<Either<Failure, AppLevel?>> fetchCurrentLevel() =>
      _guard(_remote.fetchCurrentLevel);

  @override
  Future<Either<Failure, AppLevel>> saveLevel({
    required String levelId,
    required LevelSource source,
  }) => _guard(() => _remote.saveLevel(levelId: levelId, source: source));

  @override
  Future<Either<Failure, AppLevel>> applyPlacementResult(String attemptId) =>
      _guard(() => _remote.applyPlacementResult(attemptId));

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
