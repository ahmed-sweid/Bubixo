import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/stories_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/story_models.dart';

/// Yarıda bırakılan hikâyeyi cümle ilerlemesiyle birlikte gösteren devam
/// kartı.
class ContinueStoryCard extends StatelessWidget {
  const ContinueStoryCard({super.key, required this.story, this.onTap});

  final Story story;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final int current = (story.lastReadSentenceIndex + 1).clamp(
      0,
      story.sentences.length,
    );
    final String progress = StoriesContent.progressTemplate
        .replaceFirst('{current}', '$current')
        .replaceFirst('{total}', '${story.sentences.length}');

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedLg,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 108,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(AppRadius.lg - AppSizes.borderWidth),
                ),
                child: ColoredBox(
                  color: AppColors.surfaceHover,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset(story.coverAsset, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.inkDisplay,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    LinearProgressIndicator(
                      value: current / story.sentences.length,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      progress,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        Text(
                          StoriesContent.continueCtaLabel,
                          style: AppTypography.labelUppercaseSm.copyWith(
                            color: AppColors.primaryPressed,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Iconsax.forward,
                          size: 16,
                          color: AppColors.primaryPressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
