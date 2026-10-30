import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/profile_models.dart';

/// Dört öğrenme sayacı ve genel ilerleme çubuğu — tek kartta.
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({super.key, required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    final String wordsDetail = ProfileContent.wordsDetailTemplate
        .replaceAll('{learning}', '${stats.learningWords}')
        .replaceAll('{memorized}', '${stats.memorizedWords}');
    final int percent = (stats.overallProgress * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  icon: Iconsax.book,
                  value: '${stats.completedLessons}',
                  label: ProfileContent.completedLessonsLabel,
                ),
              ),
              const _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Iconsax.element_3,
                  value: '${stats.wordTotal}',
                  label: ProfileContent.wordsLabel,
                  detail: wordsDetail,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _StatTile(
                  icon: Iconsax.story,
                  value: '${stats.readStories}',
                  label: ProfileContent.readStoriesLabel,
                ),
              ),
              const _Divider(),
              Expanded(
                child: _StatTile(
                  icon: Iconsax.edit_2,
                  value: '${stats.completedPractices}',
                  label: ProfileContent.completedPracticesLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: AppSizes.hairlineWidth, color: AppColors.hairline),
          const SizedBox(height: AppSpacing.base),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  ProfileContent.overallProgressLabel,
                  style: AppTypography.labelUppercaseSm.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
              ),
              Text(
                ProfileContent.percentTemplate.replaceFirst(
                  '{percent}',
                  '$percent',
                ),
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.primaryPressed,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: stats.overallProgress,
                backgroundColor: AppColors.hairline,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.hairlineWidth,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      color: AppColors.hairline,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.detail,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.bodySoft),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.headingSm.copyWith(color: AppColors.inkDisplay),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTypography.labelUppercaseSm.copyWith(
            color: AppColors.bodyMuted,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (detail != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            detail!,
            style: AppTypography.caption.copyWith(color: AppColors.bodySoft),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
