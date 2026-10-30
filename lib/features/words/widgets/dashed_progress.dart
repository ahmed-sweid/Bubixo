import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Ezberleme ilerlemesi: tamamlanan dilimler yeşil boyanır.
class DashedProgress extends StatelessWidget {
  const DashedProgress({super.key, required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        total,
        (int index) => Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index < done ? AppColors.primary : AppColors.hairline,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          ),
        ),
      ),
    );
  }
}
