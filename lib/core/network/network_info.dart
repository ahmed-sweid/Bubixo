import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Repository'lerin "istek atmadan önce ağda mıyız?" sorusuna verdiği cevap.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connection);

  final InternetConnection _connection;

  @override
  Future<bool> get isConnected => _connection.hasInternetAccess;
}
