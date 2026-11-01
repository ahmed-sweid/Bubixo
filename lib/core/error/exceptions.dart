import 'package:supabase_flutter/supabase_flutter.dart';

/// Veri katmanının tek hata tipi.
///
/// Supabase SDK tipleri (`PostgrestException`, `AuthException`,
/// `StorageException`) yalnızca `core/data` içinde doğar; cubit ve ekranlar
/// bu tipi de görmez — repository onu `Failure`'a çevirir.
class BackendException implements Exception {
  const BackendException({
    required this.message,
    this.code,
    this.table,
    this.cause,
  });

  /// Ham hata metni (teknik). Kullanıcıya gösterilmez.
  final String message;

  /// SQLSTATE (`23505`, `42501`, …) veya GoTrue hata kodu
  /// (`invalid_credentials`, `user_already_exists`, …).
  final String? code;

  /// Hatanın geldiği tablo; RPC/storage işlemlerinde null.
  final String? table;

  final Object? cause;

  factory BackendException.postgrest(PostgrestException error, {String? table}) =>
      BackendException(
        message: error.message,
        code: error.code,
        table: table,
        cause: error,
      );

  factory BackendException.auth(AuthException error) => BackendException(
        message: error.message,
        code: error.code,
        cause: error,
      );

  factory BackendException.storage(StorageException error, {String? path}) =>
      BackendException(
        message: error.message,
        code: '${error.statusCode}',
        table: path,
        cause: error,
      );

  /// Bağlantı yok / SDK başlatılmamış / tanısız hata.
  factory BackendException.unknown(Object error) => BackendException(
        message: error.toString(),
        cause: error,
      );

  @override
  String toString() =>
      'BackendException(code: $code, table: $table, message: $message)';
}
