import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'cubit/profile_cubit.dart';
import 'widgets/profile_empty_view.dart';
import 'widgets/profile_view.dart';

/// Profil sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.cubit, this.onRetry});

  final ProfileCubit? cubit;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (_) => cubit ?? ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (BuildContext context, ProfileState state) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: switch (state) {
              ProfileLoading() => const ProfileSkeleton(),
              ProfileError() => AppErrorView(onRetry: onRetry),
              ProfileEmpty() => const ProfileEmptyView(),
              ProfileReady(
                :final profile,
                :final settings,
                :final stats,
                :final doneToday,
              ) =>
                ProfileView(
                  profile: profile,
                  settings: settings,
                  stats: stats,
                  doneToday: doneToday,
                ),
            },
          );
        },
      ),
    );
  }
}
