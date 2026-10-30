import 'package:flutter/material.dart';

import '../../../core/constants/state_content.dart';
import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';
import '../../common/states/app_empty_view.dart';

/// Kelime havuzu boşken gösterilen durum.
class DiscoverEmptyView extends StatelessWidget {
  const DiscoverEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const AppEmptyView(
          imageAsset: StateContent.searchEmptyImageAsset,
          title: WordsContent.discoverEmptyTitle,
          message: WordsContent.discoverEmptyMessage,
        ),
      ),
    );
  }
}
