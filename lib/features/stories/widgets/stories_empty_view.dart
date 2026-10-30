import 'package:flutter/material.dart';

import '../../../core/constants/state_content.dart';
import '../../../core/design_system.dart';
import '../../common/states/app_empty_view.dart';

/// Hiç hikâye yokken gösterilen tam ekran boş durum.
class StoriesEmptyView extends StatelessWidget {
  const StoriesEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: const AppEmptyView(
              imageAsset: StateContent.storiesEmptyImageAsset,
              title: StateContent.storiesEmptyTitle,
              message: StateContent.storiesEmptyMessage,
            ),
          ),
        ),
      ),
    );
  }
}
