import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:en_bubixo/core/constants/level_content.dart';
import 'package:en_bubixo/core/design_system.dart';
import 'package:en_bubixo/features/level/data/models/level_models.dart';
import 'package:en_bubixo/features/level/level_chosen_screen.dart';

void main() {
  Future<void> pumpChosen(
    WidgetTester tester, {
    AppLevel? level,
    VoidCallback? onContinue,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LevelChosenScreen(level: level, onContinue: onContinue),
      ),
    );
    await tester.pump();
  }

  testWidgets('görsel, başlık ve ana sayfa butonu gösterilir', (
    WidgetTester tester,
  ) async {
    await pumpChosen(tester, level: const AppLevel(id: '3', code: 'B1', title: 'Intermediate', orderIndex: 3));

    expect(find.text(LevelContent.chosenTitle), findsOneWidget);
    expect(find.text(LevelContent.chosenCtaLabel), findsOneWidget);
    expect(
      find.text(
        LevelContent.chosenMessageTemplate.replaceFirst('{level}', 'B1'),
      ),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('seviye bilinmiyorsa genel metin kullanılır', (
    WidgetTester tester,
  ) async {
    await pumpChosen(tester);

    expect(find.text(LevelContent.chosenFallbackMessage), findsOneWidget);
  });

  testWidgets('ana sayfa butonu bağlanan eylemi çalıştırır', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await pumpChosen(tester, onContinue: () => taps++);

    await tester.tap(find.text(LevelContent.chosenCtaLabel));
    await tester.pump();

    expect(taps, 1);
  });
}
