import 'package:flutter/material.dart';

import '../../../core/constants/profile_content.dart';
import '../../../core/design_system.dart';

/// Ayar sheet'lerinin ortak gövdesi: başlık, içerik ve TAMAM butonu.
class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: AppTypography.headingSm.copyWith(
                color: AppColors.inkDisplay,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            ...children,
            const SizedBox(height: AppSpacing.base),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(ProfileContent.sheetDoneCtaLabel),
            ),
          ],
        ),
      ),
    );
  }
}
