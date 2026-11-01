import 'package:dart_either/dart_either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/placement_remote_data_source.dart';
import '../models/placement_models.dart';

/// Seviye belirleme testinin tip güvenli kapısı.
///
/// `Left` gösterilebilir bir `Failure` (oturum yok, sahiplik reddi, kapalı
/// oturum, çift cevap), `Right` sunucunun adaptif adımı. Cevap doğruluğu bu
/// katmanda da hesaplanmaz — hesaplanacak bir anahtar istemciye inmez.
abstract class PlacementRepository {
  Future<Either<Failure, PlacementSession?>> startAttempt();

  Future<Either<Failure, PlacementAnswer>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
    int? responseTimeMs,
  });

  Future<Either<Failure, PlacementOutcome>> fetchResult(String attemptId);
}

class PlacementRepositoryImpl implements PlacementRepository {
  PlacementRepositoryImpl(this._remote, this._network);

  final PlacementRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, PlacementSession?>> startAttempt() =>
      _guard(_remote.startAttempt);

  @override
  Future<Either<Failure, PlacementAnswer>> submitAnswer({
    required String attemptId,
    required String questionId,
    required String answerId,
    int? responseTimeMs,
  }) => _guard(
    () => _remote.submitAnswer(
      attemptId: attemptId,
      questionId: questionId,
      answerId: answerId,
      responseTimeMs: responseTimeMs,
    ),
  );

  @override
  Future<Either<Failure, PlacementOutcome>> fetchResult(String attemptId) =>
      _guard(() => _remote.fetchResult(attemptId));

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
