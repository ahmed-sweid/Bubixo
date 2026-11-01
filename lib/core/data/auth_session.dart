import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_backend.dart';

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

  bool get isAuthenticated => _authenticated;
  String? get userId => _userId;
  String? get email => _email;

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
    final next = session?.user != null;
    final nextId = session?.user.id;
    final nextEmail = session?.user.email;

    if (next == _authenticated && nextId == _userId && nextEmail == _email) {
      return;
    }
    _authenticated = next;
    _userId = nextId;
    _email = nextEmail;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
