import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design_system.dart';
import '../../shared/service_locator.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/words_cubit.dart';
import 'data/repositories/word_repository.dart';
import 'widgets/words_empty_view.dart';
import 'widgets/words_view.dart';

/// Kelimeler sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer. Kendi cubit'i verilmezse DI'dan alır ve listeyi yükler.
class WordsScreen extends StatelessWidget {
  const WordsScreen({super.key, this.cubit, this.onRetry});

  final WordsCubit? cubit;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WordsCubit>(
      create: (_) => cubit ?? _cubitFromLocator(),
      child: BlocBuilder<WordsCubit, WordsState>(
        builder: (BuildContext context, WordsState state) {
          return switch (state) {
            WordsLoading() => const Scaffold(
              backgroundColor: AppColors.canvas,
              body: WordsSkeleton(),
            ),
            WordsError(:final message) => Scaffold(
              backgroundColor: AppColors.canvas,
              body: AppErrorView(
                message: message,
                onRetry: onRetry ?? () => context.read<WordsCubit>().load(),
              ),
            ),
            WordsEmpty() => const Scaffold(
              backgroundColor: AppColors.canvas,
              body: WordsEmptyView(),
            ),
            WordsReady(
              :final words,
              :final suggestedWords,
              :final translation,
              :final enToTr,
            ) =>
              WordsView(
                words: words,
                suggestedWords: suggestedWords,
                translation: translation,
                enToTr: enToTr,
                onTranslate: (String term) =>
                    context.read<WordsCubit>().translate(term),
                onSwap: () => context.read<WordsCubit>().swapDirection(),
              ),
          };
        },
      ),
    );
  }

  /// Veri katmanı kayıtlıysa (üretim) gerçek cubit, değilse boşta kalan
  /// iskelet — widget testleri ekranı tek başına render eder.
  WordsCubit _cubitFromLocator() {
    final WordRepository? repository = slIfRegistered<WordRepository>();
    return repository == null
        ? WordsCubit()
        : WordsCubit(repository: repository)..load();
  }
}
