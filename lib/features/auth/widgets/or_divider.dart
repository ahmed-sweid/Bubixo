import 'package:flutter/material.dart';

import '../../../core/constants/auth_content.dart';
import '../../../core/design_system.dart';

/// Form ile sosyal giriş arasındaki "VEYA" ayırıcısı.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            LoginContent.dividerLabel,
            style: AppTypography.labelUppercaseSm.copyWith(
              color: AppColors.bodyMuted,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
