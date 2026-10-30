import 'package:flutter/foundation.dart';

/// Seviye belirleme testi sorusu.
@immutable
class LevelTestQuestion {
  const LevelTestQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}
