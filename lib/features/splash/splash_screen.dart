import 'package:flutter/material.dart';

import '../../core/constants/splash_content.dart';
import '../../core/design_system.dart';
import '../auth/login_screen.dart';
import '../onboarding/onboarding_screen.dart';
import 'widgets/bubixo_mark.dart';

/// Açılış ekranı: saf beyaz kanvas, maskot yer tutucusu, yeşil marka adı ve
/// sistem ritmiyle BÜYÜK HARF CTA çifti (yeşil dolgu + macaw kontur).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  late final CurvedAnimation _brandReveal = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
  );

  late final CurvedAnimation _actionsReveal = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.3, 1, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _bob = Tween<double>(
    begin: -6,
    end: 6,
  ).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    final reducedMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    _entrance.forward();
    if (!reducedMotion) {
      _float.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  void _startOnboarding() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()));
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _reveal(
                  animation: _brandReveal,
                  reducedMotion: reducedMotion,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _bob,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, reducedMotion ? 0 : _bob.value),
                          child: child,
                        ),
                        child: const BubixoMark(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        SplashContent.appName,
                        style: AppTypography.displayLg.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        SplashContent.tagline,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.bodyMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _reveal(
                    animation: _actionsReveal,
                    reducedMotion: reducedMotion,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _startOnboarding,
                            child: const Text(SplashContent.startCtaLabel),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _openLogin,
                            child: const Text(SplashContent.loginCtaLabel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reveal({
    required Animation<double> animation,
    required bool reducedMotion,
    required Widget child,
  }) {
    if (reducedMotion) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - animation.value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
