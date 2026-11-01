/// Kullanıcıya gösterilen hata metinleri.
///
/// Proje kuralı: ekranda görünen her metin `lib/core/constants` altında durur;
/// hata katmanı da bundan hariç değildir. `Failure.errorMessage` değerlerini
/// buradan okur, teknik kodları (`SQLSTATE`, GoTrue hata kodu) göstermez.
abstract final class ErrorContent {
  static const String generic = 'Bir şeyler ters gitti. Lütfen tekrar dene.';
  static const String offline =
      'İnternet bağlantısı yok. Bağlantını kontrol edip tekrar dene.';
  static const String timeout = 'İstek zaman aşımına uğradı. Tekrar dene.';
  static const String serverBusy = 'Sunucu şu anda yoğun. Birazdan tekrar dene.';
  static const String unauthorized = 'Oturumun sona erdi. Yeniden giriş yapmalısın.';
  static const String forbidden = 'Bu içerik için erişim yetkin yok.';
  static const String notFound = 'Aradığın kayıt bulunamadı.';
  static const String validation = 'Gönderilen bilgiler geçersiz.';
  static const String conflict = 'Bu kayıt zaten mevcut.';
  static const String emailAlreadyRegistered = 'Bu e-posta zaten kayıtlı.';
  static const String invalidCredentials = 'E-posta veya şifre hatalı.';
  static const String weakPassword = 'Şifre çok zayıf, en az 6 karakter olmalı.';
  static const String emailNotConfirmed =
      'E-postanı onaylamadan devam edemezsin.';
  static const String rateLimited =
      'Çok fazla deneme yaptın. Biraz sonra tekrar dene.';
  static const String storage = 'Dosya işlemi tamamlanamadı.';
  static const String cache = 'Kayıt okunamadı. Uygulamayı yeniden başlat.';
}
