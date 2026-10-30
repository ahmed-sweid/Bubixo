import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/practice_cubit.dart';
import 'widgets/practice_empty_view.dart';
import 'widgets/practice_view.dart';

/// Pratikler sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, this.cubit, this.onRetry, this.onOpenType});

  final PracticeCubit? cubit;
  final VoidCallback? onRetry;
  final ValueChanged<PracticeTypeProgress>? onOpenType;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PracticeCubit>(
      create: (_) => cubit ?? PracticeCubit(),
      child: BlocBuilder<PracticeCubit, PracticeState>(
        builder: (BuildContext context, PracticeState state) {
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
        },
      ),
    );
  }
}
