import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:en_bubixo/core/constants/level_content.dart';
import 'package:en_bubixo/core/data/launch_store.dart';
import 'package:en_bubixo/core/data/supabase_backend.dart';
import 'package:en_bubixo/core/design_system.dart';
import 'package:en_bubixo/features/auth/data/auth_session.dart';
import 'package:en_bubixo/features/auth/login_screen.dart';
import 'package:en_bubixo/features/gate/app_gate.dart';
import 'package:en_bubixo/features/level/level_chosen_screen.dart';
import 'package:en_bubixo/features/level/level_screen.dart';
import 'package:en_bubixo/features/level/widgets/level_select_card.dart';
import 'package:en_bubixo/features/shell/home_shell.dart';
import 'package:en_bubixo/features/shell/widgets/nav_tab.dart';
import 'package:en_bubixo/features/splash/splash_screen.dart';

class _RecordingLaunchStore implements LaunchStore {
  _RecordingLaunchStore({required this.introCompleted});

  bool introCompleted;

  @override
  Future<bool> isIntroCompleted() async => introCompleted;

  @override
  Future<void> markIntroCompleted() async => introCompleted = true;
}

/// SDK'ya dokunmayan oturum: `client` null olduğu için `_attach` erken çıkar,
/// yalnız `isAuthenticated` yorumlanır.
class _AnonymousSession extends AuthSession {
  _AnonymousSession() : super(SupabaseBackendImpl());
}

class _SignedInSession extends AuthSession {
  _SignedInSession() : super(SupabaseBackendImpl());

  @override
  bool get isAuthenticated => true;
}

void main() {
  Future<void> pumpGate(
    WidgetTester tester, {
    required bool introCompleted,
    AuthSession? session,
  }) async {
    tester.view.physicalSize = const Size(1170, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AppGate(
          store: _RecordingLaunchStore(introCompleted: introCompleted),
          session: session ?? _AnonymousSession(),
        ),
      ),
    );
    await tester.pump();
  }

  group('Açılış kapısı', () {
    test('karar tablosu tek yerde: dört giriş noktası', () {
      expect(
        AppGate.startScreen(introCompleted: false, signedIn: false),
        isA<SplashScreen>(),
      );
      expect(
        AppGate.startScreen(introCompleted: false, signedIn: true),
        isA<SplashScreen>(),
      );
      expect(
        AppGate.startScreen(introCompleted: true, signedIn: false),
        isA<LoginScreen>(),
      );
      expect(
        AppGate.startScreen(introCompleted: true, signedIn: true),
        isA<HomeShell>(),
      );
    });

    testWidgets('ilk açılış: oturum olsa bile tanıtım akışı baştan başlar', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester, introCompleted: false, session: _SignedInSession());

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(HomeShell), findsNothing);
    });

    testWidgets('ilk akış bitti, oturum yok: yalnız giriş ekranı', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester, introCompleted: true);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('ilk akış bitti, oturum var: doğrudan ana ekran', (
      WidgetTester tester,
    ) async {
      await pumpGate(tester, introCompleted: true, session: _SignedInSession());

      expect(find.byType(HomeShell), findsOneWidget);
      expect(find.byType(NavTab), findsNWidgets(5));
      expect(find.byType(LoginScreen), findsNothing);

      // Ana ekran hikâyeler sekmesini kurarken kubite bağlı kısa bir gecikme
      // çalışır; zamanlayıcı test bitmeden tükenmeli.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    });
  });

  testWidgets('seviye onayı ilk akışı bitirir ve tanıtım yığınını siler', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 6000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final _RecordingLaunchStore store = _RecordingLaunchStore(
      introCompleted: false,
    );
    LaunchStore.current = store;
    addTearDown(() => LaunchStore.current = const SilentLaunchStore());

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LevelScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(LevelSelectCard).first);
    await tester.pump();
    await tester.tap(find.text(LevelContent.chooseLabel));
    // pumpAndSettle kullanılmaz: ana ekranın iskeletleri sonsuz shimmer
    // çalıştırıyor, settle hiç gelmez.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(store.introCompleted, isTrue);
    expect(find.byType(LevelChosenScreen), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);

    // Onay sayfasındaki buton tanıtım yığınını silip ana ekrana götürür.
    await tester.tap(find.text(LevelContent.chosenCtaLabel));
    // pumpAndSettle kullanılmaz: ana ekranın iskeletleri sonsuz shimmer
    // çalıştırıyor, settle hiç gelmez.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.pump();

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.byType(LevelChosenScreen), findsNothing);
    expect(find.byType(LevelScreen), findsNothing);

    // Geri: yığın silindiği için kök rota kaldı, uygulama ana ekranda kalır.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(HomeShell), findsOneWidget);
  });
}
