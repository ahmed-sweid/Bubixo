import 'package:flutter/material.dart';

import '../../../core/constants/state_content.dart';
import '../../../core/design_system.dart';
import '../../common/states/app_empty_view.dart';

/// Profil sekmesinin boş durumu.
class ProfileEmptyView extends StatelessWidget {
  const ProfileEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: const AppEmptyView(
              imageAsset: StateContent.profileEmptyImageAsset,
              title: StateContent.profileEmptyTitle,
              message: StateContent.profileEmptyMessage,
            ),
          ),
        ),
      ),
    );
  }
}
