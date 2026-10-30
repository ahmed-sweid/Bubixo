import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/design_system.dart';

/// Ayar ve hesap satırlarını tek kartta toplayan grup; satırlar arasında
/// ince ayraç çizilir.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.hairline,
          width: AppSizes.borderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0)
              Container(
                height: AppSizes.hairlineWidth,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                color: AppColors.hairline,
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

/// Tek satır: ikon, başlık, isteğe bağlı özet değer ve sağ ok.
class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.destructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;

  /// Satırın sağ tarafında gösterilen kısa özet (örn. mevcut dil).
  final String? value;

  /// Kırmızı hesap işlemleri için.
  final bool destructive;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = destructive
        ? AppColors.accentCardinal
        : AppColors.bodyMuted;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLg.copyWith(
                  color: destructive
                      ? AppColors.accentCardinal
                      : AppColors.body,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (value != null) ...<Widget>[
              const SizedBox(width: AppSpacing.sm),
              Text(
                value!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.bodySoft,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: destructive
                  ? AppColors.accentCardinal
                  : AppColors.bodySoft,
            ),
          ],
        ),
      ),
    );
  }
}
