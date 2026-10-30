/// Kimlik akışları (giriş / kayıt) içerik verisi — metinler tek noktadan
/// yönetilir; sayfa katmanı yalnızca tüketir.
abstract final class AuthContent {
  static const String nameLabel = 'Ad';
  static const String emailLabel = 'E-posta';
  static const String passwordLabel = 'Şifre';
  static const String passwordConfirmLabel = 'Şifreni Onayla';

  static const String requiredField = 'Bu alan boş bırakılamaz.';
  static const String invalidEmail = 'Geçerli bir e-posta adresi gir.';
  static const String shortPassword = 'Şifren en az 6 karakter olmalı.';
  static const String passwordMismatch = 'Şifreler eşleşmiyor.';
}

abstract final class LoginContent {
  static const String imageAsset = 'assets/images/Welcome-rafiki.png';
  static const String title = 'Tekrar hoş geldin!';
  static const String subtitle =
      'Hesabına giriş yap ve kaldığın yerden devam et.';

  /// Etiketler BÜYÜK HARF saklanır: Dart'ın toUpperCase()'i 'i'yi noktasız
  /// 'I'a çevirdiği için Türkçe etiketler kaynağında büyük yazılır.
  static const String ctaLabel = 'GİRİŞ YAP';
  static const String forgotLabel = 'ŞİFREMİ UNUTTUM';
  static const String googleCtaLabel = 'GOOGLE İLE GİRİŞ YAP';
  static const String googleIconAsset = 'assets/gg/search.png';
  static const String dividerLabel = 'VEYA';
  static const String signupPromptLabel = 'HESABIN YOK MU?';
  static const String signupCtaLabel = 'KAYDOL';
}

abstract final class SignupContent {
  static const String imageAsset = 'assets/images/Goal-rafiki.png';
  static const String title = 'Hedefine ilk adım at!';
  static const String subtitle = 'Hesabını oluştur, öğrenmeye hemen başla.';
  static const String ctaLabel = 'HESAP OLUŞTUR';
  static const String existingAccountLabel = 'ZATEN HESABIM VAR';
}

abstract final class ForgotPasswordContent {
  static const String title = 'Şifreni mi unuttun?';
  static const String subtitle =
      'Hesabına bağlı e-posta adresini gir; şifre güncelleme linkini '
      'sana gönderelim.';
  static const String ctaLabel = 'LİNK GÖNDER';

  static const String formImageAsset = 'assets/images/Sent Message-rafiki.png';
  static const String sentImageAsset = 'assets/images/Sent Message-rafiki.png';
  static const String sentTitle = 'E-postanı kontrol et!';

  /// {email} yer tutucusu gönderim anında girilen adresle değiştirilir.
  static const String sentDescription =
      'Şifre güncelleme linkini {email} adresine gönderdik. '
      'Gelmezse spam klasörüne bak.';
  static const String backToLoginLabel = 'GİRİŞ EKRANINA DÖN';
}
