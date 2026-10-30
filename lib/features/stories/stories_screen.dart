import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/stories_cubit.dart';
import 'widgets/stories_empty_view.dart';
import 'widgets/stories_view.dart';

/// Hikâyeler sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key, this.cubit, this.onRetry});

  final StoriesCubit? cubit;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoriesCubit>(
      create: (_) => cubit ?? StoriesCubit(),
      child: BlocBuilder<StoriesCubit, StoriesState>(
        builder: (BuildContext context, StoriesState state) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: switch (state) {
              StoriesLoading() => const StoriesSkeleton(),
              StoriesError() => AppErrorView(onRetry: onRetry),
              StoriesEmpty() => const StoriesEmptyView(),
              StoriesReady(
                :final stories,
                :final categories,
                :final continueStory,
              ) =>
                StoriesView(
                  stories: stories,
                  categories: categories,
                  continueStory: continueStory,
                ),
            },
          );
        },
      ),
    );
  }
}
