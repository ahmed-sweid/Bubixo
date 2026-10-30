import 'package:flutter/material.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import '../common/states/app_error_view.dart';
import '../common/states/app_skeletons.dart';
import 'practice_state.dart';
import 'widgets/practice_detail_empty_view.dart';
import 'widgets/practice_detail_view.dart';

/// Pratik detayı: cubit durumuna göre yükleme, hata, boş veya seviye
/// kartlarını gösterir.
class PracticeDetailScreen extends StatelessWidget {
  const PracticeDetailScreen({
    super.key,
    required this.type,
    this.state = const PracticeDetailLoading(),
    this.onRetry,
    this.onOpenItem,
  });

  final PracticeType type;
  final PracticeDetailState state;
  final VoidCallback? onRetry;
  final ValueChanged<PracticeItem>? onOpenItem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(PracticeContent.typeTitles[type]!)),
      body: switch (state) {
        PracticeDetailLoading() => const PracticeDetailSkeleton(),
        PracticeDetailError() => AppErrorView(onRetry: onRetry),
        PracticeDetailEmpty() => const PracticeDetailEmptyView(),
        PracticeDetailReady(:final progress) => PracticeDetailView(
          progress: progress,
          onOpenItem: onOpenItem,
        ),
      },
    );
  }
}
