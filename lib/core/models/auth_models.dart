import 'package:equatable/equatable.dart';

/// Oturum sahibi hesap.
///
/// SDK'nın `User` tipi buraya girmez: `id` = `auth.users.id` (uuid),
/// `displayName` = kayıt olurken `raw_user_meta_data.display_name` olarak
/// gönderilen ad; veritabanındaki `profiles` satırını kayıt anında bir
/// tetikleyici oluşturur.
class AuthAccount extends Equatable {
  const AuthAccount({
    required this.id,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;

  /// Görüntülenecek ad: önce kayıt sırasında girilen ad, yoksa e-posta.
  String get displayLabel =>
      (displayName != null && displayName!.trim().isNotEmpty)
      ? displayName!.trim()
      : (email ?? 'Bubixo kullanıcısı');

  @override
  List<Object?> get props => <Object?>[id, email, displayName];
}
