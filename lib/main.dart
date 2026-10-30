import 'package:flutter/material.dart';

import 'core/design_system.dart';
import 'features/splash/splash_screen.dart';

void main() {
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
