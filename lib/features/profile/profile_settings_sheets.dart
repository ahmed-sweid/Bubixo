import 'package:flutter/material.dart';

import '../../core/constants/profile_content.dart';
import '../../core/design_system.dart';
import '../../core/models/profile_models.dart';
import 'widgets/choice_tile.dart';
import 'widgets/settings_sheet.dart';
import 'widgets/speed_chips.dart';
import 'widgets/switch_tile.dart';

/// Profil ayar sheet'leri.
///
/// Her sheet seçili değeri dışarıdan alır ve değişikliği callback ile
/// bildirir; kalıcılığı cubit üstlenir. Sheet yalnızca kendi geçici
/// seçimini tutar, böylece dokunuş anında görünüm canlı kalır.
Future<void> _openSheet(BuildContext context, Widget sheet) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext _) => sheet,
  );
}

Future<void> showLanguageSheet(
  BuildContext context, {
  required AppLanguage selected,
  required ValueChanged<AppLanguage> onChanged,
}) {
  return _openSheet(
    context,
    _LocalValue<AppLanguage>(
      initial: selected,
      builder:
          (
            BuildContext context,
            AppLanguage value,
            ValueChanged<AppLanguage> update,
          ) => SettingsSheet(
            title: ProfileContent.languageSheetTitle,
            children: <Widget>[
              for (final AppLanguage language in AppLanguage.values)
                ChoiceTile(
                  label: ProfileContent.languageLabels[language]!,
                  selected: value == language,
                  onTap: () {
                    update(language);
                    onChanged(language);
                  },
                ),
            ],
          ),
    ),
  );
}

Future<void> showDailyGoalSheet(
  BuildContext context, {
  required DailyGoal selected,
  required ValueChanged<DailyGoal> onChanged,
}) {
  return _openSheet(
    context,
    _LocalValue<DailyGoal>(
      initial: selected,
      builder:
          (
            BuildContext context,
            DailyGoal value,
            ValueChanged<DailyGoal> update,
          ) => SettingsSheet(
            title: ProfileContent.goalSectionLabel,
            children: <Widget>[
              for (final DailyGoal goal in DailyGoal.values)
                ChoiceTile(
                  label:
                      '${ProfileContent.goalLabels[goal]!} · ${goal.count} '
                      '${ProfileContent.goalUnit}',
                  selected: value == goal,
                  onTap: () {
                    update(goal);
                    onChanged(goal);
                  },
                ),
            ],
          ),
    ),
  );
}

Future<void> showNotificationSheet(
  BuildContext context, {
  required NotificationPrefs prefs,
  required ValueChanged<NotificationPrefs> onChanged,
}) {
  return _openSheet(
    context,
    _LocalValue<NotificationPrefs>(
      initial: prefs,
      builder:
          (
            BuildContext context,
            NotificationPrefs value,
            ValueChanged<NotificationPrefs> update,
          ) => SettingsSheet(
            title: ProfileContent.notificationsSheetTitle,
            children: <Widget>[
              SwitchTile(
                label: ProfileContent.practiceReminderLabel,
                description: ProfileContent.practiceReminderDescription,
                value: value.practiceReminder,
                onChanged: (bool enabled) {
                  final NotificationPrefs next = value.copyWith(
                    practiceReminder: enabled,
                  );
                  update(next);
                  onChanged(next);
                },
              ),
              SwitchTile(
                label: ProfileContent.streakGuardLabel,
                description: ProfileContent.streakGuardDescription,
                value: value.streakGuard,
                onChanged: (bool enabled) {
                  final NotificationPrefs next = value.copyWith(
                    streakGuard: enabled,
                  );
                  update(next);
                  onChanged(next);
                },
              ),
              SwitchTile(
                label: ProfileContent.newContentLabel,
                description: ProfileContent.newContentDescription,
                value: value.newContent,
                onChanged: (bool enabled) {
                  final NotificationPrefs next = value.copyWith(
                    newContent: enabled,
                  );
                  update(next);
                  onChanged(next);
                },
              ),
            ],
          ),
    ),
  );
}

