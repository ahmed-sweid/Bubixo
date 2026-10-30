import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'widgets/words_empty_view.dart';
import 'widgets/words_view.dart';
import 'words_state.dart';

/// Kelimeler sekmesi: veri katmanı bağlanana kadar durumları render eder.
class WordsScreen extends StatelessWidget {
  const WordsScreen({
    super.key,
    this.state = const WordsLoading(),
    this.onRetry,
  });

  final WordsState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      WordsLoading() => const Scaffold(
        backgroundColor: AppColors.canvas,
        body: WordsSkeleton(),
      ),
      WordsError() => Scaffold(
        backgroundColor: AppColors.canvas,
        body: AppErrorView(onRetry: onRetry),
      ),
      WordsEmpty() => const Scaffold(
        backgroundColor: AppColors.canvas,
        body: WordsEmptyView(),
      ),
      WordsReady(:final words, :final suggestedWords, :final translation) =>
        WordsView(
          words: words,
          suggestedWords: suggestedWords,
          translation: translation,
        ),
    };
  }
}
