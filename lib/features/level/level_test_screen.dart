import 'package:flutter/material.dart';

import '../../core/constants/level_test_content.dart';
import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'level_test_state.dart';
import 'widgets/level_test_empty_view.dart';
import 'widgets/level_test_view.dart';

/// Seviye belirleme testi: cubit durumuna göre yükleme, hata, boş veya
/// soru akışını seçer.
class LevelTestScreen extends StatelessWidget {
  const LevelTestScreen({
    super.key,
    this.state = const LevelTestLoading(),
    this.onRetry,
    this.onCompleted,
    this.onChooseManually,
  });

  final LevelTestState state;
  final VoidCallback? onRetry;

  /// Test bitince önerilen CEFR indeksiyle çağrılır.
  final ValueChanged<int>? onCompleted;
  final VoidCallback? onChooseManually;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text(LevelTestContent.appBarTitle)),
      body: switch (state) {
        LevelTestLoading() => const LevelTestSkeleton(),
        LevelTestError() => AppErrorView(onRetry: onRetry),
        LevelTestEmpty() => const LevelTestEmptyView(),
        LevelTestReady(:final questions) => LevelTestView(
          questions: questions,
          onCompleted: onCompleted,
          onChooseManually: onChooseManually,
        ),
      },
    );
  }
}
