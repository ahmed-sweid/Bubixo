import 'package:dart_either/dart_either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/lesson_models.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/lesson_remote_data_source.dart';

/// Dersler sekmesinin tip güvenli kapısı: `Left` her zaman gösterilebilir bir
/// `Failure`, `Right` katalogda en az bir seviye olan bir liste.
abstract class LessonRepository {
  Future<Either<Failure, List<LessonLevel>>> fetchCatalog();
}

class LessonRepositoryImpl implements LessonRepository {
  LessonRepositoryImpl(this._remote, this._network);

  final LessonRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, List<LessonLevel>>> fetchCatalog() =>
      _guard(_remote.fetchCatalog);

  /// Görünümler `auth.uid()` ile birleştiği için oturumsuz okuma `42501`
  /// döndürür; bu bir ağ hatası değil, `PermissionFailure` olarak ekrana
  /// düşmesi gereken tasarım gereği bir kapıdır.
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
