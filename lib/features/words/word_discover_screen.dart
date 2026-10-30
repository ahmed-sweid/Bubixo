import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/words_content.dart';
import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/discover_cubit.dart';
import 'widgets/discover_empty_view.dart';
import 'widgets/word_discover_view.dart';

/// Kelime havuzundan seçim yapılan sayfa; cubit durumuna göre yükleme,
/// hata, boş veya hazır görünümü seçer.
class WordDiscoverScreen extends StatelessWidget {
  const WordDiscoverScreen({super.key, this.cubit, this.onRetry});

  final DiscoverCubit? cubit;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiscoverCubit>(
      create: (_) => cubit ?? DiscoverCubit(),
      child: BlocBuilder<DiscoverCubit, DiscoverState>(
        builder: (BuildContext context, DiscoverState state) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(title: const Text(WordsContent.discoverScreenTitle)),
            body: SafeArea(
              child: switch (state) {
                DiscoverLoading() => const DiscoverSkeleton(),
                DiscoverError() => AppErrorView(onRetry: onRetry),
                DiscoverEmpty() => const DiscoverEmptyView(),
                DiscoverReady(:final words, :final categories) =>
                  WordDiscoverView(words: words, categories: categories),
              },
            ),
          );
        },
      ),
    );
  }
}
