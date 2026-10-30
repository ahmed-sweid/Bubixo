import 'package:flutter/material.dart';

import '../../../core/design_system.dart';

/// Kategori çoklu seçimi için ortak alt sayfa.
class CategoryFilterSheet extends StatefulWidget {
  const CategoryFilterSheet({
    super.key,
    required this.title,
    required this.categories,
    required this.initialCategories,
    required this.applyLabel,
    required this.onApply,
  });

  final String title;
  final List<String> categories;
  final List<String> initialCategories;
  final String applyLabel;
  final ValueChanged<List<String>> onApply;

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late final Set<String> _selected = Set<String>.from(widget.initialCategories);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.title,
              style: AppTypography.labelUppercaseSm.copyWith(
                color: AppColors.bodyMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final String category in widget.categories)
                  FilterChip(
                    label: Text(category),
                    selected: _selected.contains(category),
                    onSelected: (bool value) => setState(() {
                      if (value) {
                        _selected.add(category);
                      } else {
                        _selected.remove(category);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => widget.onApply(_selected.toList()),
              child: Text(widget.applyLabel),
            ),
          ],
        ),
      ),
    );
  }
}
