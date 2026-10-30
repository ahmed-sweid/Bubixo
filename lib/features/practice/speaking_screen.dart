import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/constants/practice_content.dart';
import '../../core/design_system.dart';
import '../../core/models/practice_models.dart';
import 'practice_launcher.dart';
import 'widgets/practice_session_frame.dart';

/// 7.5 — Konuşma pratiği.
///
/// Mikrofon kaydı şimdilik simülasyondur; gerçek kayıt ve telaffuz
/// değerlendirmesi backend'e bağlanacak.
/// TODO(backend): kayıt izni, ses yükleme ve değerlendirme sonucu.
class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key, required this.prompts});

  final List<SpeakingPrompt> prompts;

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  static const PracticeType _type = PracticeType.speaking;

  List<SpeakingPrompt> get _prompts => widget.prompts;

  int _index = 0;
  bool _recording = false;
  bool _recorded = false;
  bool _scored = false;
  int _completedCount = 0;

  SpeakingPrompt get _prompt => _prompts[_index];

  bool get _isLast => _index == _prompts.length - 1;

  void _toggleRecording() {
    setState(() {
      if (_recording) {
        _recording = false;
        _recorded = true;
        if (!_scored) {
          _completedCount++;
          _scored = true;
        }
      } else {
        _recording = true;
      }
    });
  }

  void _retry() {
    setState(() {
      _recorded = false;
      _recording = false;
    });
  }

  void _advance() {
    if (_isLast) {
      openPracticeResult(
        context,
        _type,
        total: _prompts.length,
        correct: _completedCount,
        retryBuilder: (_) => SpeakingScreen(prompts: _prompts),
      );
      return;
    }
    setState(() {
      _index++;
      _recording = false;
      _recorded = false;
      _scored = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PracticeSessionFrame(
      type: _type,
      index: _index,
      total: _prompts.length,
      footer: _buildFooter(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            PracticeContent.speakingInstruction,
            style: AppTypography.caption.copyWith(color: AppColors.bodyMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(
                color: AppColors.hairline,
                width: AppSizes.borderWidth,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  PracticeContent.speakingTaskLabel,
                  style: AppTypography.labelUppercaseSm.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _prompt.task,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.inkDisplay,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  PracticeContent.speakingPhraseLabel,
                  style: AppTypography.labelUppercaseSm.copyWith(
                    color: AppColors.bodyMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _prompt.phrase,
                  style: AppTypography.headingSm.copyWith(
                    color: AppColors.inkDisplay,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: _toggleRecording,
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _recording
                          ? AppColors.accentCardinal
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _recording ? Iconsax.stop : Iconsax.microphone_2,
                      size: 36,
                      color: AppColors.canvas,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  _recording
                      ? PracticeContent.recordingLabel
                      : _recorded
                      ? PracticeContent.recordedLabel
                      : '',
                  style: AppTypography.caption.copyWith(
                    color: _recording
                        ? AppColors.accentCardinal
                        : AppColors.bodyMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_recorded) ...<Widget>[
          const PracticeFeedbackBanner(
            correct: true,
            message: PracticeContent.recordedMessage,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: _retry,
            child: const Text(PracticeContent.retryLabel),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ElevatedButton(
          onPressed: _recorded ? _advance : _toggleRecording,
          child: Text(
            _recorded
                ? _isLast
                      ? PracticeContent.finishCtaLabel
                      : PracticeContent.nextCtaLabel
                : _recording
                ? PracticeContent.recordStopLabel
                : PracticeContent.recordStartLabel,
          ),
        ),
      ],
    );
  }
}
