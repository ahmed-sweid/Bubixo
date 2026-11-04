import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/data/supabase_backend.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_models.dart';

/// Kimlik doğrulamanın uzak veri kaynağı — GoTrue'ya dokunan **tek** dosya.
///
/// Kural: burada SDK tipleri (`AuthException`, `AuthResponse`) doğar ve
/// `BackendException`'a çevrilir; `Failure` üretmek repository'nin işi.
abstract class AuthRemoteDataSource {
  Future<AuthAccount> signIn({
    required String email,
    required String password,
  });

  Future<AuthAccount> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Google OAuth akışını başlatır. Dönen değer **akışın açılıp açılmadığı**;
  /// oturum tarayıcı dönüşünde `AuthSession` üzerinden gelir, burada değil.
  Future<bool> signInWithGoogle();

  /// E-posta doğrulama/şifre güncelleme linki. GoTrue kullanıcı listesini
  /// sızdırmamak için adres kayıtlı olmasa da başarı döner.
  Future<void> sendPasswordResetLink({required String email});

  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._backend);

  final SupabaseBackend _backend;

  GoTrueClient get _auth {
    if (!_backend.isReady) {
      throw const BackendException(
        message: 'Supabase başlatılmamış; kimlik akışı çalıştırılamaz.',
        code: 'backend_not_ready',
      );
    }
    return _backend.client.auth;
  }

  @override
  Future<AuthAccount> signIn({
    required String email,
    required String password,
  }) => _run(
    () => _auth.signInWithPassword(email: email, password: password),
  );

  @override
  Future<AuthAccount> signUp({
    required String email,
    required String password,
    required String displayName,
  }) => _run(
    () => _auth.signUp(
      email: email,
      password: password,
      // `private.handle_new_bubixo_user()` tetikleyicisi
      // `profiles.display_name` satırını bu anahtardan kurar; adı sabittir.
      data: <String, dynamic>{'display_name': displayName},
    ),
  );

  @override
  Future<bool> signInWithGoogle() async {
    try {
      return await _auth.signInWithOAuth(OAuthProvider.google);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on BackendException {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<void> sendPasswordResetLink({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on BackendException {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on BackendException {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }
  }

  Future<AuthAccount> _run(
    Future<AuthResponse> Function() request,
  ) async {
    final AuthResponse result;
    try {
      result = await request();
    } on AuthException catch (error) {
      throw BackendException.auth(error);
    } on BackendException {
      rethrow;
    } on Object catch (error) {
      throw BackendException.unknown(error);
    }

    final session = result.session;
    if (session == null) {
      // Kayıt oluştu ama proje "e-posta doğrula" ayarındaysa oturum açılmaz.
      throw const BackendException(
        message: 'Email confirmation is required before signing in.',
        code: 'email_not_confirmed',
      );
    }
    return _accountOf(session.user)!;
  }

  AuthAccount? _accountOf(User? user) {
    if (user == null) return null;
    return AuthAccount(
      id: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
    );
  }
}
