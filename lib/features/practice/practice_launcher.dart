import 'package:flutter/material.dart';

import '../../core/models/practice_models.dart';
import 'practice_result_screen.dart';

/// Oturum bittiğinde sonuç sayfasını açar; sonuç, oturumun üzerine yazılır.
/// [retryBuilder] aynı içerikle yeni bir oturum kurar.
void openPracticeResult(
  BuildContext context,
  PracticeType type, {
  required int total,
  required int correct,
  required WidgetBuilder retryBuilder,
}) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => PracticeResultScreen(
        type: type,
        total: total,
        correct: correct,
        wrong: total - correct,
        retryBuilder: retryBuilder,
      ),
    ),
  );
}
