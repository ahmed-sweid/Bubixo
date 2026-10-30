import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/lessons_cubit.dart';
import 'widgets/lessons_empty_view.dart';
import 'widgets/lessons_view.dart';

/// Dersler sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key, this.cubit, this.onRetry});

  final LessonsCubit? cubit;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LessonsCubit>(
      create: (_) => cubit ?? LessonsCubit(),
      child: BlocBuilder<LessonsCubit, LessonsState>(
        builder: (BuildContext context, LessonsState state) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: switch (state) {
              LessonsLoading() => const LessonsSkeleton(),
              LessonsError() => AppErrorView(onRetry: onRetry),
              LessonsEmpty() => const LessonsEmptyView(),
              LessonsReady(:final levels) => LessonsView(levels: levels),
            },
          );
        },
      ),
    );
  }
}
