import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'practice_state.dart';
import 'widgets/practice_empty_view.dart';
import 'widgets/practice_view.dart';

/// Pratikler sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({
    super.key,
    this.state = const PracticeLoading(),
    this.onRetry,
    this.onOpenType,
  });

  final PracticeState state;
  final VoidCallback? onRetry;
  final ValueChanged<PracticeTypeProgress>? onOpenType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: switch (state) {
        PracticeLoading() => const PracticeSkeleton(),
        PracticeError() => AppErrorView(onRetry: onRetry),
        PracticeEmpty() => const PracticeEmptyView(),
        PracticeReady(:final types) => PracticeView(
          types: types,
          onOpenType: onOpenType,
        ),
      },
    );
  }
}
