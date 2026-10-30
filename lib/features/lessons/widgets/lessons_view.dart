import 'package:flutter/material.dart';

import '../../../core/constants/nav_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/lesson_models.dart';
import 'lessons_level_card.dart';
import 'lessons_tabs_header_delegate.dart';
import 'track_tabs.dart';

/// Dersler sekmesinin hazır durum görünümü: başlık, track sekmeleri ve
/// seviye kartları. Sekme ve açılır kart seçimi yerel UI durumudur.
class LessonsView extends StatefulWidget {
  const LessonsView({
    super.key,
    required this.levels,
    this.onOpenLesson,
    this.onOpenLevelTest,
  });

  final List<LessonLevel> levels;
  final ValueChanged<Lesson>? onOpenLesson;
  final ValueChanged<int>? onOpenLevelTest;

  @override
  State<LessonsView> createState() => _LessonsViewState();
}

class _LessonsViewState extends State<LessonsView> {
  LessonTrack _track = LessonTrack.grammar;
  int? _expandedLevel;

  void _selectTrack(LessonTrack track) {
    setState(() {
      _track = track;
      _expandedLevel = null;
    });
  }

  void _toggleLevel(int levelIndex) {
    setState(() {
      _expandedLevel = _expandedLevel == levelIndex ? null : levelIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        NavContent.lessonsTitle,
                        style: AppTypography.headingMd.copyWith(
                          color: AppColors.inkDisplay,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        NavContent.lessonsDescription,
                        style: AppTypography.bodyLg.copyWith(
                          color: AppColors.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: LessonsTabsHeaderDelegate(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: TrackTabs(selected: _track, onChanged: _selectTrack),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                sliver: SliverList.separated(
                  itemCount: widget.levels.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (BuildContext context, int index) {
                    final LessonLevel level = widget.levels[index];
                    return LessonsLevelCard(
                      level: level,
                      track: _track,
                      expanded: _expandedLevel == level.levelIndex,
                      onToggle: () => _toggleLevel(level.levelIndex),
                      onOpenLesson: widget.onOpenLesson,
                      onOpenLevelTest: widget.onOpenLevelTest == null
                          ? null
                          : () => widget.onOpenLevelTest!(level.levelIndex),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
