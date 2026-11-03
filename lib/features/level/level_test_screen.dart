import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/level_test_content.dart';
import '../../core/design_system.dart';
import '../../shared/service_locator.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/level_test_cubit.dart';
import 'data/repositories/level_repository.dart';
import 'data/repositories/placement_repository.dart';
import 'widgets/level_test_empty_view.dart';
import 'widgets/level_test_question_view.dart';
import 'widgets/level_test_result_view.dart';

/// Seviye belirleme testi: cubit durumuna göre yükleme, hata, boş, soru
/// akışı veya sonuç görünümünü seçer. Kendi cubit'i verilmezse DI'dan alır
/// ve oturumu başlatır.
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

  /// Sonuç sunucuya yazıldıktan sonra çağrılır; yazma başarısızsa çağrılmaz.
  final VoidCallback? onCompleted;
  final VoidCallback? onChooseManually;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LevelTestCubit>(
      create: (_) => cubit ?? _cubitFromLocator(),
      child: BlocBuilder<LevelTestCubit, LevelTestState>(
        builder: (BuildContext context, LevelTestState state) {
          final LevelTestCubit controller = context.read<LevelTestCubit>();
          return Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(title: const Text(LevelTestContent.appBarTitle)),
            body: switch (state) {
              LevelTestLoading() => const LevelTestSkeleton(),
              LevelTestError(:final message) => AppErrorView(
                message: message,
                onRetry: onRetry ?? controller.start,
              ),
              LevelTestEmpty() => const LevelTestEmptyView(),
              LevelTestReady(
                :final question,
                :final answeredCount,
                :final totalCap,
                :final selectedIndex,
                :final isSubmitting,
              ) =>
                LevelTestQuestionView(
                  question: question,
                  index: answeredCount,
                  total: totalCap,
                  selectedOption: selectedIndex,
                  isSubmitting: isSubmitting,
                  onSelectOption: controller.selectOption,
                  onContinue: controller.advance,
                ),
              LevelTestResult(
                :final levelIndex,
                :final isSaving,
                :final saveMessage,
              ) =>
                LevelTestResultView(
                  levelIndex: levelIndex,
                  isSaving: isSaving,
                  message: saveMessage,
                  onConfirm: () async {
                    if (await controller.confirmResult()) {
                      onCompleted?.call();
                    }
                  },
                  onChooseManually: onChooseManually,
                ),
            },
          );
        },
      ),
    );
  }

  /// Veri katmanı kayıtlıysa (üretim) gerçek cubit, değilse boşta kalan
  /// iskelet — widget testleri ekranı tek başına render eder.
  LevelTestCubit _cubitFromLocator() {
    final PlacementRepository? repository =
        slIfRegistered<PlacementRepository>();
    final LevelRepository? levelRepository = slIfRegistered<LevelRepository>();
    return repository == null
          ? LevelTestCubit()
          : LevelTestCubit(
              repository: repository,
              levelRepository: levelRepository,
            )
      ..start();
  }
}