Future<void> showAudioSheet(
  BuildContext context, {
  required AudioPrefs audio,
  required ValueChanged<AudioPrefs> onChanged,
}) {
  return _openSheet(
    context,
    _LocalValue<AudioPrefs>(
      initial: audio,
      builder:
          (
            BuildContext context,
            AudioPrefs value,
            ValueChanged<AudioPrefs> update,
          ) => SettingsSheet(
            title: ProfileContent.audioSheetTitle,
            children: <Widget>[
              SwitchTile(
                label: ProfileContent.readAloudLabel,
                description: ProfileContent.readAloudDescription,
                value: value.readAloud,
                onChanged: (bool enabled) {
                  final AudioPrefs next = value.copyWith(readAloud: enabled);
                  update(next);
                  onChanged(next);
                },
              ),
              SwitchTile(
                label: ProfileContent.soundEffectsLabel,
                description: ProfileContent.soundEffectsDescription,
                value: value.soundEffects,
                onChanged: (bool enabled) {
                  final AudioPrefs next = value.copyWith(soundEffects: enabled);
                  update(next);
                  onChanged(next);
                },
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                ProfileContent.audioSpeedLabel,
                style: AppTypography.bodySm.copyWith(color: AppColors.body),
              ),
              const SizedBox(height: AppSpacing.sm),
              SpeedChips(
                speed: value.speed,
                onChanged: (double speed) {
                  final AudioPrefs next = value.copyWith(speed: speed);
                  update(next);
                  onChanged(next);
                },
              ),
            ],
          ),
    ),
  );
}

Future<void> showReadingSheet(
  BuildContext context, {
  required ReadingPrefs reading,
  required ValueChanged<ReadingPrefs> onChanged,
}) {
  return _openSheet(
    context,
    _LocalValue<ReadingPrefs>(
      initial: reading,
      builder:
          (
            BuildContext context,
            ReadingPrefs value,
            ValueChanged<ReadingPrefs> update,
          ) => SettingsSheet(
            title: ProfileContent.readingSheetTitle,
            children: <Widget>[
              Text(
                ProfileContent.textSizeLabel,
                style: AppTypography.bodySm.copyWith(color: AppColors.body),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: <Widget>[
                  for (final ReadingTextSize size in ReadingTextSize.values)
                    ChoiceChip(
                      label: Text(ProfileContent.textSizeLabels[size]!),
                      selected: value.textSize == size,
                      onSelected: (bool _) {
                        final ReadingPrefs next = value.copyWith(
                          textSize: size,
                        );
                        update(next);
                        onChanged(next);
                      },
                      labelStyle: AppTypography.bodySm.copyWith(
                        color: value.textSize == size
                            ? AppColors.primaryPressed
                            : AppColors.bodyMuted,
                      ),
                      side: BorderSide(
                        color: value.textSize == size
                            ? AppColors.primary
                            : AppColors.hairline,
                        width: AppSizes.borderWidth,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              SwitchTile(
                label: ProfileContent.showTranslationLabel,
                description: ProfileContent.showTranslationDescription,
                value: value.showTranslation,
                onChanged: (bool enabled) {
                  final ReadingPrefs next = value.copyWith(
                    showTranslation: enabled,
                  );
                  update(next);
                  onChanged(next);
                },
              ),
              SwitchTile(
                label: ProfileContent.tapToTranslateLabel,
                description: ProfileContent.tapToTranslateDescription,
                value: value.tapToTranslate,
                onChanged: (bool enabled) {
                  final ReadingPrefs next = value.copyWith(
                    tapToTranslate: enabled,
                  );
                  update(next);
                  onChanged(next);
                },
              ),
            ],
          ),
    ),
  );
}

/// Sheet içindeki geçici seçimi tutar; kalıcı kayıt callback'e aittir.
class _LocalValue<T> extends StatefulWidget {
  const _LocalValue({required this.initial, required this.builder});

  final T initial;
  final Widget Function(BuildContext context, T value, ValueChanged<T> update)
  builder;

  @override
  State<_LocalValue<T>> createState() => _LocalValueState<T>();
}

class _LocalValueState<T> extends State<_LocalValue<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      _value,
      (T next) => setState(() => _value = next),
    );
  }
}
