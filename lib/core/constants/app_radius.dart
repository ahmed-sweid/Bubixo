import 'package:flutter/material.dart';

/// Duolingo yarıçap ölçeği. Omurga: 16px buton yarıçapı, 8px chip/input.
abstract final class AppRadius {
  static const double none = 0;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double full = 9999;

  static final BorderRadius roundedSm = BorderRadius.circular(sm);
  static final BorderRadius roundedMd = BorderRadius.circular(md);
  static final BorderRadius roundedLg = BorderRadius.circular(lg);
}
