import '../../core/constants/auth_content.dart';

/// E-posta / şifre doğrulama kuralları — giriş ve kayıt akışları paylaşır.
abstract final class AuthValidators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return AuthContent.requiredField;
    }
    return null;
  }

  static String? email(String? value) {
    final String email = (value ?? '').trim();
    if (email.isEmpty) {
      return AuthContent.requiredField;
    }
    if (!_emailPattern.hasMatch(email)) {
      return AuthContent.invalidEmail;
    }
    return null;
  }

  static String? password(String? value) {
    final String password = value ?? '';
    if (password.isEmpty) {
      return AuthContent.requiredField;
    }
    if (password.length < 6) {
      return AuthContent.shortPassword;
    }
    return null;
  }

  /// Şifre onay alanı doğrulayıcısı — orijinal şifreyle karşılaştırır.
  static String? passwordConfirm(String? value, String password) {
    final String confirm = value ?? '';
    if (confirm.isEmpty) {
      return AuthContent.requiredField;
    }
    if (confirm != password) {
      return AuthContent.passwordMismatch;
    }
    return null;
  }
}
