import 'package:dart_either/dart_either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/word_remote_data_source.dart';
import '../models/word_snapshot.dart';

/// Kelimeler sekmesinin tip güvenli kapısı: `Left` gösterilebilir bir
/// `Failure`, `Right` kullanıcının listesi ve öneri havuzu.
abstract class WordRepository {
  Future<Either<Failure, WordSnapshot>> fetchSnapshot();
}

class WordRepositoryImpl implements WordRepository {
  WordRepositoryImpl(this._remote, this._network);

  final WordRemoteDataSource _remote;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, WordSnapshot>> fetchSnapshot() =>
      _guard(_remote.fetchSnapshot);

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
