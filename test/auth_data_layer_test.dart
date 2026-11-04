import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/error/exceptions.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/features/auth/data/models/auth_models.dart';
import 'package:en_bubixo/core/network/network_info.dart';
import 'package:en_bubixo/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:en_bubixo/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeNetworkInfo implements NetworkInfo {
  _FakeNetworkInfo(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeAuthRemote implements AuthRemoteDataSource {
  _FakeAuthRemote({this.account});

  AuthAccount? account;
  Object? throwError;

  int signInCalls = 0;
  int signUpCalls = 0;
  int signOutCalls = 0;
  int resetCalls = 0;
  int googleCalls = 0;
  String? lastSignUpDisplayName;

  @override
  Future<AuthAccount> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (throwError != null) throw throwError!;
    return account!;
  }

  @override
  Future<AuthAccount> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    signUpCalls++;
    lastSignUpDisplayName = displayName;
    if (throwError != null) throw throwError!;
    return account!;
  }

  @override
  Future<bool> signInWithGoogle() async {
    googleCalls++;
    if (throwError != null) throw throwError!;
    return true;
  }

  @override
  Future<void> sendPasswordResetLink({required String email}) async {
    resetCalls++;
    if (throwError != null) throw throwError!;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (throwError != null) throw throwError!;
    account = null;
  }
}

Failure? _leftOf<T>(Either<Failure, T> either) =>
    either.fold(ifLeft: (f) => f, ifRight: (_) => null);

T? _rightValue<T>(Either<Failure, T> either) =>
    either.fold(ifLeft: (_) => null, ifRight: (r) => r);

void main() {
  const AuthAccount account = AuthAccount(
    id: 'a1b2c3d4-0000-4000-8000-000000000001',
    email: 'demo@bubixo.app',
    displayName: 'Demo',
  );

  late _FakeAuthRemote remote;
  late _FakeNetworkInfo network;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = _FakeAuthRemote(account: account);
    network = _FakeNetworkInfo(true);
    repository = AuthRepositoryImpl(remote, network);
  });

  group('AuthRepository', () {
    test('bağlantı yoksa istek atmadan NetworkFailure döner', () async {
      network.connected = false;

      final result = await repository.signIn(
        email: account.email!,
        password: 'parola123',
      );

      expect(_leftOf(result), isA<NetworkFailure>());
      expect(remote.signInCalls, 0);
      expect(
        _leftOf(result)!.errorMessage,
        'İnternet bağlantısı yok. Bağlantını kontrol edip tekrar dene.',
      );
    });

    test('geçersiz kimlik bilgisi Türkçe mesajla AuthFailure olur', () async {
      remote.throwError = const BackendException(
        message: 'Invalid login credentials',
        code: 'invalid_credentials',
      );

      final result = await repository.signIn(
        email: account.email!,
        password: 'yanlış',
      );

      final failure = _leftOf(result);
      expect(failure, isA<AuthFailure>());
      expect(failure!.code, 'invalid_credentials');
      expect(failure.errorMessage, 'E-posta veya şifre hatalı.');
    });

    test('kayıtlı e-posta ConflictFailure olur', () async {
      remote.throwError = const BackendException(
        message: 'User already registered',
        code: 'user_already_exists',
      );

      final result = await repository.signUp(
        email: account.email!,
        password: 'parola123',
        displayName: 'Demo',
      );

      final failure = _leftOf(result);
      expect(failure, isA<ConflictFailure>());
      expect(failure!.errorMessage, 'Bu e-posta zaten kayıtlı.');
    });

    test('doğrulama bekleyen kayıt email_not_confirmed olarak döner', () async {
      remote.throwError = const BackendException(
        message: 'Email confirmation is required before signing in.',
        code: 'email_not_confirmed',
      );

      final result = await repository.signUp(
        email: account.email!,
        password: 'parola123',
        displayName: 'Demo',
      );

      final failure = _leftOf(result);
      expect(failure, isA<AuthFailure>());
      expect(
        failure!.errorMessage,
        'E-postanı onaylamadan devam edemezsin.',
      );
    });

    test('başarılı giriş hesap döner ve ad metadata ile taşınır', () async {
      final result = await repository.signUp(
        email: account.email!,
        password: 'parola123',
        displayName: 'Ayşe',
      );

      expect(remote.signUpCalls, 1);
      expect(remote.lastSignUpDisplayName, 'Ayşe');
      expect(_rightValue(result), account);
    });

    test('Google akışı yalnızca "tarayıcı açıldı" döner, hesap değil', () async {
      final result = await repository.signInWithGoogle();

      expect(remote.googleCalls, 1);
      expect(_rightValue(result), isTrue);
    });

    test('çıkış uzak kaynağa bir kez ulaşır', () async {
      final result = await repository.signOut();

      expect(remote.signOutCalls, 1);
      expect(_leftOf(result), isNull);
    });
  });

  group('AuthAccount', () {
    test('displayLabel adsız hesapta e-postaya düşer', () {
      const unnamed = AuthAccount(id: 'x', email: 'adis@bubixo.app');
      const blank = AuthAccount(id: 'x', displayName: '   ', email: 'a@b.c');

      expect(unnamed.displayLabel, 'adis@bubixo.app');
      expect(blank.displayLabel, 'a@b.c');
      expect(account.displayLabel, 'Demo');
    });
  });
}
