import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Profil bölüm etiketi ve içeriğini tek sliver'da toplar.
class ProfileSectionSliver extends StatelessWidget {
  const ProfileSectionSliver({
    super.key,
    required this.label,
    required this.child,
    this.last = false,
  });

  final String label;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          last ? AppSpacing.xl : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              label,
              style: AppTypography.labelUppercaseSm.copyWith(
                color: AppColors.bodyMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

/// Kimlik kartını kaydırma sırasında üstte sabitleyen başlık.
class ProfileIdentityHeaderDelegate extends SliverPersistentHeaderDelegate {
  const ProfileIdentityHeaderDelegate({required this.child});

  final Widget child;

  static const double height = 104;

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
  bool shouldRebuild(ProfileIdentityHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
