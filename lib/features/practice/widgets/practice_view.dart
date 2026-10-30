import 'package:flutter/material.dart';

import '../../../core/constants/nav_content.dart';
import '../../../core/design_system.dart';
import '../practice_state.dart';
import 'practice_type_card.dart';

/// Pratikler sekmesinin hazır durum görünümü: başlık ve tür kartları.
class PracticeView extends StatelessWidget {
  const PracticeView({super.key, required this.types, this.onOpenType});

  final List<PracticeTypeProgress> types;
  final ValueChanged<PracticeTypeProgress>? onOpenType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: <Widget>[
              Text(
                NavContent.practiceTitle,
                style: AppTypography.headingMd.copyWith(
                  color: AppColors.inkDisplay,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                NavContent.practiceDescription,
                style: AppTypography.bodyLg.copyWith(
                  color: AppColors.bodyMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final PracticeTypeProgress type in types)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: PracticeTypeCard(
                    progress: type,
                    onTap: onOpenType == null ? null : () => onOpenType!(type),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
