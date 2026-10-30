import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/profile_models.dart';

/// Profil fotoğrafı; portresi olmayan kullanıcı için adın baş harfleriyle
/// çizilen yeşil avatar.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.profile, this.size = 56});

  final UserProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final String? avatarAsset = profile.avatarAsset;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: avatarAsset == null ? AppColors.primary : AppColors.surfaceHover,
        border: Border.all(
          color: avatarAsset == null
              ? AppColors.primaryPressed
              : AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarAsset == null
          ? Center(
              child: Text(
                profile.initials,
                style: AppTypography.labelUppercase.copyWith(
                  color: AppColors.canvas,
                  fontSize: size * 0.32,
                ),
              ),
            )
          : Image.asset(
              avatarAsset,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder:
                  (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) => Center(
                    child: Text(
                      profile.initials,
                      style: AppTypography.labelUppercase.copyWith(
                        color: AppColors.bodyMuted,
                        fontSize: size * 0.32,
                      ),
                    ),
                  ),
            ),
    );
  }
}

/// Sabit kalan kimlik kartı: avatar, ad, e-posta ve düzenleme butonu.
class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key, required this.profile, this.onEdit});

  final UserProfile profile;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      child: Row(
        children: <Widget>[
          ProfileAvatar(profile: profile),
          const SizedBox(width: AppSpacing.base),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.name,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  profile.email,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Iconsax.edit, size: 16),
            label: const Text(ProfileContent.editCtaLabel),
          ),
        ],
      ),
    );
  }
}
