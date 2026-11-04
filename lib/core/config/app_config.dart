/// Derleme zamanı yapılandırması.
///
/// Buradaki anahtar **istemci tarafı** anahtardır: Supabase'de güvenlik sınırı
/// RLS policy'leridir, anahtar değil; bu yüzden uygulamaya gömülü olması
/// normaldir. `service_role` / secret anahtar bu dosyaya asla girmemeli.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'BUBIXO_SUPABASE_URL',
    defaultValue: 'https://ryrdgtpdxdhypxqiatfy.supabase.co',
  );

  static const String supabasePublishableKey = String.fromEnvironment(
    'BUBIXO_SUPABASE_KEY',
    defaultValue: 'sb_publishable_-ujO1PH0HOn7Rg36ZZ1TBg_WhI00mzf',
  );

  /// Supabase başlatılabilir mi? Boş değer, `--dart-define` verilmediği
  /// durumlarda (ör. bazı test çalıştırmaları) ağ katmanını devre dışı tutar.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
