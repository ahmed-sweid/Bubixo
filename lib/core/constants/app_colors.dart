import 'package:flutter/material.dart';

/// Duolingo tasarım sistemi renk token'ları (duolingo.design.md v alpha).
///
/// Sistem kuralları:
/// - [primary] yalnızca birincil CTA dolgusu ve marka vurgusudur; gövde metni
///   veya geniş zemin dolgusu olarak asla kullanılmaz.
/// - [primaryMint] yalnızca metin ve kenarlık rengidir; zemin olarak kullanılmaz.
/// - İkincil eylem rengi asla ikinci bir doygun dolgu değildir: beyaz zemin +
///   [accentMacaw] metinli kontur buton.
abstract final class AppColors {
  // --- Marka voltajı: baykuş yeşili ailesi ---
  static const Color primary = Color(0xFF58CC02); // owl
  static const Color primaryPressed = Color(0xFF58A700); // tree frog
  static const Color primarySoft = Color(0xFFD7FFB8); // sea sponge soft
  static const Color primaryMint = Color(0xFFA5ED6E); // sea sponge

  // --- Display mürekkepleri ---
  static const Color inkDisplay = Color(0xFF042C60); // lacivert hero
  static const Color inkDisplayDeep = Color(0xFF100F3E); // deep starling
  static const Color inkDisplayBlue = Color(0xFF000437); // eclipse

  // --- Gövde grileri ---
  static const Color body = Color(0xFF3C3C3C); // black-text
  static const Color bodyStrong = Color(0xFF4B4B4B); // eel
  static const Color bodyMuted = Color(0xFF777777); // wolf
  static const Color bodySoft = Color(0xFFAFAFAF); // hare

  // --- Yüzeyler ---
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF7F7F7);
  static const Color hairline = Color(0xFFE5E5E5);

  // --- Bağlantı ---
  static const Color link = Color(0xFF0000EE);
  static const Color linkInk = Color(0xFF000000);

  // --- Hayvan vurguları ---
  static const Color accentMacaw = Color(0xFF1CB0F6); // ikincil eylem
  static const Color accentCardinal = Color(0xFFFF4B4B); // hata / kalp kaybı
  static const Color accentFox = Color(0xFFFF9600); // streak alevi
  static const Color accentBee = Color(0xFFFFC800); // altın lig / madalya
  static const Color accentBeetle = Color(0xFFCE82FF); // super / elmas lig
}
