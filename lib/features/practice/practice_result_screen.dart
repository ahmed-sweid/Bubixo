import 'package:flutter/material.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import 'widgets/practice_result_view.dart';

/// Bütün pratik türlerinin ortak sonuç sayfası. Tekrar, oturumu aynı
/// içerikle yeniden kuran [retryBuilder] üzerinden yapılır.
class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({
    super.key,
    required this.type,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.retryBuilder,
  });

  final PracticeType type;
  final int total;
  final int correct;
  final int wrong;
  final WidgetBuilder retryBuilder;

  void _retry(BuildContext context) {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: retryBuilder));
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text(PracticeContent.resultTitle)),
      body: PracticeResultView(
        type: type,
        total: total,
        correct: correct,
        wrong: wrong,
        onRetry: () => _retry(context),
        onGoHome: () => _goHome(context),
      ),
    );
  }
}
