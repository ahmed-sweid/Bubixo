import 'package:equatable/equatable.dart';

import '../constants/error_content.dart';
import '../constants/supabase_tables.dart';
import 'exceptions.dart';

/// Kullanıcıya gösterilebilir hata. `errorMessage` doğrudan arayüze gider,
/// `code` yalnızca loglama ve test içindir.
sealed class Failure extends Equatable {
  const Failure({this.code, this.messageOverride});

  final String? code;
  final String? messageOverride;

  String get errorMessage => messageOverride ?? _defaultMessage;

  String get _defaultMessage;

  @override
  List<Object?> get props => <Object?>[code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.offline;
}

class ServerFailure extends Failure {
  const ServerFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.generic;
}

class AuthFailure extends Failure {
  const AuthFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.unauthorized;
}

class PermissionFailure extends Failure {
  const PermissionFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.forbidden;
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.notFound;
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.validation;
}

class ConflictFailure extends Failure {
  const ConflictFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.conflict;
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.rateLimited;
}

class StorageFailure extends Failure {
  const StorageFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.storage;
}

class CacheFailure extends Failure {
  const CacheFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.cache;
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.code, super.messageOverride});

  @override
  String get _defaultMessage => ErrorContent.generic;
}

/// `BackendException` -> `Failure`.
///
/// SQLSTATE'ler Postgres'ten, GoTrue kodları kimlik doğrulamadan gelir; ikisi
/// de tek yerden çevrilir ki ekranda jenerik "bir şeyler ters gitti" yerine
/// doğru Türkçe mesaj görünsün.
Failure failureFrom(BackendException error) {
  final code = error.code;

  // GoTrue hata kodları (signup/reset/signIn akışları).
  switch (code) {
    case 'invalid_credentials':
    case 'invalid_login':
      return const AuthFailure(
        code: 'invalid_credentials',
        messageOverride: ErrorContent.invalidCredentials,
      );
    case 'user_already_exists':
    case 'user_exists':
      return const ConflictFailure(
        code: 'user_already_exists',
        messageOverride: ErrorContent.emailAlreadyRegistered,
      );
    case 'weak_password':
      return const ValidationFailure(
        code: 'weak_password',
        messageOverride: ErrorContent.weakPassword,
      );
    case 'email_not_confirmed':
      return const AuthFailure(
        code: 'email_not_confirmed',
        messageOverride: ErrorContent.emailNotConfirmed,
      );
    case 'session_expired':
    case 'refresh_token_not_found':
      return const AuthFailure(code: 'session_expired');
    case 'over_request_rate_limit':
    case 'rate_limit_exceeded':
      return const RateLimitFailure(code: 'rate_limit_exceeded');
  }

  // SQLSTATE + HTTP karşılıkları.
  switch (code) {
    case '42501':
    case '403':
      return PermissionFailure(code: code);
    case '401':
      return AuthFailure(code: code);
    case '404':
    case 'PGRST116':
      return NotFoundFailure(code: code);
    case '400':
    case '22P02':
    case '23514':
      return ValidationFailure(code: code);
    case '429':
      return RateLimitFailure(code: code);
    case '23505':
    case '23503':
      // `profiles` üzerinde benzersizlik ihlali kayıt denemesinden gelir;
      // diğer tablolarda jenerik çakışma mesajı doğru olandır.
      return error.table == null || error.table == SupabaseTable.profiles
          ? const ConflictFailure(
              code: '23505',
              messageOverride: ErrorContent.emailAlreadyRegistered,
            )
          : ConflictFailure(code: code);
    case '500':
    case '502':
    case '503':
    case '504':
      return ServerFailure(
        code: code,
        messageOverride: ErrorContent.serverBusy,
      );
    case 'PGRST118':
    case 'PGRST205':
      return ServerFailure(code: code);
  }

  // Sınıf bazlı SQLSTATE'ler: 08* bağlantı, 53* kaynak, 5* sunucu tarafı.
  if (code != null &&
      (code.startsWith('08') ||
          code.startsWith('53') ||
          code.startsWith('57') ||
          code.startsWith('58') ||
          code.startsWith('40'))) {
    return const ServerFailure(
      messageOverride: ErrorContent.serverBusy,
    );
  }
  return ServerFailure(code: code ?? error.message);
}

/// SDK dışından gelen (socket, timeout, tanısız) hatalar için güvenlik ağı.
Failure failureFromUnknown(Object error) {
  if (error is BackendException) return failureFrom(error);
  return UnexpectedFailure(messageOverride: ErrorContent.generic, code: '$error');
}
