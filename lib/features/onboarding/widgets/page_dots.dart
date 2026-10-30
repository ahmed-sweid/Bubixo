import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Onboarding sayfa göstergesi; aktif nokta uzar.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSpacing.xs,
      children: List.generate(count, (index) {
        final bool active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.hairline,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}
