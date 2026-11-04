import 'package:flutter/material.dart';

import '../../core/constants/level_content.dart';
import '../../core/design_system.dart';
import 'data/models/level_models.dart';

/// Seviye kaydedildikten sonraki onay sayfası: görsel, başlık, metin ve
/// ana sayfaya çıkış. Seçim elle yapıldığında da test sonucu onaylandığında
/// da bu sayfaya gelinir; çıkış butonunu ekranı açan akış bağlar.
class LevelChosenScreen extends StatelessWidget {
  const LevelChosenScreen({super.key, this.level, this.onContinue});

  /// Kaydedilen bant; biliniyorsa metinde koduyla anılır.
  final AppLevel? level;

  /// "ANA SAYFAYA GİT" eylemi — tanıtım yığınını silip ana ekrana gider.
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final String code = level?.code ?? '';
    final String message = code.isEmpty
        ? LevelContent.chosenFallbackMessage
        : LevelContent.chosenMessageTemplate.replaceFirst('{level}', code);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.asset(
                    LevelContent.chosenImageAsset,
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    LevelContent.chosenTitle,
                    style: AppTypography.headingMd.copyWith(
                      color: AppColors.inkDisplay,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.bodyMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      child: const Text(LevelContent.chosenCtaLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
