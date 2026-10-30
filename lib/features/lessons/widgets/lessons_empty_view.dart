import 'package:flutter/material.dart';

import '../../../core/constants/state_content.dart';
import '../../../core/design_system.dart';
import '../../common/states/app_empty_view.dart';

/// Dersler sekmesinin boş durumu.
class LessonsEmptyView extends StatelessWidget {
  const LessonsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const AppEmptyView(
              imageAsset: StateContent.lessonsEmptyImageAsset,
              title: StateContent.lessonsEmptyTitle,
              message: StateContent.lessonsEmptyMessage,
            ),
          ),
        ),
      ),
    );
  }
}
