import 'package:flutter/material.dart';

import '../../core/constants/onboarding_content.dart';
import '../../core/design_system.dart';
import '../auth/login_screen.dart';
import 'widgets/page_dots.dart';

/// Onboarding: üç sayfalık tanıtım akışı — beyaz kanvas, illüstrasyon,
/// lacivert başlık, gri gövde ve BÜYÜK HARF yeşil CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  bool get _isLastPage => _pageIndex == OnboardingContent.pages.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _advance() {
    if (_isLastPage) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingContent.pages.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (context, index) {
                  final page = OnboardingContent.pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Image.asset(
                                page.imageAsset,
                                fit: BoxFit.contain,
                                semanticLabel: page.title,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          page.title,
                          style: AppTypography.headingMd.copyWith(
                            color: AppColors.inkDisplay,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.base),
                        Text(
                          page.description,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.bodyMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  );
                },
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PageDots(
                        count: OnboardingContent.pages.length,
                        activeIndex: _pageIndex,
                      ),
                      const SizedBox(height: AppSpacing.base),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _advance,
                          child: Text(
                            OnboardingContent.pages[_pageIndex].ctaLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
