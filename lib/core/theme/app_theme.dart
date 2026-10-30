import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';
import 'app_text_theme.dart';

/// Duolingo tasarım sistemi — Material 3 ışık teması.
///
/// Kaynak doküman yalnızca açık yüzeyi tanımlar (dark mode token'ları
/// belgelenmemiş); bu yüzden sistem yalnızca [light] sağlar ve kanvas
/// merdiveni yoktur: tüm yüzeyler beyazdır, griler yalnızca token
/// düzeyinde (hairline, surfaceHover) bileşenlere verilir.
abstract final class AppTheme {
  static const ColorScheme _scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.canvas,
    primaryContainer: AppColors.primarySoft,
    onPrimaryContainer: AppColors.primaryPressed,
    secondary: AppColors.accentMacaw,
    onSecondary: AppColors.canvas,
    secondaryContainer: AppColors.canvas,
    onSecondaryContainer: AppColors.accentMacaw,
    tertiary: AppColors.accentBee,
    onTertiary: AppColors.inkDisplay,
    error: AppColors.accentCardinal,
    onError: AppColors.canvas,
    surface: AppColors.canvas,
    onSurface: AppColors.body,
    onSurfaceVariant: AppColors.bodyMuted,
    surfaceContainerLowest: AppColors.canvas,
    surfaceContainerLow: AppColors.canvas,
    surfaceContainer: AppColors.canvas,
    surfaceContainerHigh: AppColors.canvas,
    surfaceContainerHighest: AppColors.canvas,
    inverseSurface: AppColors.body,
    onInverseSurface: AppColors.canvas,
    inversePrimary: AppColors.primarySoft,
    outline: AppColors.bodySoft,
    outlineVariant: AppColors.hairline,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: _scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    canvasColor: AppColors.canvas,
    textTheme: appTextTheme,
    iconTheme: const IconThemeData(size: 24, color: AppColors.body),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primaryMint,
      selectionHandleColor: AppColors.primary,
    ),
    appBarTheme: AppBarThemeData(
      backgroundColor: AppColors.canvas,
      foregroundColor: AppColors.body,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      toolbarHeight: AppSizes.topNavHeight,
      titleTextStyle: AppTypography.bodyMd.copyWith(color: AppColors.body),
      iconTheme: const IconThemeData(color: AppColors.body),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _primaryButton),
    outlinedButtonTheme: OutlinedButtonThemeData(style: _secondaryButton),
    textButtonTheme: TextButtonThemeData(style: _textButton),
    inputDecorationTheme: _input,
    chipTheme: _chip,
    dividerTheme: const DividerThemeData(
      color: AppColors.hairline,
      thickness: AppSizes.hairlineWidth,
      space: AppSizes.hairlineWidth,
    ),
    dialogTheme: _dialog,
    snackBarTheme: _snackBar,
    bottomSheetTheme: _bottomSheet,
    tabBarTheme: _tabBar,
    switchTheme: _switch,
    checkboxTheme: _checkbox,
    radioTheme: _radio,
    progressIndicatorTheme: _progress,
    floatingActionButtonTheme: _fab,
    navigationBarTheme: _navigationBar,
    listTileTheme: _listTile,
    popupMenuTheme: _popupMenu,
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.accentCardinal,
      textColor: AppColors.canvas,
    ),
  );

  // --- Butonlar -----------------------------------------------------------
  // Birincil: owl green dolgu, BÜYÜK HARF beyaz etiket, 16px yarıçap, 50px.
  // Lip gölgesi ve basılı düşme hareketi buton bileşenindedir
  // (AppShadows.buttonLipPrimary).
  static ButtonStyle get _primaryButton => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AppColors.hairline
          : states.contains(WidgetState.pressed)
          ? AppColors.primaryPressed
          : AppColors.primary,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AppColors.bodySoft
          : AppColors.canvas,
    ),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(AppTypography.labelUppercase),
    minimumSize: const WidgetStatePropertyAll(Size(0, AppSizes.buttonHeight)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: AppSizes.buttonVPadding,
        horizontal: AppSizes.buttonHPadding,
      ),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
    ),
  );

  // İkincil: beyaz dolgu, macaw metin, 2px bodySoft kontur — asla ikinci bir
  // doygun dolgu rengi değildir.
  static ButtonStyle get _secondaryButton => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.focused)
          ? AppColors.surfaceHover
          : AppColors.canvas,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AppColors.bodySoft
          : AppColors.accentMacaw,
    ),
    side: const WidgetStatePropertyAll(
      BorderSide(color: AppColors.bodySoft, width: AppSizes.borderWidth),
    ),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(AppTypography.labelUppercase),
    minimumSize: const WidgetStatePropertyAll(Size(0, AppSizes.buttonHeight)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: AppSizes.buttonVPadding,
        horizontal: AppSizes.buttonHPadding,
      ),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
    ),
  );

  // Marka butonu: dokümanın app-store-button söz dağarcığı — beyaz dolgu,
  // body mürekkebi, 2px hairline kontur; etkileşimde surfaceHover. İkon,
  // kromla aynı sistemden gelmez (marka işareti gerçek rengiyle gösterilir).
  static ButtonStyle get googleButton => ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.focused)
          ? AppColors.surfaceHover
          : AppColors.canvas,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled)
          ? AppColors.bodySoft
          : AppColors.body,
    ),
    side: const WidgetStatePropertyAll(
      BorderSide(color: AppColors.hairline, width: AppSizes.borderWidth),
    ),
    elevation: const WidgetStatePropertyAll(0),
    textStyle: WidgetStatePropertyAll(AppTypography.labelUppercase),
    minimumSize: const WidgetStatePropertyAll(Size(0, AppSizes.buttonHeight)),
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(
        vertical: AppSizes.buttonVPadding,
        horizontal: AppSizes.buttonHPadding,
      ),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
    ),
  );

  static ButtonStyle get _textButton => TextButton.styleFrom(
    foregroundColor: AppColors.accentMacaw,
    disabledForegroundColor: AppColors.bodySoft,
    textStyle: AppTypography.labelUppercase,
    minimumSize: const Size(0, AppSizes.buttonHeight),
    padding: const EdgeInsets.symmetric(
      vertical: AppSizes.buttonVPadding,
      horizontal: AppSizes.buttonHPadding,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
  );

  // --- Girdi ---------------------------------------------------------------
  // 48px, 8px yarıçap, 2px hairline kontur; odakta macaw, hatada cardinal.
  static InputDecorationThemeData get _input => InputDecorationThemeData(
    filled: true,
    fillColor: AppColors.canvas,
    constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
    contentPadding: const EdgeInsets.symmetric(
      vertical: AppSizes.inputVPadding,
      horizontal: AppSizes.inputHPadding,
    ),
    hintStyle: AppTypography.bodyLg.copyWith(color: AppColors.bodySoft),
    helperStyle: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
    errorStyle: AppTypography.caption.copyWith(color: AppColors.accentCardinal),
    suffixIconColor: AppColors.bodyMuted,
    border: _inputBorder(AppColors.hairline),
    enabledBorder: _inputBorder(AppColors.hairline),
    focusedBorder: _inputBorder(AppColors.accentMacaw),
    errorBorder: _inputBorder(AppColors.accentCardinal),
    focusedErrorBorder: _inputBorder(AppColors.accentCardinal),
  );

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: AppRadius.roundedSm,
    borderSide: BorderSide(color: color, width: AppSizes.borderWidth),
  );

  // --- Çipler ---------------------------------------------------------------
  // Seçili çip zemini primarySoft; seçili metin rengi (primaryPressed) çip
  // bileşeninde labelStyle ile verilir.
  static ChipThemeData get _chip => ChipThemeData(
    backgroundColor: Colors.transparent,
    selectedColor: AppColors.primarySoft,
    checkmarkColor: AppColors.primaryPressed,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
    padding: const EdgeInsets.symmetric(
      vertical: AppSizes.chipVPadding,
      horizontal: AppSizes.chipHPadding,
    ),
    labelStyle: AppTypography.bodySm.copyWith(color: AppColors.bodyMuted),
  );

  // --- Diğer bileşenler -----------------------------------------------------
  static DialogThemeData get _dialog => DialogThemeData(
    backgroundColor: AppColors.canvas,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
    titleTextStyle: AppTypography.headingSm.copyWith(
      color: AppColors.bodyStrong,
    ),
    contentTextStyle: AppTypography.bodyLg.copyWith(color: AppColors.bodyMuted),
  );

  static SnackBarThemeData get _snackBar => SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.body,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
    contentTextStyle: AppTypography.bodyLg.copyWith(color: AppColors.canvas),
    actionTextColor: AppColors.accentMacaw,
  );

  static BottomSheetThemeData get _bottomSheet => BottomSheetThemeData(
    backgroundColor: AppColors.canvas,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    modalElevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    dragHandleColor: AppColors.hairline,
  );

  static TabBarThemeData get _tabBar => TabBarThemeData(
    labelColor: AppColors.body,
    unselectedLabelColor: AppColors.bodyMuted,
    labelStyle: AppTypography.bodyMd,
    unselectedLabelStyle: AppTypography.bodyMd,
    indicatorColor: AppColors.primary,
    dividerColor: AppColors.hairline,
    indicatorSize: TabBarIndicatorSize.label,
  );

  static SwitchThemeData get _switch => SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(AppColors.canvas),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primary
          : AppColors.hairline,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.transparent
          : AppColors.bodySoft,
    ),
  );

  static CheckboxThemeData get _checkbox => CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primary
          : Colors.transparent,
    ),
    checkColor: const WidgetStatePropertyAll(AppColors.canvas),
    side: const BorderSide(
      color: AppColors.bodySoft,
      width: AppSizes.borderWidth,
    ),
  );

  static RadioThemeData get _radio => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.primary
          : AppColors.bodySoft,
    ),
  );

  static ProgressIndicatorThemeData get _progress => ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.hairline,
    circularTrackColor: AppColors.hairline,
    refreshBackgroundColor: AppColors.canvas,
  );

  static FloatingActionButtonThemeData get _fab =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.canvas,
        elevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
      );

  static NavigationBarThemeData get _navigationBar => NavigationBarThemeData(
    backgroundColor: AppColors.canvas,
    surfaceTintColor: Colors.transparent,
    indicatorColor: AppColors.primarySoft,
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.bodySoft,
      ),
    ),
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => AppTypography.bodySm.copyWith(
        color: states.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.bodyMuted,
      ),
    ),
  );

  static ListTileThemeData get _listTile => ListTileThemeData(
    iconColor: AppColors.bodyMuted,
    titleTextStyle: AppTypography.bodyLg.copyWith(color: AppColors.body),
    subtitleTextStyle: AppTypography.caption.copyWith(
      color: AppColors.bodyMuted,
    ),
  );

  static PopupMenuThemeData get _popupMenu => PopupMenuThemeData(
    color: AppColors.canvas,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
    textStyle: AppTypography.bodyLg.copyWith(color: AppColors.body),
  );
}
