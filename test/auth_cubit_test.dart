import 'package:dart_either/dart_either.dart';
import 'package:en_bubixo/core/data/auth_session.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/error/failure.dart';
import 'package:en_bubixo/core/models/auth_models.dart';
import 'package:en_bubixo/features/auth/cubit/auth_cubit.dart';
import 'package:en_bubixo/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.account});

  AuthAccount? account;
  Failure? failure;

  int signInCalls = 0;
  int signUpCalls = 0;
  int googleCalls = 0;
  int resetCalls = 0;
  int signOutCalls = 0;

  Either<Failure, T> _result<T>(T value) =>
      failure == null ? Right<Failure, T>(value) : Left<Failure, T>(failure!);

  @override
  Future<Either<Failure, AuthAccount>> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    return _result(account!);
  }

  @override
  Future<Either<Failure, AuthAccount>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    signUpCalls++;
    return _result(account!);
  }

  @override
  Future<Either<Failure, bool>> signInWithGoogle() async {
    googleCalls++;
    return _result(true);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetLink({
    required String email,
  }) async {
    resetCalls++;
    return _result(null);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    signOutCalls++;
    return _result(null);
  }
}

/// Başlatılmamış kapı: `AuthSession` dinleyici takmaz, `account` null kalır.
class _IdleBackend implements SupabaseBackend {
  @override
  bool get isReady => false;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Bu testte Supabase client kullanılmaz');
}

void main() {
  const AuthAccount account = AuthAccount(
    id: 'u-1',
    email: 'demo@bubixo.app',
    displayName: 'Demo',
  );

  late _FakeAuthRepository repository;
  late AuthCubit cubit;

  setUp(() {
    repository = _FakeAuthRepository(account: account);
    cubit = AuthCubit(repository: repository);
  });

  tearDown(() async => cubit.close());

  AuthState last() => cubit.state;

  group('AuthCubit', () {
    test('başlangıç durumu oturum okunana kadar checking', () {
      expect(last(), const AuthChecking());
    });

    test('restore oturum yoksa signedOut yayımlar', () {
      cubit.restore();

      expect(last(), const AuthSignedOut());
    });

    test('başarılı giriş hesaba geçiş yapar', () async {
      await cubit.signIn(email: account.email!, password: 'parola123');

      expect(last(), const AuthSignedIn(account: account));
      expect(repository.signInCalls, 1);
    });

    test('geçersiz kimlik bilgisi Türkçe hata mesajına dönüşür', () async {
      repository.failure = const AuthFailure(
        code: 'invalid_credentials',
        messageOverride: 'E-posta veya şifre hatalı.',
      );

      await cubit.signIn(email: account.email!, password: 'yanlış');

      final state = last();
      expect(state, isA<AuthError>());
      expect((state as AuthError).message, 'E-posta veya şifre hatalı.');
    });

    test('kayıt başarılı olunca signedIn', () async {
      await cubit.signUp(
        email: account.email!,
        password: 'parola123',
        displayName: 'Demo',
      );

      expect(last(), const AuthSignedIn(account: account));
      expect(repository.signUpCalls, 1);
    });

    test('ardışık iki giriş komutu son durumda hesap tutar', () async {
      await cubit.signIn(email: account.email!, password: 'parola123');
      await cubit.signIn(email: account.email!, password: 'parola123');

      expect(repository.signInCalls, 2);
      expect(last(), const AuthSignedIn(account: account));
    });

    test('google akışı busy kalır, hesap oturum dönüşünde gelir', () async {
      await cubit.signInWithGoogle();

      expect(repository.googleCalls, 1);
      // OAuth tarayıcıda sürdüğü için cubit kendi kendine signedIn olmaz.
      expect(last(), const AuthBusy());
    });

    test('şifre linki gönderilince adres ekrana taşınır', () async {
      await cubit.sendPasswordResetLink(email: account.email!);

      expect(last(), const AuthResetLinkSent(email: 'demo@bubixo.app'));
    });

    test('çıkış signedOut yayımlar', () async {
      await cubit.signIn(email: account.email!, password: 'parola123');
      await cubit.signOut();

      expect(repository.signOutCalls, 1);
      expect(last(), const AuthSignedOut());
    });

    test('session varsa restore hesabı oturumdan okur', () async {
      final sessionCubit = AuthCubit(
        repository: repository,
        session: AuthSession(_IdleBackend()),
      );
      addTearDown(sessionCubit.close);

      sessionCubit.restore();

      // Başlatılmamış kapıda oturum yoktur.
      expect(sessionCubit.state, const AuthSignedOut());
    });
  });
}
