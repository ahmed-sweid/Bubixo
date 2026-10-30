import 'package:flutter/material.dart';

import '../../../core/constants/practice_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/practice_models.dart';
import 'practice_level_card.dart';

/// Pratik detayının hazır durum görünümü: açıklama, toplam ve seviye
/// kartları. Açılır kart seçimi yerel UI durumudur.
class PracticeDetailView extends StatefulWidget {
  const PracticeDetailView({
    super.key,
    required this.progress,
    this.onOpenItem,
  });

  final PracticeTypeProgress progress;
  final ValueChanged<PracticeItem>? onOpenItem;

  @override
  State<PracticeDetailView> createState() => _PracticeDetailViewState();
}

class _PracticeDetailViewState extends State<PracticeDetailView> {
  int? _expandedLevel;

  void _toggleLevel(int levelIndex) {
    setState(() {
      _expandedLevel = _expandedLevel == levelIndex ? null : levelIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String totalText = PracticeContent.itemCountTemplate
        .replaceFirst('{done}', '${widget.progress.completedCount}')
        .replaceFirst('{total}', '${widget.progress.totalCount}');

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  PracticeContent.typeDescriptions[widget.progress.type]!,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  totalText,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final PracticeLevelProgress level
                    in widget.progress.levels)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: PracticeLevelCard(
                      level: level,
                      expanded: _expandedLevel == level.levelIndex,
                      onToggle: () => _toggleLevel(level.levelIndex),
                      onOpenItem: widget.onOpenItem,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
