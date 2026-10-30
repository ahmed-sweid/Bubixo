import 'package:en_bubixo/features/shell/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/level_content.dart';
import '../../core/design_system.dart';
import 'level_test_screen.dart';
import 'widgets/level_select_card.dart';

/// Seviye belirleme ekranı: A1–C2 seviye kartlarından dokunarak seçim yapılır;
/// kartlar sıralı hafif bir animasyonla belirir, seçim yapılınca onay
/// butonu aktifleşir. Hareket azaltma açıksa giriş animasyonu atlanır.
class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  int? _selectedLevel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1.0;
    } else {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _selectLevel(int index) {
    HapticFeedback.selectionClick();
    setState(() => _selectedLevel = index);
  }

  void _confirmSelection() {
    // TODO(backend): seçilen seviyeyi kullanıcı profiline kaydet.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomeShell()),
    );
  }

  Future<void> _openLevelTest() async {
    final int? suggestedLevel = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (BuildContext _) => LevelTestScreen(
          onCompleted: (int levelIndex) =>
              Navigator.of(context).pop(levelIndex),
          onChooseManually: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (suggestedLevel != null && mounted) {
      setState(() => _selectedLevel = suggestedLevel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          LevelContent.title,
                          style: AppTypography.headingMd.copyWith(
                            color: AppColors.inkDisplay,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          LevelContent.subtitle,
                          style: AppTypography.bodyLg.copyWith(
                            color: AppColors.bodyMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        ...List.generate(3, (int row) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: row < 2 ? AppSpacing.base : 0,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: LevelSelectCard(
                                    index: row * 2,
                                    selectedLevel: _selectedLevel,
                                    entrance: _entrance,
                                    onSelected: _selectLevel,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.base),
                                Expanded(
                                  child: LevelSelectCard(
                                    index: row * 2 + 1,
                                    selectedLevel: _selectedLevel,
                                    entrance: _entrance,
                                    onSelected: _selectLevel,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedLevel == null
                              ? null
                              : _confirmSelection,
                          child: Text(LevelContent.chooseLabel),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _openLevelTest,
                          child: Text(LevelContent.testLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
