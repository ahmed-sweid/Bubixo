part of 'auth_cubit.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => const <Object?>[];
}

/// İlk durum: SDK deposu henüz okunmadı.
final class AuthChecking extends AuthState {
  const AuthChecking();
}

/// Bir kimlik komodu yolda.
final class AuthBusy extends AuthState {
  const AuthBusy();
}

final class AuthSignedIn extends AuthState {
  const AuthSignedIn({required this.account});

  final AuthAccount account;

  @override
  List<Object?> get props => <Object?>[account];
}

final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}

/// Şifre linki gönderildi; ekranda hangi adrese gönderildiği gösterilir.
final class AuthResetLinkSent extends AuthState {
  const AuthResetLinkSent({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

/// `message` doğrudan `Failure.errorMessage`'dir, yani gösterilebilir Türkçe.
final class AuthError extends AuthState {
  const AuthError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
