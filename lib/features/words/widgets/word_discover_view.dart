import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/level_content.dart';
import '../../../core/constants/state_content.dart';
import '../../../core/constants/words_content.dart';
import '../../../core/design_system.dart';
import '../../../core/models/word_models.dart';
import '../../common/states/app_empty_view.dart';
import '../../common/widgets/category_filter_sheet.dart';
import '../../common/widgets/level_chip.dart';

/// Kelime Keşfet sayfasının hazır durum görünümü: arama, filtreler, iki
/// sütunlu kelime havuzu ve seçim çubuğu.
class WordDiscoverView extends StatefulWidget {
  const WordDiscoverView({
    super.key,
    required this.words,
    required this.categories,
  });

  final List<PoolWord> words;
  final List<String> categories;

  @override
  State<WordDiscoverView> createState() => _WordDiscoverViewState();
}

class _WordDiscoverViewState extends State<WordDiscoverView> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = <String>{};
  int _levelIndex = -1;
  List<String> _categories = <String>[];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PoolWord> get _results {
    final String query = _searchController.text.trim().toLowerCase();
    return widget.words
        .where(
          (PoolWord word) =>
              (_levelIndex < 0 || word.levelIndex == _levelIndex) &&
              (_categories.isEmpty || _categories.contains(word.category)) &&
              (query.isEmpty ||
                  word.term.toLowerCase().contains(query) ||
                  word.translation.toLowerCase().contains(query)),
        )
        .toList(growable: false);
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => CategoryFilterSheet(
        title: WordsContent.filterSectionLabel,
        categories: widget.categories,
        initialCategories: _categories,
        applyLabel: WordsContent.applyFiltersLabel,
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
    final List<PoolWord> results = _results;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            0,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: WordsContent.discoverSearchHint,
                    prefixIcon: Icon(Iconsax.search_normal, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                tooltip: WordsContent.discoverFilterTooltip,
                onPressed: _showFilterSheet,
                icon: const Icon(Iconsax.filter, size: 22),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            itemCount: LevelContent.cefrLevels.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
            itemBuilder: (BuildContext context, int index) {
              final bool selected = _levelIndex == index;
              return LevelChip(
                label: LevelContent.cefrLevels[index],
                selected: selected,
                onTap: () =>
                    setState(() => _levelIndex = selected ? -1 : index),
              );
            },
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: SingleChildScrollView(
                    child: AppEmptyView(
                      imageAsset: StateContent.searchEmptyImageAsset,
                      title: StateContent.searchEmptyTitle,
                      message: StateContent.searchEmptyMessage,
                      actionLabel: StateContent.clearFiltersLabel,
                      onAction: _clearFilters,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: results.length,
                  itemBuilder: (BuildContext context, int index) {
                    final PoolWord word = results[index];
                    return _PoolWordCard(
                      word: word,
                      selected: _selectedIds.contains(word.id),
                      onToggle: () => setState(() {
                        if (!_selectedIds.add(word.id)) {
                          _selectedIds.remove(word.id);
                        }
                      }),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.hairline)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  WordsContent.selectedCountTemplate.replaceFirst(
                    '{count}',
                    '${_selectedIds.length}',
                  ),
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: null,
                child: const Text(WordsContent.addSelectedCtaLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PoolWordCard extends StatelessWidget {
  const _PoolWordCard({
    required this.word,
    required this.selected,
    required this.onToggle,
  });

  final PoolWord word;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: AppRadius.roundedLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.canvas,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.hairline,
            width: AppSizes.borderWidth,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    word.term,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.inkDisplay,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  selected ? Iconsax.tick_circle : Iconsax.add_circle,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.bodyMuted,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Expanded(
              child: Text(
                word.translation,
                style: AppTypography.caption.copyWith(
                  color: AppColors.bodyMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Text(
                LevelContent.cefrLevels[word.levelIndex],
                style: AppTypography.caption.copyWith(
                  color: AppColors.accentMacaw,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
