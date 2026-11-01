import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/auth_content.dart';
import '../data/auth_session.dart';
import '../../../core/error/failure.dart';
import '../data/models/auth_models.dart';
import '../data/repositories/auth_repository.dart';

part 'auth_state.dart';

/// Kimlik akışlarının durum makinesi.
///
/// İki bilgi kaynağı var ve işleri ayrı: **komutlar** [repository]'den,
/// **oturumun güncel durumu** [session]'dan gelir. OAuth'ta uygulama
/// tarayıcıyı açar açmaz geri döner ama oturum dönüşte kurulur; bu yüzden
/// cubit [AuthBusy]'de bekler ve oturum geri bildirimiyle ilerler.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.repository, this.session})
    : super(const AuthChecking()) {
    session?.addListener(_onSessionChanged);
  }

  final AuthRepository repository;
  final AuthSession? session;

  /// Açılışta (splash) sorulur; ağa çıkmaz, SDK deposunu okur.
  void restore() => emit(_fromSession());

  Future<void> signIn({
    required String email,
    required String password,
  }) => _submit(() => repository.signIn(email: email, password: password));

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) => _submit(
    () => repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    ),
  );

  Future<void> signInWithGoogle() async {
    emit(const AuthBusy());
    final result = await repository.signInWithGoogle();
    result.fold(
      ifLeft: _emitError,
      ifRight: (started) {
        if (!started) {
          emit(const AuthError(message: AuthContent.googleLaunchFailed));
        }
      },
    );
  }

  Future<void> sendPasswordResetLink({required String email}) async {
    emit(const AuthBusy());
    final result = await repository.sendPasswordResetLink(email: email);
    result.fold(
      ifLeft: _emitError,
      ifRight: (_) => emit(AuthResetLinkSent(email: email)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthBusy());
    final result = await repository.signOut();
    result.fold(ifLeft: _emitError, ifRight: (_) => emit(const AuthSignedOut()));
  }

  /// Başarıda dönen hesap varsa onu, yoksa oturumun gerçek durumunu yayar.
  Future<void> _submit<T>(Future<Either<Failure, T>> Function() request) async {
    emit(const AuthBusy());
    final result = await request();
    result.fold(
      ifLeft: _emitError,
      ifRight: (value) => _emitSuccess(value is AuthAccount ? value : null),
    );
  }

  void _emitSuccess(AuthAccount? account) =>
      emit(account == null ? _fromSession() : AuthSignedIn(account: account));

  void _emitError(Failure failure) =>
      emit(AuthError(message: failure.errorMessage));

  AuthState _fromSession() {
    final current = session?.account;
    return current == null
        ? const AuthSignedOut()
        : AuthSignedIn(account: current);
  }

  void _onSessionChanged() {
    final current = session;
    if (current == null) return;
    // Süre dolumu / başka ekrandan çıkış: form beklememeli, hata ezilmemeli.
    if (!current.isAuthenticated && state is! AuthError) {
      emit(const AuthSignedOut());
    } else if (current.account != null && state is! AuthSignedIn) {
      emit(AuthSignedIn(account: current.account!));
    }
  }

  @override
  Future<void> close() {
    session?.removeListener(_onSessionChanged);
    return super.close();
  }
}
