import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/words_cubit.dart';
import 'widgets/words_empty_view.dart';
import 'widgets/words_view.dart';

/// Kelimeler sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class WordsScreen extends StatelessWidget {
  const WordsScreen({super.key, this.cubit, this.onRetry});

  final WordsCubit? cubit;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WordsCubit>(
      create: (_) => cubit ?? WordsCubit(),
      child: BlocBuilder<WordsCubit, WordsState>(
        builder: (BuildContext context, WordsState state) {
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
            WordsReady(
              :final words,
              :final suggestedWords,
              :final translation,
            ) =>
              WordsView(
                words: words,
                suggestedWords: suggestedWords,
                translation: translation,
              ),
          };
        },
      ),
    );
  }
}
