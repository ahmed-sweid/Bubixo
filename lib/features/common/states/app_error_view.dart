import 'package:flutter/material.dart';

import '../../../core/constants/state_content.dart';
import '../../../core/design_system.dart';

/// Hata durumu: her ekranda aynı görsel, başlık ve açıklama. `onRetry`
/// verildiğinde tekrar dene eylemi gösterilir; veri katmanı bağlanana kadar
/// eylemsiz de kullanılabilir.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Image.asset(
                  StateContent.errorImageAsset,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  StateContent.errorTitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  StateContent.errorMessage,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      child: const Text(StateContent.retryLabel),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
