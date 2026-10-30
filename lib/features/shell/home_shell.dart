import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/nav_content.dart';
import '../../core/design_system.dart';
import '../lessons/lessons_screen.dart';
import '../practice/practice_screen.dart';
import '../profile/profile_screen.dart';
import '../stories/stories_screen.dart';
import '../words/words_screen.dart';
import 'widgets/nav_tab.dart';

/// Ana uygulama iskeleti: alt gezinme çubuğuyla beş sekmeyi taşıyan ekran.
/// Sekmeler [IndexedStack] ile tutulur; geçişlerde sekme durumu korunur.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const double _barHeight = 60;
  static const Duration _motion = Duration(milliseconds: 260);

  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    LessonsScreen(),
    StoriesScreen(),
    WordsScreen(),
    PracticeScreen(),
    ProfileScreen(),
  ];

  static const List<({String label, IconData icon})> _tabSpecs = [
    (label: NavContent.lessonsLabel, icon: Iconsax.book),
    (label: NavContent.storiesLabel, icon: Iconsax.story),
    (label: NavContent.wordsLabel, icon: Iconsax.element_3),
    (label: NavContent.practiceLabel, icon: Iconsax.edit_2),
    (label: NavContent.profileLabel, icon: Iconsax.user),
  ];

  void _selectTab(int index) {
    if (index == _currentIndex) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          0,
          AppSpacing.base,
          AppSpacing.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedLg,
            boxShadow: AppShadows.navBarFloat,
          ),
          child: Material(
            color: AppColors.canvas,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.roundedLg,
              side: const BorderSide(
                color: AppColors.hairline,
                width: AppSizes.borderWidth,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: SizedBox(
                height: _barHeight,
                child: Stack(
                  children: <Widget>[
                    AnimatedAlign(
                      duration: _motion,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment(
                        -1 + 2 * _currentIndex / (_tabSpecs.length - 1),
                        0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1 / _tabSpecs.length,
                        heightFactor: 1,
                        child: Center(
                          child: SizedBox.square(
                            dimension: NavTab.tileSize,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: AppRadius.roundedMd,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(_tabSpecs.length, (int index) {
                        return NavTab(
                          key: ValueKey<String>(
                            'nav-${_tabSpecs[index].label}',
                          ),
                          label: _tabSpecs[index].label,
                          icon: _tabSpecs[index].icon,
                          selected: _currentIndex == index,
                          onTap: () => _selectTab(index),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
