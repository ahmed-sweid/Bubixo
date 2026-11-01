import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/design_system.dart';
import 'core/services/sound_service.dart';
import 'features/splash/splash_screen.dart';
import 'shared/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase başlatması yalnız gerçek uygulamada yapılır; widget testleri
  // `Supabase.initialize()` görmediği için `backend.isReady` false kalır ve
  // veri katmanı ağa hiç dokunmaz.
  if (AppConfig.hasSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }
  await initDependencies(
    supabase: AppConfig.hasSupabase ? Supabase.instance.client : null,
  );

  SoundService.instance.init();
  runApp(const BubixoApp());
}

class BubixoApp extends StatelessWidget {
  const BubixoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubixo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
