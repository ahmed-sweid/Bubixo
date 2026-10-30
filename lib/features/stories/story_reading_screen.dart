import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/stories_content.dart';
import '../../core/design_system.dart';
import '../../core/models/story_models.dart';
import 'widgets/audio_control_bar.dart';

/// Cümle cümle okuma ekranı: aktif cümle vurgusu, sesli okuma simülasyonu ve
/// hız/ilerleme kontrolleri.
class StoryReadingScreen extends StatefulWidget {
  const StoryReadingScreen({
    super.key,
    required this.story,
    this.initialSentenceIndex = 0,
  });

  final Story story;
  final int initialSentenceIndex;

  @override
  State<StoryReadingScreen> createState() => _StoryReadingScreenState();
}

class _StoryReadingScreenState extends State<StoryReadingScreen> {
  Timer? _playbackTimer;
  late int _currentSentenceIndex;
  bool _isPlaying = false;
  double _speed = 1;

  @override
  void initState() {
    super.initState();
    _currentSentenceIndex = widget.initialSentenceIndex.clamp(
      0,
      widget.story.sentences.length - 1,
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _pausePlayback();
      return;
    }
    if (_currentSentenceIndex == widget.story.sentences.length - 1) {
      setState(() => _currentSentenceIndex = 0);
    }
    setState(() => _isPlaying = true);
    _startPlaybackTimer();
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(
      Duration(milliseconds: (2400 / _speed).round()),
      (_) => _advanceSentence(),
    );
  }

  void _pausePlayback() {
    _playbackTimer?.cancel();
    setState(() => _isPlaying = false);
  }

  void _advanceSentence() {
    if (_currentSentenceIndex >= widget.story.sentences.length - 1) {
      _playbackTimer?.cancel();
      setState(() => _isPlaying = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(StoriesContent.finishedMessage)),
        );
      return;
    }
    setState(() => _currentSentenceIndex++);
  }

  void _moveSentence(int delta) {
    final int target = _currentSentenceIndex + delta;
    if (target < 0 || target >= widget.story.sentences.length) {
      return;
    }
    setState(() => _currentSentenceIndex = target);
    if (_isPlaying) {
      _startPlaybackTimer();
    }
  }

  void _setSpeed(double speed) {
    setState(() => _speed = speed);
    if (_isPlaying) {
      _startPlaybackTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          widget.story.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: widget.story.sentences.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  final bool active = index == _currentSentenceIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primarySoft : AppColors.canvas,
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        for (final String word
                            in widget.story.sentences[index].split(' '))
                          Text(
                            word,
                            style: AppTypography.bodyLg.copyWith(
                              fontSize: 19,
                              height: 1.5,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.body,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            AudioControlBar(
              isPlaying: _isPlaying,
              speed: _speed,
              currentSentence: _currentSentenceIndex + 1,
              sentenceCount: widget.story.sentences.length,
              canGoBack: _currentSentenceIndex > 0,
              canGoForward:
                  _currentSentenceIndex < widget.story.sentences.length - 1,
              onPrevious: () => _moveSentence(-1),
              onNext: () => _moveSentence(1),
              onTogglePlayback: _togglePlayback,
              onSpeedChanged: _setSpeed,
            ),
          ],
        ),
      ),
    );
  }
}
