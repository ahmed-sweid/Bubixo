import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Material metin rollerinin Duolingo tipografi token'larina köprüsü.
///
/// Ritim kuralı: lacivert display yalnızca sayfa açılışında (h1), yeşil
/// displayMedium ise bölüm başlıklarında kullanılır; ikisi aynı bölümde
/// yer almaz. Display-tier olmayan başlıklar bodyStrong grisi taşır.
/// Etiket rollerinin rengi bileşenin foregroundColor'ından gelir.
final TextTheme appTextTheme = TextTheme(
  displayLarge: AppTypography.displayXl.copyWith(color: AppColors.inkDisplay),
  displayMedium: AppTypography.displayLg.copyWith(color: AppColors.primary),
  displaySmall: AppTypography.headingMd.copyWith(color: AppColors.bodyStrong),
  headlineLarge: AppTypography.headingMd.copyWith(color: AppColors.bodyStrong),
  headlineMedium: AppTypography.headingSm.copyWith(color: AppColors.bodyStrong),
  headlineSmall: AppTypography.headingSm.copyWith(color: AppColors.bodyStrong),
  titleLarge: AppTypography.bodyMd.copyWith(color: AppColors.body),
  titleMedium: AppTypography.bodyMd.copyWith(color: AppColors.body),
  titleSmall: AppTypography.bodySm.copyWith(color: AppColors.body),
  bodyLarge: AppTypography.bodyLg.copyWith(color: AppColors.bodyMuted),
  bodyMedium: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
  bodySmall: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
  labelLarge: AppTypography.labelUppercase,
  labelMedium: AppTypography.labelUppercaseSm,
  labelSmall: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
);
