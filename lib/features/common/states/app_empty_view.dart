import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Boş durum: bağlama göre değişen görsel, başlık, açıklama ve isteğe bağlı
/// tek eylem. İlk girişteki boş listeler eylem çağrısıyla doldurulmaya
/// davet eder; kullanıcının yapabileceği bir şey yoksa eylem verilmez.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String imageAsset;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(imageAsset, height: 180, fit: BoxFit.contain),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headingSm.copyWith(
              color: AppColors.inkDisplay,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLg.copyWith(color: AppColors.bodyMuted),
          ),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
