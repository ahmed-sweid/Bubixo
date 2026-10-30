import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

/// Duolingo derinlik dili: difüz gölge yok, yalnızca "lip" (dudak) gölgesi.
///
/// Birincil butonun altında basma rengiyle ([AppColors.primaryPressed]) çizilen
/// 4px düz şerit, butona gamepad tuşu hissi verir. Basılı durumda buton lip
/// derinliği kadar aşağı kayar ve lip söner — bu davranış buton bileşenindedir.
abstract final class AppShadows {
  static const List<BoxShadow> buttonLipPrimary = [
    BoxShadow(
      offset: Offset(0, AppSizes.lipDepth),
      blurRadius: 0,
      color: AppColors.primaryPressed,
    ),
  ];

  /// Alt gezinme çubuğunu sayfanın üzerinde yüzdürür.
  static const List<BoxShadow> navBarFloat = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 30, color: Color(0x26042C60)),
  ];
}
