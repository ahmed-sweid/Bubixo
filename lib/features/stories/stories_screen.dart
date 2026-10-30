import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'stories_state.dart';
import 'widgets/stories_empty_view.dart';
import 'widgets/stories_view.dart';

/// Hikâyeler sekmesi: veri katmanı bağlanana kadar durumları render eder.
class StoriesScreen extends StatelessWidget {
  const StoriesScreen({
    super.key,
    this.state = const StoriesLoading(),
    this.onRetry,
  });

  final StoriesState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: switch (state) {
        StoriesLoading() => const StoriesSkeleton(),
        StoriesError() => AppErrorView(onRetry: onRetry),
        StoriesEmpty() => const StoriesEmptyView(),
        StoriesReady(:final stories, :final categories, :final continueStory) =>
          StoriesView(
            stories: stories,
            categories: categories,
            continueStory: continueStory,
          ),
      },
    );
  }
}
