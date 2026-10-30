import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Alt gezinme çubuğundaki tek sekme: ikon ve etiket, seçiliyken büyür.
class NavTab extends StatelessWidget {
  const NavTab({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  /// Seçim vurgusunun oturduğu kare tepsinin kenarı.
  static const double tileSize = 44;

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? AppColors.primaryPressed
        : AppColors.bodyMuted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primarySoft.withValues(alpha: 0.5),
          highlightColor: Colors.transparent,
          child: Center(
            child: AnimatedScale(
              scale: selected ? 1.14 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: SizedBox.square(
                dimension: tileSize,
                child: Center(child: Icon(icon, size: 24, color: color)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
