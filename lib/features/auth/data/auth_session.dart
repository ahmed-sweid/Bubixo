import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/supabase_backend.dart';
import 'models/auth_models.dart';

/// Oturum durumu: `AuthSession` elle token saklamaz, flutter_secure_storage
/// kullanmaz. Supabase SDK oturumu kendi güvenli deposunda tutar ve yeniler;
/// bizim işimiz yalnız durumu UI'a duyurmak.
class AuthSession extends ChangeNotifier {
  AuthSession(this._backend) {
    _attach();
  }

  final SupabaseBackend _backend;
  StreamSubscription<AuthState>? _subscription;

  bool _authenticated = false;
  String? _userId;
  String? _email;
  String? _displayName;

  bool get isAuthenticated => _authenticated;
  String? get userId => _userId;
  String? get email => _email;

  /// Kayıt sırasında gönderilen ad (`raw_user_meta_data.display_name`).
  String? get displayName => _displayName;

  /// Oturum yoksa `null`. Cubit'ler ve ekranlar SDK `User` yerine bunu görür.
  AuthAccount? get account {
    final id = _userId;
    if (id == null) return null;
    return AuthAccount(id: id, email: _email, displayName: _displayName);
  }

  void _attach() {
    if (!_backend.isReady) return;

    _apply(_backend.client.auth.currentSession);
    _subscription = _backend.client.auth.onAuthStateChange.listen(
      (state) => _apply(state.session),
      onError: (Object error) {
        // Dinleyicide hata olursa oturum "bilinmiyor" kalır; UI'yı çökertmez.
        _apply(null);
      },
    );
  }

  void _apply(Session? session) {
    final user = session?.user;
    final next = user != null;
    final nextId = user?.id;
    final nextEmail = user?.email;
    final nextName = user?.userMetadata?['display_name'] as String?;

    if (next == _authenticated &&
        nextId == _userId &&
        nextEmail == _email &&
        nextName == _displayName) {
      return;
    }
    _authenticated = next;
    _userId = nextId;
    _email = nextEmail;
    _displayName = nextName;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
