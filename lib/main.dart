import 'package:flutter/material.dart';

import 'core/design_system.dart';
import 'core/services/sound_service.dart';
import 'features/splash/splash_screen.dart';

void main() {
  // Yalnızca gerçek uygulamada başlatılır; widget testleri servisi init etmez
  // ve bu sayede ses katmanı sessiz kalır.
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
