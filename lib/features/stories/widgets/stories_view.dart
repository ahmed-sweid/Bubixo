import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/nav_content.dart';
import '../../../core/constants/stories_content.dart';
import '../../../core/constants/state_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/story_models.dart';
import '../../common/states/app_empty_view.dart';
import '../../common/widgets/category_filter_sheet.dart';
import '../../common/widgets/level_chip.dart';
import 'continue_story_card.dart';
import 'story_card.dart';

/// Hikâyeler sekmesinin hazır durum görünümü: arama, seviye/kategori
/// filtreleri, devam kartı ve hikâye ızgarası.
class StoriesView extends StatefulWidget {
  const StoriesView({
    super.key,
    required this.stories,
    required this.categories,
    this.continueStory,
  });

  final List<Story> stories;
  final List<String> categories;
  final Story? continueStory;

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  final TextEditingController _searchController = TextEditingController();
  int _levelIndex = -1;
  List<String> _categories = <String>[];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Story> get _results {
    final String query = _searchController.text.trim().toLowerCase();
    return widget.stories
        .where(
          (Story story) =>
              (_levelIndex < 0 || story.levelIndex == _levelIndex) &&
              (_categories.isEmpty || _categories.contains(story.category)) &&
              (query.isEmpty ||
                  story.title.toLowerCase().contains(query) ||
                  story.category.toLowerCase().contains(query)),
        )
        .toList(growable: false);
  }

  bool get _isFiltering =>
      _levelIndex >= 0 ||
      _categories.isNotEmpty ||
      _searchController.text.trim().isNotEmpty;

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => CategoryFilterSheet(
        title: StoriesContent.categoriesLabel,
        categories: widget.categories,
        initialCategories: _categories,
        applyLabel: StoriesContent.applyFiltersLabel,
        onApply: (List<String> categories) {
          Navigator.of(sheetContext).pop();
          setState(() => _categories = categories);
        },
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _levelIndex = -1;
      _categories = <String>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Story> results = _results;
    final Story? continueStory = widget.continueStory;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        NavContent.storiesTitle,
                        style: AppTypography.headingMd.copyWith(
                          color: AppColors.inkDisplay,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        NavContent.storiesDescription,
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
                delegate: _FilterHeaderDelegate(
                  height: 108,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (_) => setState(() {}),
                                textInputAction: TextInputAction.search,
                                decoration: const InputDecoration(
                                  hintText: StoriesContent.searchHint,
                                  prefixIcon: Icon(
                                    Iconsax.search_normal,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: StoriesContent.filterTooltip,
                              onPressed: _showFilterSheet,
                              icon: Icon(
                                _categories.isEmpty
                                    ? Iconsax.filter
                                    : Iconsax.filter_tick,
                                size: 22,
                                color: _categories.isEmpty
                                    ? AppColors.body
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            itemCount: LevelContent.cefrLevels.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.xs),
                            itemBuilder: (BuildContext context, int index) {
                              final bool selected = _levelIndex == index;
                              return LevelChip(
                                label: LevelContent.cefrLevels[index],
                                selected: selected,
                                onTap: () => setState(
                                  () => _levelIndex = selected ? -1 : index,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (continueStory != null && !_isFiltering) ...<Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      StoriesContent.continueSectionLabel,
                      style: AppTypography.labelUppercaseSm.copyWith(
                        color: AppColors.bodyMuted,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: ContinueStoryCard(story: continueStory),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Text(
                    StoriesContent.allStoriesLabel,
                    style: AppTypography.labelUppercaseSm.copyWith(
                      color: AppColors.bodyMuted,
                    ),
                  ),
                ),
              ),
              if (results.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: SingleChildScrollView(
                      child: AppEmptyView(
                        imageAsset: StateContent.searchEmptyImageAsset,
                        title: StateContent.searchEmptyTitle,
                        message: StateContent.searchEmptyMessage,
                        actionLabel: StateContent.clearFiltersLabel,
                        onAction: _clearFilters,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.72,
                        ),
                    delegate: SliverChildBuilderDelegate((
                      BuildContext context,
                      int index,
                    ) {
                      final Story story = results[index];
                      return StoryCard(story: story);
                    }, childCount: results.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: ColoredBox(color: AppColors.canvas, child: child),
    );
  }

  @override
  bool shouldRebuild(_FilterHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
