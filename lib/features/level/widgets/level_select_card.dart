import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/design_system.dart';
import '../data/models/level_models.dart';

/// Seviye seçim ızgarasındaki tek CEFR kartı; kademeli giriş animasyonuyla
/// belirir ve seçilince büyüyüp vurgulanır.
///
/// Etiket sunucudaki `levels.code`'dan, açıklama ise `LevelContent`'ten
/// **koda göre** gelir: sunucunun `title` alanı İngilizce olduğu için
/// arayüz metni sabit katmandadır.
class LevelSelectCard extends StatelessWidget {
  const LevelSelectCard({
    super.key,
    required this.level,
    required this.position,
    required this.selected,
    required this.entrance,
    required this.onSelected,
  });

  final AppLevel level;

  /// Izgaradaki sıra numarası — kademe animasyonunun gecikmesi için.
  final int position;
  final bool selected;
  final AnimationController entrance;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final Color ink = selected ? AppColors.primaryPressed : AppColors.inkDisplay;
    final String described = LevelContent.descriptionFor(level.code);
    final String description = described.isEmpty ? level.title : described;
    final Animation<double> appear = CurvedAnimation(
      parent: entrance,
      curve: Interval(
        position * 0.08,
        (position * 0.08 + 0.55).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: appear,
      builder: (BuildContext context, Widget? child) => Opacity(
        opacity: appear.value,
        child: Transform.translate(
          offset: Offset(0, (1 - appear.value) * 16),
          child: child,
        ),
      ),
      child: AnimatedScale(
        scale: selected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: onSelected,
          borderRadius: AppRadius.roundedLg,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 84,
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.canvas,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.hairline,
                width: AppSizes.borderWidth,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        level.code,
                        style: AppTypography.headingSm.copyWith(color: ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: AppTypography.caption.copyWith(
                          color: selected
                              ? AppColors.primaryPressed
                              : AppColors.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: selected ? 1 : 0,
                    child: Icon(
                      Iconsax.tick_circle,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
