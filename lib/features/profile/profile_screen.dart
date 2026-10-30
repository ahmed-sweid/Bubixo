import 'package:flutter/material.dart';

import '../../core/design_system.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'profile_state.dart';
import 'widgets/profile_empty_view.dart';
import 'widgets/profile_view.dart';

/// Profil sekmesi: cubit durumuna göre yükleme, hata, boş veya hazır
/// görünümü seçer.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.state = const ProfileLoading(),
    this.onRetry,
  });

  final ProfileState state;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
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
  }
}
