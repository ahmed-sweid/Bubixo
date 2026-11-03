import 'package:flutter/material.dart';

import '../../core/data/launch_store.dart';
import '../../core/design_system.dart';
import '../../shared/service_locator.dart';
import '../auth/data/auth_session.dart';
import '../auth/login_screen.dart';
import '../shell/home_shell.dart';
import '../splash/splash_screen.dart';

/// Açılış kapısı: ilk akışı (splash → onboarding → auth → seviye) yalnızca
/// uygulama ilk kez açıldığında gösterir.
///
/// Karar iki yerel bilgiyle verilir, ağa çıkılmaz: oturum
/// [AuthSession.isAuthenticated] (Supabase SDK deposu), ilk akış bayrağı
/// [LaunchStore.isIntroCompleted] (cihaz kaydı). Bayrak seviye seçimi
/// onaylandığında yazılır; o yüzden yarım kalan bir akış bir daha gösterilir.
///
/// [store] ve [session] enjekte edilmezse üretim değerleri kullanılır;
/// enjeksiyon alanı widget testlerinin dört senaryoyu da kontrol edebilmesi
/// için var.
class AppGate extends StatefulWidget {
  const AppGate({super.key, this.store, this.session});

  final LaunchStore? store;
  final AuthSession? session;

  /// Dört giriş noktası tek yerde: ilk akış tamamsa oturuma göre ana ekran ya
  /// da giriş; değilse baştan başlayan tanıtım akışı.
  @visibleForTesting
  static Widget startScreen({
    required bool introCompleted,
    required bool signedIn,
  }) {
    if (!introCompleted) return const SplashScreen();
    return signedIn ? const HomeShell() : const LoginScreen();
  }

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  Widget? _destination;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final LaunchStore store = widget.store ?? LaunchStore.current;
    final AuthSession? session = widget.session ?? slIfRegistered<AuthSession>();
    final bool introCompleted = await store.isIntroCompleted();
    if (!mounted) return;
    setState(
      () => _destination = AppGate.startScreen(
        introCompleted: introCompleted,
        signedIn: session?.isAuthenticated ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Karar cihaz deposundan geldiği için tek kare sürer; marka animasyonu
    // yalnız ilk açılışta (SplashScreen) gösterilir, dönen kullanıcı görmez.
    return _destination ??
        const Scaffold(
          backgroundColor: AppColors.canvas,
          body: SizedBox.shrink(),
        );
  }
}
