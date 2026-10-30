import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/state_content.dart';
import '../../../core/design_system.dart';

/// İskelet parçalarını tek bir shimmer animasyonunda saran zemin.
///
/// Parçalar [SkeletonBox] / [SkeletonLine] ile kurulur; renkleri shimmer
/// gradyanı ezer, bu yüzden parçalarda yalnızca ölçü ve yarıçap verilir.
class AppShimmer extends StatelessWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: StateContent.loadingLabel,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: AppColors.hairline,
          highlightColor: AppColors.surfaceHover,
          period: const Duration(milliseconds: 1400),
          child: child,
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.md,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.hairline,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key, this.widthFactor = 1, this.height = 12});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: SkeletonBox(height: height, radius: AppRadius.full),
    );
  }
}
