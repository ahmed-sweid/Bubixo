import 'package:flutter/material.dart';

import '../../../core/design_system.dart';
import 'app_shimmer.dart';

/// Sayfa iskeletlerinin ortak çerçevesi: güvenli alan, genişlik sınırı,
/// shimmer zemini ve kaydırılamayan liste.
class _SkeletonFrame extends StatelessWidget {
  const _SkeletonFrame({
    required this.children,
    this.maxWidth,
    this.safeArea = true,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.lg,
      AppSpacing.lg,
    ),
  });

  final List<Widget> children;
  final double? maxWidth;
  final bool safeArea;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget content = AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        children: children,
      ),
    );
    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }
    if (!safeArea) {
      return Center(child: content);
    }
    return SafeArea(child: Center(child: content));
  }
}

Widget _card(double height) =>
    SkeletonBox(height: height, radius: AppRadius.lg);

/// Dersler: başlık, sekme çubuğu ve seviye kartları.
class LessonsSkeleton extends StatelessWidget {
  const LessonsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 480,
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.35, height: 24),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(widthFactor: 0.75),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonBox(height: 48, radius: AppRadius.lg),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _card(92),
          ),
      ],
    );
  }
}

/// Hikâyeler: arama, seviye çipleri ve hikâye kartları ızgarası.
class StoriesSkeleton extends StatelessWidget {
  const StoriesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 520,
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.4, height: 24),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(widthFactor: 0.85),
        const SizedBox(height: AppSpacing.md),
        const SkeletonBox(height: 48, radius: AppRadius.lg),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            for (final double width in <double>[48, 56, 64, 52])
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: SkeletonBox(
                  width: width,
                  height: 32,
                  radius: AppRadius.full,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLine(widthFactor: 0.3),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(child: _card(220)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _card(220)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Kelimeler: istatistik kartı, çeviri kartı ve önerilen kelimeler.
class WordsSkeleton extends StatelessWidget {
  const WordsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 480,
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.4, height: 24),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(widthFactor: 0.8),
        const SizedBox(height: AppSpacing.md),
        _card(128),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLine(widthFactor: 0.3),
        const SizedBox(height: AppSpacing.md),
        _card(190),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLine(widthFactor: 0.35),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _card(56),
          ),
      ],
    );
  }
}

/// Pratikler: başlık ve pratik türü kartları.
class PracticeSkeleton extends StatelessWidget {
  const PracticeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 520,
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.35, height: 24),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(widthFactor: 0.8),
        const SizedBox(height: AppSpacing.lg),
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _card(132),
          ),
      ],
    );
  }
}

/// Seviye testi: ilerleme, soru ve seçenekler.
class LevelTestSkeleton extends StatelessWidget {
  const LevelTestSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 480,
      safeArea: false,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.25),
        const SizedBox(height: AppSpacing.xl),
        const SkeletonLine(widthFactor: 0.7, height: 24),
        const SizedBox(height: AppSpacing.lg),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.base),
            child: _card(56),
          ),
        const SizedBox(height: AppSpacing.xl),
        _card(52),
      ],
    );
  }
}

/// Profil: başlık, kimlik kartı, seviye ve ayar grupları.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 480,
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.35, height: 24),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(widthFactor: 0.8),
        const SizedBox(height: AppSpacing.lg),
        _card(88),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLine(widthFactor: 0.28),
        const SizedBox(height: AppSpacing.md),
        _card(150),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLine(widthFactor: 0.32),
        const SizedBox(height: AppSpacing.md),
        _card(240),
        const SizedBox(height: AppSpacing.lg),
        const SkeletonLine(widthFactor: 0.3),
        const SizedBox(height: AppSpacing.md),
        _card(168),
      ],
    );
  }
}

/// Pratik detayı: açıklama ve seviye kartları.
class PracticeDetailSkeleton extends StatelessWidget {
  const PracticeDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      maxWidth: 480,
      safeArea: false,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      children: <Widget>[
        const SkeletonLine(widthFactor: 0.8),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(widthFactor: 0.3),
        const SizedBox(height: AppSpacing.lg),
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _card(92),
          ),
      ],
    );
  }
}

/// Kelime Keşfet: arama, filtre çipleri ve kelime ızgarası.
class DiscoverSkeleton extends StatelessWidget {
  const DiscoverSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonFrame(
      safeArea: false,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      children: <Widget>[
        const SkeletonBox(height: 48, radius: AppRadius.lg),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            for (final double width in <double>[48, 56, 64, 52])
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: SkeletonBox(
                  width: width,
                  height: 32,
                  radius: AppRadius.full,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Expanded(child: _card(112)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _card(112)),
              ],
            ),
          ),
      ],
    );
  }
}
