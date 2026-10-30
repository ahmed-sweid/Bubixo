import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/splash_content.dart';
import '../../../core/design_system.dart';

/// Maskot yer tutucusu — gerçek karakter seti gelene kadar yalnızca sistem
/// renkleriyle çizilmiş baykuş.
class BubixoMark extends StatelessWidget {
  const BubixoMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: SplashContent.markSemanticsLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: 200,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: 176,
              height: 176,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                children: <Widget>[
                  Positioned(top: 0, left: 34, child: _tuft()),
                  Positioned(top: 0, right: 34, child: _tuft()),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    right: 32,
                    bottom: 10,
                    child: Container(
                      height: 76,
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(48),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 36,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _eye(),
                        const SizedBox(width: 12),
                        _eye(),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 71,
                    left: 73,
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.accentFox,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tuft() => Container(
    width: 30,
    height: 30,
    decoration: const BoxDecoration(
      color: AppColors.primary,
      shape: BoxShape.circle,
    ),
  );

  Widget _eye() => Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(
      color: AppColors.canvas,
      shape: BoxShape.circle,
    ),
    child: const Center(
      child: SizedBox(
        width: 14,
        height: 14,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.inkDisplay,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}
