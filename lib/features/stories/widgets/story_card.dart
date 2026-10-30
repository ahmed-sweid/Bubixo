import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/story_models.dart';

/// Hikâye ızgarasındaki kapak, başlık ve seviye rozetli kart.
class StoryCard extends StatelessWidget {
  const StoryCard({super.key, required this.story, this.onTap});

  final Story story;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedLg,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHover,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg - AppSizes.borderWidth),
                  ),
                ),
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.asset(story.coverAsset, fit: BoxFit.contain),
                    if (story.isRead)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            child: Icon(
                              Iconsax.check,
                              size: 14,
                              color: AppColors.canvas,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                    child: Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMd.copyWith(
                        height: 1.25,
                        color: AppColors.inkDisplay,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      LevelContent.cefrLevels[story.levelIndex],
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accentMacaw,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
