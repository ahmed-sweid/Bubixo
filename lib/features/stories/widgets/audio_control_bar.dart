import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/constants/stories_content.dart';
import '../../../core/design_system.dart';

/// Okuma ekranının alt ses çubuğu: hız, önceki/sonraki cümle ve oynatma.
class AudioControlBar extends StatelessWidget {
  const AudioControlBar({
    super.key,
    required this.isPlaying,
    required this.speed,
    required this.currentSentence,
    required this.sentenceCount,
    required this.canGoBack,
    required this.canGoForward,
    required this.onPrevious,
    required this.onNext,
    required this.onTogglePlayback,
    required this.onSpeedChanged,
  });

  final bool isPlaying;
  final double speed;
  final int currentSentence;
  final int sentenceCount;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTogglePlayback;
  final ValueChanged<double> onSpeedChanged;

  String get _speedLabel {
    final String value = speed == speed.roundToDouble()
        ? speed.toInt().toString()
        : speed.toString();
    return StoriesContent.speedTemplate.replaceFirst('{value}', value);
  }

  @override
  Widget build(BuildContext context) {
    final String progress = StoriesContent.readingProgressTemplate
        .replaceFirst('{current}', '$currentSentence')
        .replaceFirst('{total}', '$sentenceCount');

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 76,
            child: PopupMenuButton<double>(
              tooltip: StoriesContent.speedTooltip,
              initialValue: speed,
              onSelected: onSpeedChanged,
              itemBuilder: (_) => <PopupMenuEntry<double>>[
                for (final double option in StoriesContent.playbackSpeeds)
                  PopupMenuItem<double>(
                    value: option,
                    child: Text(
                      StoriesContent.speedTemplate.replaceFirst(
                        '{value}',
                        option == option.roundToDouble()
                            ? option.toInt().toString()
                            : option.toString(),
                      ),
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Iconsax.speedometer, size: 17),
                    const SizedBox(width: AppSpacing.xxs),
                    Flexible(
                      child: Text(
                        _speedLabel,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: StoriesContent.previousSentenceTooltip,
            onPressed: canGoBack ? onPrevious : null,
            icon: const Icon(Iconsax.previous),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: isPlaying
                  ? StoriesContent.pauseTooltip
                  : StoriesContent.playTooltip,
              onPressed: onTogglePlayback,
              color: AppColors.canvas,
              icon: Icon(isPlaying ? Iconsax.pause : Iconsax.play),
            ),
          ),
          IconButton(
            tooltip: StoriesContent.nextSentenceTooltip,
            onPressed: canGoForward ? onNext : null,
            icon: const Icon(Iconsax.next),
          ),
          SizedBox(
            width: 56,
            child: Text(
              progress,
              textAlign: TextAlign.right,
              maxLines: 1,
              softWrap: false,
              style: AppTypography.bodySm.copyWith(color: AppColors.bodyMuted),
            ),
          ),
        ],
      ),
    );
  }
}
