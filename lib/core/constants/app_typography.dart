import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Duolingo tipografi token'ları.
///
/// İki yazı tipi dialoğu (duolingo.design.md):
/// - Display: Feather Bold -> Nunito (dokümanın önerdiği tek ücretsiz ikame),
///   yalnızca w700, h1/h2 rollerinde.
/// - Gövde/UI: DIN Round -> Quicksand (dokümanın önerdiği ikame).
///
/// Ağırlık disiplini: yalnızca 500 ve 700. w400/w600 kullanmak markayı kırar.
///
/// `label*` token'ları BÜYÜK HARF etiketlerle kullanılır (0.8px letter-spacing);
/// Flutter'da otomatik text-transform olmadığından metin çağrı tarafında
/// `.toUpperCase()` ile iletilir.
abstract final class AppTypography {
  // --- Display (Nunito w700) ---
  static TextStyle get displayXl => GoogleFonts.nunito(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -1.28,
  );

  static TextStyle get displayLg => GoogleFonts.nunito(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  // --- Başlıklar (Quicksand w700) ---
  static TextStyle get headingMd => GoogleFonts.quicksand(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static TextStyle get headingSm => GoogleFonts.quicksand(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  // --- Gövde ---
  static TextStyle get bodyLg => GoogleFonts.quicksand(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.41,
  );

  static TextStyle get bodyMd => GoogleFonts.quicksand(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.47,
  );

  static TextStyle get bodySm => GoogleFonts.quicksand(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.23,
  );

  // --- Etiketler (BÜYÜK HARF, 0.8px takip) ---
  static TextStyle get labelUppercase => GoogleFonts.quicksand(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0.8,
  );

  static TextStyle get labelUppercaseSm => GoogleFonts.quicksand(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.21,
    letterSpacing: 0.8,
  );

  // --- Yardımcı roller ---
  static TextStyle get linkInline => GoogleFonts.quicksand(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    height: 1.18,
  );

  static TextStyle get caption => GoogleFonts.quicksand(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
}
