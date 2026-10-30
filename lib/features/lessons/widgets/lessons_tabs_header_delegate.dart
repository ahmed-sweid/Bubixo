import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Sekme çubuğunu kaydırma sırasında üstte tutan sabit yükseklikli başlık.
class LessonsTabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const LessonsTabsHeaderDelegate({required this.child});

  final Widget child;

  static const double height = 58;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: ColoredBox(color: AppColors.canvas, child: child),
    );
  }

  @override
  bool shouldRebuild(LessonsTabsHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
