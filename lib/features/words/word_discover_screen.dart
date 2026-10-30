import 'package:flutter/material.dart';

import '../../core/constants/words_content.dart';
import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'discover_state.dart';
import 'widgets/discover_empty_view.dart';
import 'widgets/word_discover_view.dart';

/// Kelime havuzundan seçim yapılan sayfa; durumları render eder.
class WordDiscoverScreen extends StatelessWidget {
  const WordDiscoverScreen({
    super.key,
    this.state = const DiscoverLoading(),
    this.onRetry,
  });

  final DiscoverState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text(WordsContent.discoverScreenTitle)),
      body: SafeArea(
        child: switch (state) {
          DiscoverLoading() => const DiscoverSkeleton(),
          DiscoverError() => AppErrorView(onRetry: onRetry),
          DiscoverEmpty() => const DiscoverEmptyView(),
          DiscoverReady(:final words, :final categories) => WordDiscoverView(
            words: words,
            categories: categories,
          ),
        },
      ),
    );
  }
}
