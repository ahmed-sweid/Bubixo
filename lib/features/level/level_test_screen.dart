import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/level_test_content.dart';
import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/level_test_cubit.dart';
import 'widgets/level_test_empty_view.dart';
import 'widgets/level_test_question_view.dart';
import 'widgets/level_test_result_view.dart';

/// Seviye belirleme testi: cubit durumuna göre yükleme, hata, boş, soru
/// akışı veya sonuç görünümünü seçer.
class LevelTestScreen extends StatelessWidget {
  const LevelTestScreen({
    super.key,
    this.cubit,
    this.onRetry,
    this.onCompleted,
    this.onChooseManually,
  });

  final LevelTestCubit? cubit;
  final VoidCallback? onRetry;

  /// Test bitince önerilen CEFR indeksiyle çağrılır.
  final ValueChanged<int>? onCompleted;
  final VoidCallback? onChooseManually;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LevelTestCubit>(
      create: (_) => cubit ?? LevelTestCubit(),
      child: BlocBuilder<LevelTestCubit, LevelTestState>(
        builder: (BuildContext context, LevelTestState state) {
          final LevelTestCubit controller = context.read<LevelTestCubit>();
          return Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(title: const Text(LevelTestContent.appBarTitle)),
            body: switch (state) {
              LevelTestLoading() => const LevelTestSkeleton(),
              LevelTestError() => AppErrorView(onRetry: onRetry),
              LevelTestEmpty() => const LevelTestEmptyView(),
              LevelTestReady(
                :final questions,
                :final questionIndex,
                :final selectedOption,
              ) =>
                LevelTestQuestionView(
                  question: questions[questionIndex],
                  index: questionIndex,
                  total: questions.length,
                  selectedOption: selectedOption,
                  onSelectOption: controller.selectOption,
                  onContinue: controller.advance,
                ),
              LevelTestResult(:final levelIndex) => LevelTestResultView(
                levelIndex: levelIndex,
                onConfirm: () => onCompleted?.call(levelIndex),
                onChooseManually: onChooseManually,
              ),
            },
          );
        },
      ),
    );
  }
}
