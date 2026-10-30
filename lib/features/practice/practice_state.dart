import 'package:flutter/foundation.dart';

import '../../core/models/practice_models.dart';

/// Pratikler sekmesinin cubit'e hazır durum modeli.
sealed class PracticeState {
  const PracticeState();
}

final class PracticeLoading extends PracticeState {
  const PracticeLoading();
}

final class PracticeError extends PracticeState {
  const PracticeError();
}

final class PracticeEmpty extends PracticeState {
  const PracticeEmpty();
}

final class PracticeReady extends PracticeState {
  const PracticeReady({required this.types});

  final List<PracticeTypeProgress> types;
}

/// Tek bir pratik türünün toplam ilerlemesi ve seviye kırılımı.
@immutable
class PracticeTypeProgress {
  const PracticeTypeProgress({
    required this.type,
    required this.completedCount,
    required this.totalCount,
    required this.levels,
  });

  final PracticeType type;
  final int completedCount;
  final int totalCount;
  final List<PracticeLevelProgress> levels;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
}

/// Bir pratik türünün tek seviyesindeki içerikler ve ilerlemesi.
@immutable
class PracticeLevelProgress {
  const PracticeLevelProgress({
    required this.levelIndex,
    required this.items,
    required this.progress,
  });

  final int levelIndex;
  final List<PracticeItem> items;
  final double progress;
}

/// Pratik detayının cubit'e hazır durum modeli.
sealed class PracticeDetailState {
  const PracticeDetailState();
}

final class PracticeDetailLoading extends PracticeDetailState {
  const PracticeDetailLoading();
}

final class PracticeDetailError extends PracticeDetailState {
  const PracticeDetailError();
}

final class PracticeDetailEmpty extends PracticeDetailState {
  const PracticeDetailEmpty();
}

final class PracticeDetailReady extends PracticeDetailState {
  const PracticeDetailReady({required this.progress});

  final PracticeTypeProgress progress;
}
